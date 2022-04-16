package refactor;

import refactor.rename.RenameHelper.TypeHintType;

interface ITyper {
	function resolveType(fileName:String, pos:Int):Promise<Null<TypeHintType>>;
}
