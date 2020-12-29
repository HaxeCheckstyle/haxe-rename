package refactor.discover;

class TypeList {
	public var types:Array<Type>;

	public function new() {
		types = [];
	}

	public function addType(type:Type) {
		types.push(type);
	}

	public function findTypeName(name:String):Array<Type> {
		return types.filter((t) -> t.name.name == name);
	}
}
