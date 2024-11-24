package refactor.refactor;

import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.edits.Changelist;
import refactor.refactor.RefactorHelper.TokensAtPos;
import refactor.refactor.extractmethod.CodeGenAsExpression;
import refactor.refactor.extractmethod.CodeGenEmptyReturn;
import refactor.refactor.extractmethod.CodeGenNoReturn;
import refactor.refactor.extractmethod.CodeGenOpenEnded;
import refactor.refactor.extractmethod.CodeGenReturnIsLast;
import refactor.refactor.extractmethod.ExtractMethodData;
import refactor.refactor.extractmethod.ICodeGen;
import refactor.typing.TypeHintType;

class ExtractMethod {
	public static function canRefactor(context:CanRefactorContext):CanRefactorResult {
		final extractData = makeExtractMethodData(context);
		if (extractData == null) {
			return Unsupported;
		}
		return Supported('Extract Method as ${extractData.newMethodName}');
	}

	public static function doRefactor(context:RefactorContext):Promise<RefactorResult> {
		final extractData = makeExtractMethodData(context);
		if (extractData == null) {
			return Promise.resolve(RefactorResult.Unsupported("failed to collect extract method data"));
		}
		final changelist:Changelist = new Changelist(context);

		// identifier of top-level containing function
		final functionIdentifier = getFunctionIdentifier(extractData, context);
		if (functionIdentifier == null) {
			return Promise.resolve(RefactorResult.Unsupported("failed to find identifier of containing function"));
		}

		// find all parameters for extracted method
		// e.g. all scoped vars used inside selected code
		var neededIdentifiers:Array<Identifier> = findParameters(extractData, context, functionIdentifier);

		// determine type of selected code
		var codeGen:Null<ICodeGen> = findCodeGen(extractData, context, functionIdentifier, neededIdentifiers);
		if (codeGen == null) {
			return Promise.resolve(RefactorResult.Unsupported("could not extract method from selected code - no codegen"));
		}

		var parameterList:String = "";
		var returnTypeHint:String = "";

		// resolve all parameter types either from typehint or using a hover request with Haxe server
		var parameterPromise = Promise.all(makeParameterList(extractData, context, neededIdentifiers)).then(function(params):Promise<Bool> {
			parameterList = params.join(", ");
			return Promise.resolve(true);
		});
		// resolve function return typehint

		var returnHintPromise = codeGen.makeReturnTypeHint().then(function(typeHint) {
			returnTypeHint = typeHint;
			return Promise.resolve(true);
		});

		// all necessary types resolved
		return Promise.all([parameterPromise, returnHintPromise]).then(function(_) {
			// replace selected code with call to newly extracted method
			final extractedCall:String = codeGen.makeCallSite();

			changelist.addChange(context.what.fileName,
				ReplaceText(extractedCall, {fileName: context.what.fileName, start: extractData.startToken.pos.min, end: extractData.endToken.pos.max}, true),
				null);

			// insert new method with function signature and body after current function
			final staticModifier = extractData.isStatic ? "static " : "";
			final functionDefinition:String = '${staticModifier}function ${extractData.newMethodName}($parameterList)$returnTypeHint';
			final body:String = codeGen.makeBody();

			changelist.addChange(context.what.fileName,
				InsertText(functionDefinition + body, {fileName: context.what.fileName, start: extractData.newMethodOffset, end: extractData.newMethodOffset},
					true),
				null);

			return changelist.execute();
		});
	}

