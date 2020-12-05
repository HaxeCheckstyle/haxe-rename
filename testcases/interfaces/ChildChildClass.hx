package interfaces;

import interfaces.pack.sub.IAnotherInterface;

class ChildChildClass extends ChildClass implements IAnotherInterface {
	override public function doSomethingElse() {
		doNothing();
	}

	public function doNothing() {}
}
