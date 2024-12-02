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

	public function doSomething4(d:Array<String>) {
		var data = [];
		data.concat(d);
	}

	public function doSomething5(d:Array<String>) {
		data = [];
		this.data = [];
	}

	public function doSomething6(d:Array<String>) {
		switch (val) {
			case Case1(data):
			default:
		}
		return true;
	}
}