	static function makeExtractMethodData(context:CanRefactorContext):Null<ExtractMethodData> {
		final fileContent = context.fileReader(context.what.fileName);
		var content:String;
		var root:TokenTree;
		switch (fileContent) {
			case Text(_):
				return null;
			case Token(tokens, text):
				content = text;
				root = tokens;
		}
		if (root == null) {
			return null;
		}
		if (content == null) {
			return null;
		}

		final file:Null<File> = context.fileList.getFile(context.what.fileName);
		if (file == null) {
			return null;
		}
		// find corresponding tokens in tokentree, selection start/end in whitespace
		final tokensStart:TokensAtPos = RefactorHelper.findTokensAtPos(root, context.what.posStart);
		final tokensEnd:TokensAtPos = RefactorHelper.findTokensAtPos(root, context.what.posEnd);
		if (tokensStart.after == null) {
			return null;
		}
		if (tokensEnd.before == null) {
			return null;
		}

		final tokenStart:Null<TokenTree> = tokensStart.after;
		final tokenEnd:Null<TokenTree> = tokensEnd.before;

		if (tokenStart == null || tokenEnd == null) {
			return null;
		}
		if (tokenStart.index >= tokenEnd.index) {
			return null;
		}
		// currently not supporting extracting an inner function
		switch (tokenStart.tok) {
			case Kwd(KwdFunction):
				return null;
			case Const(_):
				if (tokenStart.hasChildren()) {
					final child = tokenStart.getFirstChild();
					if (child.matches(Arrow)) {
						return null;
					}
				}
			case POpen:
				switch (TokenTreeCheckUtils.getPOpenType(tokenStart)) {
					case Parameter:
						return null;
					default:
				}
			default:
		}

		final tokenEndLast:Null<TokenTree> = TokenTreeCheckUtils.getLastToken(tokenEnd);
		if (tokenEndLast == null) {
			return null;
		}
		if (tokenEnd.index != tokenEndLast.index) {
			return null;
		}

		// extracting only works if parent of start token is also grand…parent of end token
		if (!shareSameParent(tokenStart, tokenEnd)) {
			return null;
		}

		// find top-level containing function
		var parentFunction:Null<TokenTree> = findParentFunction(tokenStart);
		if (parentFunction == null) {
			return null;
		}
		var parentParentFunction:Null<TokenTree>;
		while ((parentParentFunction = findParentFunction(parentFunction)) != null) {
			parentFunction = parentParentFunction;
		}

		var isStatic = parentFunction.access().firstChild().firstOf(Kwd(KwdStatic)).exists();
		var isSingleExpr = isSingleExpression(tokenStart, tokenEnd);

		final lastToken:Null<TokenTree> = TokenTreeCheckUtils.getLastToken(parentFunction);
		if (lastToken == null) {
			return null;
		}
		final newMethodOffset = lastToken.pos.max + 1;

		// suggest name + Extract for new method name
		final nameToken:Null<TokenTree> = parentFunction.getFirstChild();
		if (nameToken == null) {
			return null;
		}
		final name:String = nameToken.toString();
		final newMethodName = '${name}Extract';

		return {
			content: content,
			root: root,
			startToken: tokenStart,
			endToken: tokenEnd,
			newMethodOffset: newMethodOffset,
			newMethodName: newMethodName,
			functionToken: parentFunction,
			isStatic: isStatic,
			isSingleExpr: isSingleExpr,
		};
	}

	static function shareSameParent(tokenA:TokenTree, tokenB:TokenTree):Bool {
		var parentA = tokenA.parent;
		if (parentA == null) {
			return false;
		}
		var parentB = tokenB.parent;
		while (true) {
			if (parentB == null) {
				return false;
			}
			if (parentA.index == parentB.index) {
				return true;
			}
			parentB = parentB.parent;
		}
	}

	static function getFunctionIdentifier(extractData:ExtractMethodData, context:RefactorContext):Null<Identifier> {
		final file:Null<File> = context.fileList.getFile(context.what.fileName);
		if (file == null) {
			return null;
		}
		return file.getIdentifier(extractData.functionToken.getFirstChild().pos.min);
	}

	static function findParameters(extractData:ExtractMethodData, context:RefactorContext, functionIdentifier:Identifier) {
		final allIdentifiersBefore = getScopedBeforeSelected(extractData, context, functionIdentifier);

		final scopedInside:Array<Identifier> = [];
		final allUsesInside = functionIdentifier.findAllIdentifiers(identifier -> {
			if ((identifier.pos.start < extractData.startToken.pos.min) || (identifier.pos.start > extractData.endToken.pos.min)) {
				return false;
			}
			switch (identifier.type) {
				case ScopedLocal(_):
					scopedInside.push(identifier);
					return false;
				default:
			}
			return true;
		});
		final avail:Map<String, Identifier> = new Map<String, Identifier>();
		for (use in allIdentifiersBefore) {
			avail.set(use.name, use);
		}
		var neededIdentifiers:Array<Identifier> = [];
		for (use in allUsesInside) {
			final parts = use.name.split(".");
			final first = parts.shift();
			var shadowed = false;
			for (scoped in scopedInside) {
				if (scoped.name != first) {
					continue;
				}
				switch (scoped.type) {
					case ScopedLocal(scopeStart, scopeEnd, _):
						if (scopeStart <= use.pos.start && scopeEnd >= use.pos.end) {
							shadowed = true;
							break;
						}
					default:
				}
			}
			if (shadowed) {
				continue;
			}

			if (!avail.exists(first)) {
				continue;
			}
			final id = avail.get(first);
			if (neededIdentifiers.contains(id)) {
				continue;
			}
			neededIdentifiers.push(id);
		}

		return neededIdentifiers;
	}

