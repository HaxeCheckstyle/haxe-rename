package modulelevelstatics.pack;

import modulelevelstatics.StaticFuncs;

class Command {
	function action(text:String) {
		someFunction(text);
		someVar = text;
	}
}
