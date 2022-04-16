package refactor.discover;

import refactor.rename.RenameHelper.TypeHintType;

class TypeList implements ITypeList {
	public final types:Array<Type> = [];

	public function new() {}

	public function addType(type:Type) {
		types.push(type);
	}

	public function findTypeName(name:String):Array<Type> {
		return types.filter((t) -> t.name.name == name);
	}

	public function makeTypeHintType(name:String):Null<TypeHintType> {
		for (type in types) {
			if (type.getFullModulName() == name) {
				return KnownType(type, []);
			}
		};
		return null;
	}
}
