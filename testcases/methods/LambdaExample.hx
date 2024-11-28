package testcases.methods;

class LambdaExample {
	private var multiplier = 2;

	function process() {
		var numbers = [1, 2, 3];
		var result = numbers.map(n -> {
			var temp = n * multiplier;
			return temp + this.multiplier;
		});
	}

	function processCallback() {
		processItem((n, m) -> {
			var temp = n * m;
			return temp + m;
		});
	}

	function processCallbackFunc() {
		processItem(function(n, m) {
			var temp = n * m;
			return temp + m;
		});
	}

	function processItem(cb:ProcessCallback) {
		var numbers = [1, 2, 3];
		var result = numbers.map(n -> cb(n, multiplier));
	}

	function processSimple() {
		var numbers = [1, 2, 3];
		var result = numbers.map(n -> n * n);
	}
}

typedef ProcessCallback = (n:Int, m:Int) -> Int;
