package refactor;

import refactor.TypingHelper.TypeHintType;

interface ITyper {
	function resolveType(fileName:String, pos:Int):Promise<Null<TypeHintType>>;
}
