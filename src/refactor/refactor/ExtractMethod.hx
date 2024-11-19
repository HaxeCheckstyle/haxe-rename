package refactor.refactor;

import refactor.TypingHelper.TypeHintType;
import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.edits.Changelist;
import refactor.refactor.RefactorHelper.TokensAtPos;

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
			return Promise.reject("failed to collect extract method data");
		}
		final changelist:Changelist = new Changelist(context);

		var neededIdentifiers:Array<Identifier> = findParameters(extractData, context);

		var returnType = findReturnType(extractData, context, neededIdentifiers);
		if (returnType == Invalid) {
			return Promise.reject("could not extract method from selected code");
		}

		var parameterList:String = "";
		var returnTypeHint:String = "";

		var parameterPromise = Promise.all(makeParameterList(extractData, context, neededIdentifiers)).then(function(params):Promise<Bool> {
			parameterList = params.join(", ");
			return Promise.resolve(true);
		});
		var returnHintPromise = makeReturnTypeHint(extractData, context, returnType).then(function(typeHint) {
			returnTypeHint = typeHint;
			return Promise.resolve(true);
		});

		return Promise.all([parameterPromise, returnHintPromise]).then(function(_) {
			final extractedCall:String = makeCallSite(extractData, context, neededIdentifiers, returnType);

			final staticModifier = extractData.isStatic ? "static " : "";

			final functionDefinition:String = '${staticModifier}function ${extractData.newMethodName}($parameterList)$returnTypeHint';
			final body:String = makeBody(extractData, context, returnType);

			changelist.addChange(context.what.fileName,
				ReplaceText(extractedCall, {fileName: context.what.fileName, start: extractData.startToken.pos.min, end: extractData.endToken.pos.max}, true),
				null);

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
		switch (tokenStart.tok) {
			case Kwd(KwdFunction):
				return null;
			default:
		}

		final tokenEndLast:Null<TokenTree> = TokenTreeCheckUtils.getLastToken(tokenEnd);
		if (tokenEndLast == null) {
			return null;
		}
		if (tokenEnd.index != tokenEndLast.index) {
			return null;
		}

		if (!shareSameParent(tokenStart, tokenEnd)) {
			return null;
		}
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

	static function findParameters(extractData:ExtractMethodData, context:RefactorContext) {
		final file:Null<File> = context.fileList.getFile(context.what.fileName);
		if (file == null) {
			return [];
		}
		final functionIdentifier = file.getIdentifier(extractData.functionToken.getFirstChild().pos.min);
		if (functionIdentifier == null) {
			return [];
		}
		final allIdentifiersBefore = functionIdentifier.findAllIdentifiers(identifier -> {
			if ((identifier.pos.start < extractData.functionToken.pos.min) || (identifier.pos.start >= extractData.startToken.pos.min)) {
				return false;
			}
			if (identifier.name.contains(".")) {
				return false;
			}
			switch (identifier.type) {
				case ScopedLocal(scopeStart, scopeEnd, _):
					if (scopeEnd <= extractData.startToken.pos.min) {
						return false;
					}
					if (scopeStart > extractData.endToken.pos.max) {
						return false;
					}
					return true;
				default:
					return false;
			}
		});

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

	static function isSingleExpression(tokenStart:TokenTree, tokenEnd:TokenTree):Bool {
		var fullPos = tokenStart.getPos();
		return (tokenEnd.pos.min >= fullPos.min) && (tokenEnd.pos.max <= fullPos.max);
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

	static function findReturnType(extractData:ExtractMethodData, context:RefactorContext, neededParams:Array<Identifier>):ReturnType {
		final assignedVars:Array<String> = [];
		final parent = extractData.startToken.parent;

		if (usedAsExpression(parent)) {
			if (extractData.isSingleExpr) {
				return ReturnAsExpression;
			} else {
				return Invalid;
			}
		}

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
				return ReturnIsLast(lastReturn);
			}
		}

		final modifiedIdentifiers:Array<Identifier> = [];
		for (identifier in neededParams) {
			if (assignedVars.contains(identifier.name)) {
				modifiedIdentifiers.push(identifier);
				trace(identifier.name + " modified");
			}
		}

		if (allReturns.length == 0) {
			return NoReturn(modifiedIdentifiers);
		}
		for (ret in allReturns) {
			var child = ret.getFirstChild();
			if (child == null) {
				return Invalid;
			}
			switch (child.tok) {
				case Semicolon:
					return EmptyReturn(modifiedIdentifiers);
				default:
					if (modifiedIdentifiers.length > 0) {
						return Invalid;
					}
					return OpenEndedReturn(allReturns);
			}
		}
		return Invalid;
	}

	static function makeParameterList(extractData:ExtractMethodData, context:RefactorContext, neededIdentifiers:Array<Identifier>):Array<Promise<String>> {
		var promises:Array<Promise<String>> = [];
		for (identifier in neededIdentifiers) {
			final promise = findTypeOfIdentifier(context, identifier).then(function(typeHint):Promise<String> {
				trace("typehint resolved: " + PrintHelper.typeHintToString(typeHint));
				return Promise.resolve(buildParameter(identifier, typeHint));
			});

			promises.push(promise);
		}
		return promises;
	}

	static function findTypeOfIdentifier(context:RefactorContext, identifier:Identifier):Promise<TypeHintType> {
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

	static function makeCallSite(extractData:ExtractMethodData, context:RefactorContext, neededIdentifiers:Array<Identifier>, returnType:ReturnType):String {
		final callParams:String = neededIdentifiers.map(i -> i.name).join(", ");
		return switch (returnType) {
			case NoReturn(assignments):
				switch (assignments.length) {
					case 0:
						'${extractData.newMethodName}($callParams);\n';
					case 1:
						'${assignments[0].name} = ${extractData.newMethodName}($callParams);\n';
					default:
						final assignData = assignments.map(a -> '${a.name} = data.${a.name};').join("\n");
						'{\nfinal data = ${extractData.newMethodName}($callParams);\n' + assignData + "}\n";
				}
			case ReturnAsExpression:
				'${extractData.newMethodName}($callParams)';
			case ReturnIsLast(_):
				'return ${extractData.newMethodName}($callParams);\n';
			case EmptyReturn(assignments):
				switch (assignments.length) {
					case 0:
						'if (!${extractData.newMethodName}($callParams)) {\nreturn;\n}\n';
					case 1:
						'switch (${extractData.newMethodName}($callParams)) {\n'
						+ 'case None:\n'
						+ 'return;\n'
						+ 'case Some(data):\n'
						+ '${assignments[0].name} = data;\n}\n';
					default:
						final assignData = assignments.map(a -> '${a.name} = data.${a.name};').join("\n");
						'{\nfinal data =${extractData.newMethodName}($callParams);\n' + assignData + "}\n";
						'switch (${extractData.newMethodName}($callParams)) {\n'
						+ 'case None:\n'
						+ 'return;\n'
						+ 'case Some(data):\n'
						+ '${assignData}}\n';
				}
			case OpenEndedReturn(_):
				'switch (${extractData.newMethodName}($callParams)) {\n'
				+ 'case None:\n'
				+ 'case Some(data):\n'
				+ 'return data;\n}\n';
			case Invalid:
				"";
		}
	}

	static function makeReturnTypeHint(extractData:ExtractMethodData, context:RefactorContext, returnType:ReturnType):Promise<String> {
		switch (returnType) {
			case NoReturn(assignments):
				switch (assignments.length) {
					case 0:
						return Promise.resolve(":Void");
					case 1:
						return findTypeOfIdentifier(context, assignments[0]).then(function(typeHint):Promise<String> {
							if (typeHint == null) {
								return Promise.resolve("");
							}
							return Promise.resolve(":" + typeHint.printTypeHint());
						});
					default:
						var promises:Array<Promise<String>> = [];
						for (assign in assignments) {
							promises.push(findTypeOfIdentifier(context, assign).then(function(typeHint):Promise<String> {
								if (typeHint == null) {
									return Promise.resolve(assign.name + ":Any");
								}
								return Promise.resolve(":" + typeHint.printTypeHint());
							}));
						}
						return Promise.all(promises).then(function(fields) {
							return Promise.resolve(":{" + fields.join(", ") + "}");
						});
				}
			case ReturnAsExpression:
				return TypingHelper.findTypeWithTyper(context, context.what.fileName, extractData.endToken.pos.max - 1)
					.then(function(typeHint):Promise<String> {
						if (typeHint == null) {
							return Promise.resolve("");
						}
						return Promise.resolve(":" + typeHint.printTypeHint());
					});
			case ReturnIsLast(lastReturnToken):
				final pos = lastReturnToken.getPos();
				return TypingHelper.findTypeWithTyper(context, context.what.fileName, pos.max - 2).then(function(typeHint):Promise<String> {
					if (typeHint == null) {
						return Promise.resolve("");
					}
					return Promise.resolve(":" + typeHint.printTypeHint());
				});
			case EmptyReturn(assignments):
				switch (assignments.length) {
					case 0:
						return Promise.resolve(":Bool");
					case 1:
						return findTypeOfIdentifier(context, assignments[0]).then(function(typeHint):Promise<String> {
							if (typeHint == null) {
								return Promise.resolve("");
							}
							return Promise.resolve(":haxe.ds.Option<" + typeHint.printTypeHint() + ">");
						});
					default:
						var promises:Array<Promise<String>> = [];
						for (assign in assignments) {
							promises.push(findTypeOfIdentifier(context, assign).then(function(typeHint):Promise<String> {
								if (typeHint == null) {
									return Promise.resolve(assign.name + ":Any");
								}
								return Promise.resolve(":" + typeHint.printTypeHint());
							}));
						}
						return Promise.all(promises).then(function(fields) {
							return Promise.resolve(":haxe.ds.Option<{" + fields.join(", ") + "}>");
						});
				}
			case OpenEndedReturn(returnTokens):
				var token = returnTokens.shift();
				if (token == null) {
					return Promise.resolve("");
				}
				final pos = token.getPos();
				return TypingHelper.findTypeWithTyper(context, context.what.fileName, pos.max - 2).then(function(typeHint):Promise<String> {
					if (typeHint == null) {
						return Promise.resolve("");
					}
					return Promise.resolve(":haxe.ds.Option<" + typeHint.printTypeHint() + ">");
				});
			case Invalid:
				return Promise.resolve("");
		}
		return Promise.resolve("");
	}

	static function makeBody(extractData:ExtractMethodData, context:RefactorContext, returnType:ReturnType):String {
		final selectedSnippet = RefactorHelper.extractText(context.converter, extractData.content, extractData.startToken.pos.min,
			extractData.endToken.pos.max);
		return switch (returnType) {
			case NoReturn(assignments):
				switch (assignments.length) {
					case 0:
						" {\n" + selectedSnippet + "\n}\n";
					case 1:
						final returnAssigmentVar = '\nreturn ${assignments[0].name};';
						" {\n" + selectedSnippet + returnAssigmentVar + "\n}\n";
					default:
						final returnAssigments = "\nreturn {\n" + assignments.map(a -> '${a.name}: ${a.name},\n') + "};";
						" {\n" + selectedSnippet + returnAssigments + "\n}\n";
				}
			case ReturnAsExpression:
				" {\n" + "return " + selectedSnippet + "\n}\n";
			case ReturnIsLast(_):
				" {\n" + selectedSnippet + "\n}\n";
			case EmptyReturn(assignments):
				switch (assignments.length) {
					case 0:
						final reg:EReg = ~/^([ \t]*)return[ \t]*;/gm;
						final replacedSnippet = reg.map(selectedSnippet, f -> f.matched(1) + "return false;");
						" {\n" + replacedSnippet + "\nreturn true;\n}\n";
					case 1:
						final reg:EReg = ~/^([ \t]*)return[ \t]*;/gm;
						final replacedSnippet = reg.map(selectedSnippet, f -> f.matched(1) + "return None;");
						final returnAssigmentVar = '\nreturn Some(${assignments[0].name});';
						" {\n" + replacedSnippet + returnAssigmentVar + "\n}\n";
					default:
						final reg:EReg = ~/^([ \t]*)return[ \t]*;/gm;
						final replacedSnippet = reg.map(selectedSnippet, f -> f.matched(1) + "return None;");
						final returnAssigments = "\nreturn Some({\n" + assignments.map(a -> '${a.name}: ${a.name},\n') + "});";
						" {\n" + replacedSnippet + returnAssigments + "\n}\n";
				}
			case OpenEndedReturn(returnTokens):
				var startOffset = context.converter(extractData.content, extractData.startToken.pos.min);
				var snippet = selectedSnippet;
				returnTokens.reverse();
				for (token in returnTokens) {
					var pos = token.getPos();
					var returnStart = context.converter(extractData.content, pos.min);
					var returnEnd = context.converter(extractData.content, pos.max);
					returnStart -= startOffset;
					returnEnd -= startOffset;
					var before = snippet.substring(0, returnStart);
					var after = snippet.substring(returnEnd);
					var retValue = snippet.substring(returnStart + 7, returnEnd - 1);
					snippet = before + "return Some(" + retValue + ");" + after;
				}
				" {\n" + snippet + "\nreturn None;\n}\n";
			case Invalid:
				"";
		}
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

typedef ExtractMethodData = {
	var content:String;
	var root:TokenTree;
	var startToken:TokenTree;
	var endToken:TokenTree;
	var newMethodName:String;
	var newMethodOffset:Int;
	var functionToken:TokenTree;
	var isStatic:Bool;
	var isSingleExpr:Bool;
}

enum ReturnType {
	NoReturn(assignments:Array<Identifier>);
	ReturnAsExpression;
	ReturnIsLast(lastReturnToken:TokenTree);
	EmptyReturn(assignments:Array<Identifier>);
	OpenEndedReturn(returnTokens:Array<TokenTree>);
	Invalid;
}
