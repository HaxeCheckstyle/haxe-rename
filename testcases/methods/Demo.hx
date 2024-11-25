package testcases.methods;

class Demo {
	function doSomething(cond:Bool, val:Int, text:Null<String>):Float {
		if (cond && text == null) {
			return 0.0;
		}
		doNothing();
		trace("I'm here");
		doNothing();
		trace("yep, still here");
		doNothing();
		return switch [cond, val] {
			case [true, 0]:
				std.Math.random() * val;
			case [true, _]:
				val + val;
			case [false, 10]:
				Std.parseFloat(text);
			case [_, _]:
				std.Math.NEGATIVE_INFINITY;
		}
	}

	function doNothing() {}
}
