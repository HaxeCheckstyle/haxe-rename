package refactor.refactor;

import refactor.edits.Changelist;
import refactor.refactor.RefactorHelper.TokensAtPos;

class RewriteVarsToFinals {
	public static function canRefactor(context:CanRefactorContext, toFinals:Bool):CanRefactorResult {
		final extractData = makeRewriteVarsToFinalsData(context, toFinals);
		if (extractData == null) {
			return Unsupported;
		}
		if (toFinals) {
			return Supported('Rewrite Vars to Finals');
		} else {
			return Supported('Rewrite Finals to Vars');
		}
	}

	public static function doRefactor(context:RefactorContext, toFinals:Bool):Promise<RefactorResult> {
		final extractData = makeRewriteVarsToFinalsData(context, toFinals);
		if (extractData == null) {
			return Promise.reject("failed to collect rewrite vars/finals data");
		}
		final changelist:Changelist = new Changelist(context);

		for (varToken in extractData.allVarTokens) {
			if (toFinals) {
				changelist.addChange(context.what.fileName,
					ReplaceText("final", {fileName: context.what.fileName, start: varToken.pos.min, end: varToken.pos.max}, NoFormat), null);
			} else {
				changelist.addChange(context.what.fileName,
					ReplaceText("var", {fileName: context.what.fileName, start: varToken.pos.min, end: varToken.pos.max}, NoFormat), null);
			}
		}

		return Promise.resolve(changelist.execute());
	}

	static function makeRewriteVarsToFinalsData(context:CanRefactorContext, toFinals:Bool):Null<RewriteVarsToFinalsData> {
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

		// find corresponding tokens in tokentree, selection start/end in whitespace
		final tokensStart:TokensAtPos = RefactorHelper.findTokensAtPos(root, context.what.posStart);
		final tokensEnd:TokensAtPos = RefactorHelper.findTokensAtPos(root, context.what.posEnd);
		if (tokensStart.after == null || tokensEnd.before == null) {
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
		final parent = tokenStart.parent;
		if (parent == null) {
			return null;
		}
		final allVarTokens:Array<TokenTree> = parent.filterCallback(function(token, index) {
			if (token.pos.max < context.what.posStart) {
				return GoDeeper;
			}
			if (token.pos.min > context.what.posEnd) {
				return SkipSubtree;
			}
			return switch (token.tok) {
				case Kwd(KwdVar) if (toFinals):
					FoundSkipSubtree;
				case Kwd(KwdVar):
					SkipSubtree;
				case Kwd(KwdFinal):
					var finalParent = token.parent;
					if (finalParent == null) {
						return SkipSubtree;
					}
					return switch (finalParent.tok) {
						case Const(_):
							GoDeeper;
						default:
							if (toFinals) {
								return SkipSubtree;
							} else {
								return FoundSkipSubtree;
							}
					}
				default:
					GoDeeper;
			}
		});
		if (allVarTokens.length <= 0) {
			return null;
		}

		return {
			content: content,
			root: root,
			allVarTokens: allVarTokens,
		};
	}
}

typedef RewriteVarsToFinalsData = {
	var content:String;
	var root:TokenTree;
	var allVarTokens:Array<TokenTree>;
}
