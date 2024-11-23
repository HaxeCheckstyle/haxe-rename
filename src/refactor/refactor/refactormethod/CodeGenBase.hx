package refactor.refactor.refactormethod;

import refactor.TypingHelper.TypeHintType;
import refactor.discover.Identifier;
import refactor.refactor.ExtractMethod.ExtractMethodData;

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
}
