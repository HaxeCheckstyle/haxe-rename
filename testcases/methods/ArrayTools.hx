package testcases.methods;

class ArrayTools {
	public static function processItems<T>(arr:Array<T>, fn:T->Bool) {
		var results = new Array<T>();
		for (item in arr) {
			if (fn(item))
				results.push(item);
		}
		return results;
	}
}
