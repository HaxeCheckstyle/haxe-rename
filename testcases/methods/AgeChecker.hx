package testcases.methods;

class AgeChecker {
	function check() {
		var age = 15;
		var message = "";
		if (age < 18) {
			message = "Minor";
		} else {
			message = "Adult";
		}
		trace(message);
	}
}
