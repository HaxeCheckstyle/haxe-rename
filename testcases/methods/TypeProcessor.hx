package testcases.methods;

class TypeProcessor {
	function process<T:Base, U:IComparable>(item:T, compare:U) {
		var result = item.process();
		if (compare.compareTo(result) > 0) {
			item.update(compare.getValue());
		}
	}
}

interface Base {
	function process():Float;
	function update(value:Float):Void;
}

interface IComparable {
	function compareTo(value:Float):Float;
	function getValue():Float;
}