	static function getScopedBeforeSelected(extractData:ExtractMethodData, context:RefactorContext, functionIdentifier:Identifier):Array<Identifier> {
		return functionIdentifier.findAllIdentifiers(identifier -> {
			if ((identifier.pos.start < extractData.functionToken.pos.min) || (identifier.pos.start >= extractData.startToken.pos.min)) {
				return false;
			}
			if (identifier.name.contains(".")) {
				return false;
			}
			return switch (identifier.type) {
				case ScopedLocal(scopeStart, scopeEnd, _):
					if (scopeEnd <= extractData.startToken.pos.min) {
						return false;
					}
					if (scopeStart > extractData.endToken.pos.max) {
						return false;
					}
					true;
				default:
					false;
			}
		});
	}

	static function getScopedInsideSelected(extractData:ExtractMethodData, context:RefactorContext, functionIdentifier:Identifier):Array<Identifier> {
		return functionIdentifier.findAllIdentifiers(identifier -> {
			if ((identifier.pos.start < extractData.startToken.pos.min) || (identifier.pos.start > extractData.endToken.pos.min)) {
				return false;
			}
			switch (identifier.type) {
				case ScopedLocal(_):
					return true;
				default:
			}
			return false;
		});
	}

	static function isSingleExpression(tokenStart:TokenTree, tokenEnd:TokenTree):Bool {
		var fullPos = tokenStart.getPos();
		if ((tokenEnd.pos.min >= fullPos.min) && (tokenEnd.pos.max <= fullPos.max)) {
			return true;
		}
		if (tokenEnd.matches(Semicolon)) {
			return (tokenEnd.pos.min == fullPos.max);
		}

		return false;
	}

	static function findParentFunction(token:TokenTree):Null<TokenTree> {
		var parent:Null<TokenTree> = token.parent;
		while (parent != null && parent.tok != null) {
			switch parent.tok {
				case Kwd(KwdFunction):
					return parent;
				default:
			}
			parent = parent.parent;
		}
		return null;
	}

