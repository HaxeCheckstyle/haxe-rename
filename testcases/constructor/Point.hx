class Point extends Base {
	var y:Int;

	public function new(x:Int, y:Int, z:Int, text:String) {
		super(x);
		this.y = y;
	}

	public function toString() {
		return "Point(" + x + "," + y + ")";
	}
}

class Base {
	var x:Int;

	public function new(x:Int) {}
}

class Main {
	public function new(x:Int) {}
}
