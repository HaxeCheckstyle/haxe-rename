package classes.pack;

import classes.*;
import classes.ChildClass;

class UseChild {
	var list:ListOfChilds;

	function main(child:ChildClass) {
		list.push(child);
	}

	function accessParent(child:ChildClass) {
		child.parent.doSomething([]);
	}

	function iterate() {
		var list:Array<ChildClass> = [];
		for (item in list) {
			item.parent.doSomething([""]);
		}
	}

	function nullIdent() {
		var child:Null<ChildClass> = list.pop();
		child.parent.doSomething([""]);
	}

	function struct(child:ChildClass):Any {
		return {
			id: 1,
			parent: child.parent
		};
	}

	#if php
	function accessParentExt(child:ChildClass) {
		child.parent.doSomething([]);
	}
	#end

	function helperSum() {
		ChildHelper.sum(list[0]);
	}

	function json(json:JsonClass) {}

	private function doSwitch(action:String):JsonClass {
		return switch (action) {
			case "test":
				new JsonClass(1, "test", 2);
			default:
				null;
		}
	}

	function typeCheckChildClass(child:Any) {
		if ((child is ChildClass)) {
			trace("yes");
		}
	}
}

class TypedChild<T:ChildClass> {
	var memebers:Array<{sprite:ChildClass, originalX:Float, originalY:Float}> = null;
}
