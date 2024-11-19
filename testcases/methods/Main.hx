package testcases.methods;

class Main {
	public function noReturns() {
		trace("hello 1");
		trace("hello 2");
		trace("hello 3");
		trace("hello 4");
	}

	public static function noReturnsStatic() {
		trace("hello 1");
		trace("hello 2");
		trace("hello 3");
		trace("hello 4");
	}

	public function emptyReturns(cond1:Bool, cond2:Bool) {
		if (cond1) {
			return;
		}
		if (cond2) {
			return;
		}
		trace("hello 1");
		trace("hello 2");
		trace("hello 3");
		trace("hello 4");
	}
}
