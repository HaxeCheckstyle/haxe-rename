package classes;

class Childs {
	function new(name:String) {}

	static function childType(type:EnumType):Childs {
		return switch (type) {
			case Parent(_):
				new Childs("parent");
			case Childs(_):
				new Childs("child");
		}
	}
}
