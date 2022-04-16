package refactor;

import refactor.rename.RenameHelper.TypeHintType;

interface ITypeList {
	function makeTypeHintType(name:String):TypeHintType;
}
