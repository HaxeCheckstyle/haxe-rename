package classes.pack;

import classes.ChildClass.*;
import classes.ChildClass;

class UseChild {
	var list:ListOfChilds;

	function main(child:ChildClass) {
		list.push(child);
	}
}
