package interfaces;

class BaseClass implements IInterface {
	public var someVar:String;

	public function doSomething() {}

	public function doSomethingElse() {
		doSomething();
	}
}
