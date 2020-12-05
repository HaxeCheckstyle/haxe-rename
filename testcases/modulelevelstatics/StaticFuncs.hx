package modulelevelstatics;

class StaticFuncs {
	static function main() {
		someFunction("hello");
		someVar = "newvalue";
	}
}

var someVar:String = "defaultvalue";

function someFunction(text:String) {
	Sys.println(text);
}
