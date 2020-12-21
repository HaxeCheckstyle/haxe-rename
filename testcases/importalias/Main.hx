package importalias;

import Std.isOfType as isOfTypeMain;

class Main {
	public function new(value:Any) {
		Sys.println(isOfType(value, String));
		Sys.println(isOfTypeMain(value, String));
	}
}
