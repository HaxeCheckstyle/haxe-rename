package enums;

import haxe.xml.Access;

class Main {
	function test(type:IdentifierType) {
		switch (type) {
			case PackageName:
				new PackageName();
			case Call | Access:
				callOrAccess([Call, Access]);
			case ScopedLocal(scopeEnd):
				new ScopedLocal(scopeEnd);
			case StringConst:
			default:
		}

		switch (type) {
			case StringConst | ScopedGlobal(_):
				callOrAccess([StringConst, Access]);
			default:
		}
	}

	function callOrAccess(types:Array<IdentifierType>) {}
}
