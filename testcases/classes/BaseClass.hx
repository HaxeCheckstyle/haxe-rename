package classes;

class BaseClass {
	var data:Array<String>;

	public function new() {
		data = [];
	}

	public function doSomething(data:Array<String>) {
		this.data = this.data.concat(data);
	}

	public function doSomething3(d:Array<String>) {
		data.concat(d);
	}
}
