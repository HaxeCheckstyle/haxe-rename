package classes;

class ChildClass extends BaseClass {
	public var parent:BaseClass;

	public function new() {
		super();
	}

	override function doSomething(data:Array<String>) {
		super.doSomething(data);
	}

	function findIdent(identifier:MyIdentifier, scopeStart:Int):Array<MyIdentifier> {
		return identifier.defineType.findAllIdentifiers(function(ident:MyIdentifier):Bool {
			if (ident.pos.start < scopeStart) {
				return false;
			}
			if (ident.name == identifier.name) {
				return true;
			}
			if (ident.name.startsWith(identifierDot)) {
				return true;
			}
			return false;
		});
	}

	function hasIdent(name:String):Bool {
		var list:Array<MyIdentifier> = [];

		for (id in list) {
			if (id.name == name) {
				return true;
			}
		}

		for (i in 0...list.length) {
			if (list[i].name == name) {
				return true;
			}
		}
		return false;
	}
}

typedef ListOfChilds = Array<ChildClass>;
