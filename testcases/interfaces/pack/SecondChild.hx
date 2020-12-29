package interfaces.pack;

import interfaces.BaseClass as Base;
import interfaces.ChildClass;

class SecondChild extends Base {
	override public function doSomething() {
		super.doSomethingElse();
	}

	function parameterOfChildClass(child:ChildClass) {
		child.doSomething();
		child.doSomethingElse();
	}

	function localVarOfChildClass() {
		var child:ChildClass = new ChildClass();
		child.doSomething();
		child.doSomethingElse();
	}
}
