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

	function list(items:Array<Identifier>) {
		for (item in items) {
			switch (item.type) {
				case PackageName:
				case Call:
				case Access:
				case ScopedLocal(scopeEnd):
					new ScopedLocal(scopeEnd);
				case ScopedGlobal(scopeEnd):
				case StringConst:
			}
		}
	}

	function listChilds(identifier:Identifier) {
		for (item in identifier.children) {
			switch (item.type) {
				case PackageName:
				case Call:
				case Access:
				case ScopedLocal(scopeEnd):
					new ScopedLocal(scopeEnd);
				case ScopedGlobal(scopeEnd):
				case StringConst:
			}
		}
	}

	function listParentChilds(identifier:Identifier) {
		for (item in identifier.parent.children) {
			switch (item.type) {
				case PackageName:
				case Call:
				case Access:
				case ScopedLocal(scopeEnd):
					new ScopedLocal(scopeEnd);
				case ScopedGlobal(scopeEnd):
				case StringConst:
			}
		}
		printType("", ScopedLocal(100));
		printType("", ScopedGlobal(100));
		printType("", new ScopedLocal(100).type);
	}

	function printType(prefix:String, type:IdentifierType) {
		Sys.println(prefix + type);
	}
}
