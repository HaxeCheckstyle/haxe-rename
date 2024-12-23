package testcases.methods;

class ArrayHandler {
	function handle() {
		var numbers = [1, 2, 3, 4, 5];
		var sum = 0;
		for (n in numbers) {
			sum += n;
		}
		trace(sum);
	}
}
