package interfaces.pack.sub;

class AnotherClass implements IAnotherInterface {
	public var someProp(get, set):String;

	public function doSomething() {}

	public function doSomethingElse() {}

	public function doNothing() {}

	function set_someProp(value:String):String {
		return value;
	}

	function get_someProp():String {
		return "";
	}
}
