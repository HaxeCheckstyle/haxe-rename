package refactor.refactor.refactormethod;

import refactor.discover.Identifier;
import refactor.refactor.ExtractMethod.ExtractMethodData;

class CodeGenReturnIsLast extends CodeGenBase {
	final lastReturnToken:Null<TokenTree>;

	public function new(extractData:ExtractMethodData, context:RefactorContext, neededIdentifiers:Array<Identifier>, lastReturnToken:TokenTree) {
		super(extractData, context, neededIdentifiers);

		this.lastReturnToken = lastReturnToken;
	}

	public function makeCallSite():String {
		final callParams:String = neededIdentifiers.map(i -> i.name).join(", ");
		return 'return ${extractData.newMethodName}($callParams);\n';
	}

	public function makeReturnTypeHint():Promise<String> {
		if (lastReturnToken == null) {
			return Promise.resolve("");
		}
		final pos = lastReturnToken.getPos();
		return TypingHelper.findTypeWithTyper(context, context.what.fileName, pos.max - 2).then(function(typeHint):Promise<String> {
			if (typeHint == null) {
				return Promise.resolve("");
			}
			return Promise.resolve(":" + typeHint.printTypeHint());
		});
	}

	public function makeBody():String {
		final selectedSnippet = RefactorHelper.extractText(context.converter, extractData.content, extractData.startToken.pos.min,
			extractData.endToken.pos.max);
		return " {\n" + selectedSnippet + "\n}\n";
	}
}
