package classes.pack;

import classes.DocModule;

class UseDocModule {
	function new() {
		new NotDocModule();
	}

	function factory(name) {
		return NotDocModule.new;
	}

	function doSommething(name) {
		new NotDocModule().doSomething();
		this.getNotDocModule().doSomething();
	}

	function getNotDocModule() {
		return new NotDocModule();
	}
}
