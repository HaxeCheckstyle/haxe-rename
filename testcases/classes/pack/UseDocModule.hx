package classes.pack;

import classes.DocModule;

class UseDocModule {
	function new() {
		new NotDocModule();
	}

	function factory(name) {
		return NotDocModule.new;
	}
}
