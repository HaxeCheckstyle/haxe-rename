package refactor.discover;

import refactor.rename.RenameHelper.TypeHintType;

class TypeList implements ITypeList {
	public final types:Map<String, Type>;

	public function new() {
		types = new Map<String, Type>();
	}

	public function addType(type:Type) {
		types.set(type.fullModuleName, type);
	}

	public function findTypeName(name:String):Array<Type> {
		return Lambda.filter({iterator: types.iterator}, (t) -> t.name.name == name);
	}

	public function makeTypeHintType(name:String):Null<TypeHintType> {
		if (types.exists(name)) {
			return KnownType(types.get(name), []);
		}
		return null;
	}

	public function removeFile(fileName:String) {
		var fullNames:Array<String> = [];
		for (key => type in types) {
			if (type.name.pos.fileName == fileName) {
				fullNames.push(type.fullModuleName);
			}
		}
		for (name in fullNames) {
			types.remove(name);
		}
	}

	public function clear() {
		types.clear();
	}
}
