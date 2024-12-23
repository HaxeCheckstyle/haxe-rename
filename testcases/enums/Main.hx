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

	function listParentChildsFullName(identifier:Identifier) {
		for (item in identifier.parent.children) {
			switch (item.type) {
				case IdentifierType.PackageName:
				case IdentifierType.Call:
				case IdentifierType.Access:
				case IdentifierType.ScopedLocal(scopeEnd):
					new ScopedLocal(scopeEnd);
				case IdentifierType.ScopedGlobal(scopeEnd):
				case IdentifierType.StringConst:
			}
		}
		printType("", IdentifierType.ScopedLocal(100));
		printType("", IdentifierType.ScopedGlobal(100));
		printType("", new ScopedLocal(100).type);
	}

	function alarm(detector:SmokeDetector) {
		switch (detector) {
			case Staircase:
				trace("alarm in staircase!!");
			case Bedroom1:
				trace("alarm in bedroom 1!!");
			case Hallway1:
				trace("alarm in hallway 1!!");
			case Office:
				trace("alarm in office!!");
			case LivingRoom:
				trace("alarm in living room!!");
		}
		trace(detector.available());
	}

	function alarm2(detector:SmokeDetector) {
		switch (detector) {
			case SmokeDetector.Staircase:
				trace("alarm in staircase!!");
			case SmokeDetector.Bedroom1:
				trace("alarm in bedroom 1!!");
			case SmokeDetector.Hallway1:
				trace("alarm in hallway 1!!");
			case SmokeDetector.Office:
				trace("alarm in office!!");
			case SmokeDetector.LivingRoom:
				trace("alarm in living room!!");
		}
		trace(SmokeDetector.Bedroom1.available());
	}

	function testNull(type:Null<IdentifierType>) {
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
}