	static function findCodeGen(extractData:ExtractMethodData, context:RefactorContext, functionIdentifier:Identifier,
			neededIdentifiers:Array<Identifier>):Null<ICodeGen> {
		final assignedVars:Array<String> = [];
		final parent = extractData.startToken.parent;

		if (usedAsExpression(parent)) {
			if (extractData.isSingleExpr) {
				return new CodeGenAsExpression(extractData, context, neededIdentifiers);
			} else {
				return null;
			}
		}

		final leakingVars = findAdditionalScopedVars(extractData, context, functionIdentifier, neededIdentifiers);

		final allReturns = parent.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			if (token.pos.max < extractData.startToken.pos.min) {
				return GoDeeper;
			}
			if (token.pos.min > extractData.endToken.pos.max) {
				return SkipSubtree;
			}
			switch (token.tok) {
				case Kwd(KwdFunction) | Arrow:
					return SkipSubtree;
				case Kwd(KwdReturn):
					return FoundSkipSubtree;
				case Const(CIdent(s)):
					var child = token.getFirstChild();
					if (child != null) {
						switch (child.tok) {
							case Binop(OpAssign) | Binop(OpAssignOp(_)):
								assignedVars.push(s);
							case Unop(OpIncrement) | Unop(OpDecrement):
								assignedVars.push(s);
							default:
						}
					}
				default:
			}
			return GoDeeper;
		});
		if (allReturns.length > 0) {
			var lastReturn = allReturns[allReturns.length - 1];
			if (isSingleExpression(lastReturn, extractData.endToken)) {
				return new CodeGenReturnIsLast(extractData, context, neededIdentifiers);
			}
		}

		var modifiedCandidates:Map<String, Identifier> = new Map<String, Identifier>();
		for (identifier in neededIdentifiers) {
			if (assignedVars.contains(identifier.name)) {
				modifiedCandidates.set(identifier.name, identifier);
			}
		}
		final modifiedIdentifiers = findIdentifiersUsedAfterSelection(extractData, functionIdentifier, modifiedCandidates);

		if (allReturns.length == 0) {
			return new CodeGenNoReturn(extractData, context, neededIdentifiers, modifiedIdentifiers, leakingVars);
		}
		for (ret in allReturns) {
			var child = ret.getFirstChild();
			if (child == null) {
				return null;
			}
			switch (child.tok) {
				case Semicolon:
					return new CodeGenEmptyReturn(extractData, context, neededIdentifiers, allReturns, modifiedIdentifiers, leakingVars);
				default:
					return new CodeGenOpenEnded(extractData, context, neededIdentifiers, allReturns, modifiedIdentifiers, leakingVars);
			}
		}
		return null;
	}

	static function findAdditionalScopedVars(extractData:ExtractMethodData, context:RefactorContext, functionIdentifier:Identifier,
			neededParams:Array<Identifier>):Array<Identifier> {
		// find all scoped identifiers that are valid beyond user's selection
		final allVarsInsideSelection = getScopedInsideSelected(extractData, context, functionIdentifier);
		final varsValidAfterSelection:Map<String, Identifier> = new Map<String, Identifier>();
		for (identifier in allVarsInsideSelection) {
			switch (identifier.type) {
				case ScopedLocal(scopeStart, scopeEnd, _):
					if (scopeEnd > context.what.posEnd) {
						varsValidAfterSelection.set(identifier.name, identifier);
					}
				default:
			}
		}

		return findIdentifiersUsedAfterSelection(extractData, functionIdentifier, varsValidAfterSelection);
	}

	static function findIdentifiersUsedAfterSelection(extractData:ExtractMethodData, functionIdentifier:Identifier,
			varsValidAfterSelection:Map<String, Identifier>):Array<Identifier> {
		// find all identifier uses after user's selection that share same name
		final varShadows:Map<String, Identifier> = new Map<String, Identifier>();
		final allIdentifierUses:Array<Identifier> = functionIdentifier.findAllIdentifiers(identifier -> {
			if (identifier.pos.start < extractData.endToken.pos.max) {
				return false;
			}
			final parts = identifier.name.split(".");
			final part = parts.shift();
			if (!varsValidAfterSelection.exists(part)) {
				return false;
			}
			final scoped:Identifier = varsValidAfterSelection.get(part);
			switch (scoped.type) {
				case ScopedLocal(_, scopeEnd, _):
					if (identifier.pos.start > scopeEnd) {
						return false;
					}
				default:
					return false;
			}
			switch (identifier.type) {
				case ScopedLocal(_):
					// new scoped identifier that shadows the one from selection
					varShadows.set(identifier.name, identifier);
					return false;
				default:
			}
			return true;
		});

		// apply shadows
		final scopedVarUses:Array<Identifier> = [];
		for (use in allIdentifierUses) {
			final parts = use.name.split(".");
			final part = parts.shift();
			if (varShadows.exists(part)) {
				final shadow = varShadows.get(part);
				if ((use.pos.start >= shadow.pos.start) && (use.pos.end <= shadow.pos.end)) {
					continue;
				}
			}
			final scopedVar = varsValidAfterSelection.get(part);
			if (scopedVarUses.contains(scopedVar)) {
				continue;
			}
			scopedVarUses.push(scopedVar);
			trace("leaking " + varsValidAfterSelection.get(part));
		}
		return scopedVarUses;
	}

	static function makeParameterList(extractData:ExtractMethodData, context:RefactorContext, neededIdentifiers:Array<Identifier>):Array<Promise<String>> {
		var promises:Array<Promise<String>> = [];
		for (identifier in neededIdentifiers) {
			final promise = findTypeOfIdentifier(context, identifier).then(function(typeHint):Promise<String> {
				trace("typehint resolved: " + identifier + " " + PrintHelper.typeHintToString(typeHint));
				return Promise.resolve(buildParameter(identifier, typeHint));
			});

			promises.push(promise);
		}
		return promises;
	}

	public static function findTypeOfIdentifier(context:RefactorContext, identifier:Identifier):Promise<TypeHintType> {
		var hint = identifier.getTypeHint();
		if (hint != null) {
			return TypingHelper.typeFromTypeHint(context, hint);
		}
		return TypingHelper.findTypeOfIdentifier(context, {
			name: identifier.name,
			pos: identifier.pos.end - 1,
			defineType: identifier.defineType
		});
	}

	static function buildParameter(identifier:Identifier, typeHint:TypeHintType):String {
		if (typeHint == null) {
			return '${identifier.name}:Any';
		}
		return '${identifier.name}:${PrintHelper.printTypeHint(typeHint)}';
	}

	static function usedAsExpression(token:Null<TokenTree>):Bool {
		if (token == null) {
			return false;
		}
		return switch (token.tok) {
			case Kwd(KwdReturn):
				true;
			case Binop(_):
				true;
			case POpen:
				true;
			default:
				return false;
		}
	}
}

private typedef NewFunctionParameter = {
	final call:String;
	final param:String;
}
