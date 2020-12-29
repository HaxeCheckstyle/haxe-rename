package classes;

class ChildClass extends BaseClass {
	public var parent:BaseClass;

	public function new() {
		super();
	}

	override function doSomething(data:Array<String>) {
		super.doSomething(data);
	}
}

typedef ListOfChilds = Array<ChildClass>;
