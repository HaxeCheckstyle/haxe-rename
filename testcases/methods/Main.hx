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

	public function calculateTotal(items:Array<Item>):Float {
		var total:Float = 0;

		// Selected code block to extract
		for (item in items) {
			var price = item.price;
			var quantity = item.quantity;
			total += price * quantity;
		}

		return total;
	}

	public function processUser(user:User) {
		var name:String = user.name;
		var age:Int = user.age;

		// Selected code block to extract
		var greeting = "Hello, " + name;
		if (age < 18) {
			greeting += " (minor)";
		}
		trace(greeting);

		// ...
	}

	public function calculateTotal2(items:Array<Item>):Float {
		var total:Float = 0;

		// Selected code block to extract
		for (item in items) {
			var price = item.price;
			var quantity = item.quantity;
			if (quantity < 0) {
				return total;
			}
			total += price * quantity;
		}

		return total;
	}
}

typedef Item = {
	var price:Float;
	var quantity:Float;
}

typedef User = {
	var name:String;
	var age:Int;
}
