package testcases.methods;

class NameProcessor {
	function process() {
		var names = ["John", "Jane", "Bob"];
		var upperNames = [];
		for (name in names) {
			upperNames.push(name.toUpperCase());
		}
		trace(upperNames);
	}
}
