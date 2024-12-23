package testcases.methods;

class FunctionProcessor {
	function process(callback:Int->String->Bool) {
		var value = 42;
		var text = "test";
		if (callback(value, text)) {
			trace('Success: $value, $text');
		}
	}
}
