package refactor.refactor.refactormethod;

import refactor.discover.Identifier;
import refactor.refactor.ExtractMethod.ExtractMethodData;

class CodeGenAsExpression extends CodeGenBase {
	public function new(extractData:ExtractMethodData, context:RefactorContext, neededIdentifiers:Array<Identifier>) {
		super(extractData, context, neededIdentifiers);
	}

	public function makeCallSite():String {
		final callParams:String = neededIdentifiers.map(i -> i.name).join(", ");
		if (extractData.endToken.matches(Semicolon)) {
			return '${extractData.newMethodName}($callParams);\n';
		}
		return '${extractData.newMethodName}($callParams)';
	}

	public function makeReturnTypeHint():Promise<String> {
		var parent = extractData.startToken.parent;
		switch (parent.tok) {
			case Binop(OpAssign) | Binop(OpAssignOp(_)):
				parent = parent.parent;
				return TypingHelper.findTypeWithTyper(context, context.what.fileName, parent.pos.max - 1).then(function(typeHint):Promise<String> {
					if (typeHint == null) {
						return Promise.resolve("");
					}
					return Promise.resolve(":" + typeHint.printTypeHint());
				});
			default:
		}
		return TypingHelper.findTypeWithTyper(context, context.what.fileName, extractData.endToken.pos.max - 1).then(function(typeHint):Promise<String> {
			if (typeHint == null) {
				return Promise.resolve("");
			}
			return Promise.resolve(":" + typeHint.printTypeHint());
		});
	}

	public function makeBody():String {
		final selectedSnippet = RefactorHelper.extractText(context.converter, extractData.content, extractData.startToken.pos.min,
			extractData.endToken.pos.max);
		return " {\n" + "return " + selectedSnippet + "\n}\n";
	}
}
