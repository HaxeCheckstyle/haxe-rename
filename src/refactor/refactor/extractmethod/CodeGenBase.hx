package refactor.refactor.extractmethod;

import refactor.discover.Identifier;
import refactor.typing.TypeHintType;

abstract class CodeGenBase implements ICodeGen {
	final extractData:ExtractMethodData;
	final context:RefactorContext;
	final neededIdentifiers:Array<Identifier>;

	public function new(extractData:ExtractMethodData, context:RefactorContext, neededIdentifiers:Array<Identifier>) {
		this.extractData = extractData;
		this.context = context;
		this.neededIdentifiers = neededIdentifiers;
	}

	function findTypeOfIdentifier(identifier:Identifier):Promise<TypeHintType> {
		return ExtractMethod.findTypeOfIdentifier(context, identifier);
	}

	function replaceReturnValues(returnTokens:Array<TokenTree>, callback:ReturnValueCallback):String {
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
			snippet = before + "return " + callback(retValue) + ";" + after;
		}
		return snippet;
	}
}

typedef ReturnValueCallback = (value:String) -> String;
