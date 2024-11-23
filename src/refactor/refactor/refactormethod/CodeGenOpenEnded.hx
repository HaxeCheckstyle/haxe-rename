package refactor.refactor.refactormethod;

import refactor.discover.Identifier;
import refactor.refactor.ExtractMethod.ExtractMethodData;

class CodeGenOpenEnded extends CodeGenBase {
	final returnTokens:Array<TokenTree>;

	public function new(extractData:ExtractMethodData, context:RefactorContext, neededIdentifiers:Array<Identifier>, returnTokens:Array<TokenTree>) {
		super(extractData, context, neededIdentifiers);

		this.returnTokens = returnTokens;
	}

	public function makeCallSite():String {
		final callParams:String = neededIdentifiers.map(i -> i.name).join(", ");
		return 'switch (${extractData.newMethodName}($callParams)) {\n' + 'case None:\n' + 'case Some(data):\n' + 'return data;\n}\n';
	}

	public function makeReturnTypeHint():Promise<String> {
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
	}

	public function makeBody():String {
		final selectedSnippet = RefactorHelper.extractText(context.converter, extractData.content, extractData.startToken.pos.min,
			extractData.endToken.pos.max);
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
		return " {\n" + snippet + "\nreturn None;\n}\n";
	}
}
