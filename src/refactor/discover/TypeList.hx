package refactor.discover;

class TypeList {
	public final types:Array<Type> = [];

	public function new() {}

	public function addType(type:Type) {
		types.push(type);
	}

	public function findTypeName(name:String):Array<Type> {
		return types.filter((t) -> t.name.name == name);
	}
}
