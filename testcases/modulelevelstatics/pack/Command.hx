package modulelevelstatics.pack;

import modulelevelstatics.StaticFuncs;

using modulelevelstatics.StaticFuncs;

class Command {
	function action(text:String) {
		someFunction(text);
		someVar = text;
		text.someFunction();
	}
}
