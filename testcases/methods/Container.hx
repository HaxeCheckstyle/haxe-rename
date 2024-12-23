package testcases.methods;

class Container {
	function process<T>(items:Array<T>, converter:T->String) {
		var result = new Array<String>();
		for (item in items) {
			var converted = converter(item);
			result.push('[${converted}]');
		}
		trace(result);
	}
}
