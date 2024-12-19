package classes;

using classes.ChildHelper;
using classes.pack.SecondChildHelper;

class StaticUsing {
	static function main() {
		var child:ChildClass = new ChildClass();

		child.sum();

		Sys.println(child.print());

		var text:String;
		var texts:{text:Array<classes.ChildClass>} = {
			text: []
		};
		var index = 0;

		text.printText();

		Sys.println(new ChildClass().print());
		child.print().toString();
		texts.text[index].print();
		(Context.printFunc : PrintFunc).print();
	}

	function hasIdent<T, O:{}
		& T>(name:T):T {
		return null;
	}
}

/**
 * Context class
 */
class Context {
	public static var printFunc:PrintFunc;
}

typedef PrintFunc = {print:() -> Void}
