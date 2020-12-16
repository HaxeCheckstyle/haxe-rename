package enums;

import refactor.discover.IdentifierPos;

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

	function callOrAccess(types:Array<IdentifierType>):IdentifierPos {
		var pos:IdentifierPos = {
			fileName: "testcases/enums/Main.hx",
			start: 100,
			end: 200
		};
		return pos;
	}

	function testCopy(type:IdentifierTypeCopy) {
		switch (type) {
			case PackageName:
				new PackageName();
			case Call | Access:
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
}
