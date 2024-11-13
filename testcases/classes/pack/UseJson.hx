package classes.pack;

import classes.JsonClass;

class UseJson {
	private function doSwitch(action:String):Any {
		return switch (action) {
			case "test":
				new JsonClass(1, "test", 2);
			default:
				null;
		}
	}
}
