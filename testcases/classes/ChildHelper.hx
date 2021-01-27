package classes;

class ChildHelper {
	public static function sum(child:ChildClass) {}

	public static function add(child1:ChildClass, child2:ChildClass) {}

	public static function parent(type:EnumType):BaseClass {
		return switch (type) {
			case Parent(parent):
				parent;
			case Childs(child):
				child.parent;
		}
	}
}
