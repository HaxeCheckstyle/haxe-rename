package interfaces;

import interfaces.pack.sub.IAnotherInterface;

class ChildChildClass extends ChildClass implements IAnotherInterface {
	override public function doSomethingElse() {
		doNothing();
	}

	public function doNothing() {}

	public var someProp(get, set):String;

	function set_someProp(value:String):String {
		return value;
	}

	function get_someProp():String {
		return "";
	}
}
