package refactor.rename;

class RenameEnumTest extends RenameTestBase {
	function setupClass() {
		setupTestSources(["testcases/enums"]);
	}

	public function testRenameEnumType(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/enums/Identifier.hx", "IdentType", 52, 66),
			makeMoveTestEdit("testcases/enums/IdentifierType.hx", "testcases/enums/IdentType.hx"),
			makeReplaceTestEdit("testcases/enums/IdentifierType.hx", "IdentType", 21, 35),
			makeReplaceTestEdit("testcases/enums/Main.hx", "IdentType", 90, 104),
			makeReplaceTestEdit("testcases/enums/Main.hx", "IdentType", 480, 494),
			makeReplaceTestEdit("testcases/enums/Main.hx", "IdentType", 2012, 2026),
		];
		checkRename({fileName: "testcases/enums/IdentifierType.hx", toName: "IdentType", pos: 30}, edits, async);
	}

	public function testRenameScopedLocal(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/enums/IdentifierType.hx", "LocalScopeVar", 69, 80),
			makeReplaceTestEdit("testcases/enums/Main.hx", "LocalScopeVar", 235, 246),
			makeReplaceTestEdit("testcases/enums/Main.hx", "LocalScopeVar", 1133, 1144),
			makeReplaceTestEdit("testcases/enums/Main.hx", "LocalScopeVar", 1427, 1438),
			makeReplaceTestEdit("testcases/enums/Main.hx", "LocalScopeVar", 1734, 1745),
			makeReplaceTestEdit("testcases/enums/Main.hx", "LocalScopeVar", 1869, 1880),
		];
		checkRename({fileName: "testcases/enums/IdentifierType.hx", toName: "LocalScopeVar", pos: 77}, edits, async);
	}

	public function testRenameCall(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/enums/IdentifierType.hx", "FunctionCall", 53, 57),
			makeReplaceTestEdit("testcases/enums/Main.hx", "FunctionCall", 178, 182),
			makeReplaceTestEdit("testcases/enums/Main.hx", "FunctionCall", 211, 215),
		];
		checkRename({fileName: "testcases/enums/IdentifierType.hx", toName: "FunctionCall", pos: 55}, edits, async);
	}

	public function testRenameScopedGlobal(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/enums/IdentifierType.hx", "GlobalScopeVar", 97, 109),
			makeReplaceTestEdit("testcases/enums/Main.hx", "GlobalScopeVar", 367, 379),
			makeReplaceTestEdit("testcases/enums/Main.hx", "GlobalScopeVar", 1197, 1209),
			makeReplaceTestEdit("testcases/enums/Main.hx", "GlobalScopeVar", 1491, 1503),
			makeReplaceTestEdit("testcases/enums/Main.hx", "GlobalScopeVar", 1798, 1810),
			makeReplaceTestEdit("testcases/enums/Main.hx", "GlobalScopeVar", 1904, 1916),
		];
		checkRename({fileName: "testcases/enums/IdentifierType.hx", toName: "GlobalScopeVar", pos: 103}, edits, async);
	}
}
