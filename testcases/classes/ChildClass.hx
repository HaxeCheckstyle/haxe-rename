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
		return identifier.defineType.findAllIdentifiers(function(ident:MyIdentifier) {
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
}

typedef ListOfChilds = Array<ChildClass>;
