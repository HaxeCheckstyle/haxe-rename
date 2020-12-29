package classes.pack;

import classes.ChildClass.*;
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
}
