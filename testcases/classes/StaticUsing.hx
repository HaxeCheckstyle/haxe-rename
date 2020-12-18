package classes;

using classes.ChildHelper;
using classes.pack.SecondChildHelper;

class StaticUsing {
	static function main() {
		var child:ChildClass = new ChildClass();

		child.sum();

		Sys.println(child.print());

		var text:String;

		text.printText();

		Sys.println(new ChildClass().print());
	}
}
