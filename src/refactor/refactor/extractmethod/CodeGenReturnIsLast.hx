package refactor.refactor.extractmethod;

import refactor.discover.Identifier;

class CodeGenReturnIsLast extends CodeGenBase {
	public function new(extractData:ExtractMethodData, context:RefactorContext, neededIdentifiers:Array<Identifier>) {
		super(extractData, context, neededIdentifiers);
	}

	public function makeCallSite():String {
		final callParams:String = neededIdentifiers.map(i -> i.name).join(", ");
		final call = '${extractData.newMethodName}($callParams)';

		return 'return $call;\n';
	}

	public function makeReturnTypeHint():Promise<String> {
		return parentTypeHint().then(function(typeHint):Promise<String> {
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