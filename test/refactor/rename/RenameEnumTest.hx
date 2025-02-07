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
			makeReplaceTestEdit("testcases/enums/Main.hx", "IdentType", 2202, 2216),
			makeReplaceTestEdit("testcases/enums/Main.hx", "IdentType", 2239, 2253),
			makeReplaceTestEdit("testcases/enums/Main.hx", "IdentType", 2269, 2283),
			makeReplaceTestEdit("testcases/enums/Main.hx", "IdentType", 2301, 2315),
			makeReplaceTestEdit("testcases/enums/Main.hx", "IdentType", 2380, 2394),
			makeReplaceTestEdit("testcases/enums/Main.hx", "IdentType", 2428, 2442),
			makeReplaceTestEdit("testcases/enums/Main.hx", "IdentType", 2481, 2495),
			makeReplaceTestEdit("testcases/enums/Main.hx", "IdentType", 2531, 2545),
			makeReplaceTestEdit("testcases/enums/Main.hx", "IdentType", 3464, 3478),
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
			makeReplaceTestEdit("testcases/enums/Main.hx", "LocalScopeVar", 2316, 2327),
			makeReplaceTestEdit("testcases/enums/Main.hx", "LocalScopeVar", 2496, 2507),
			makeReplaceTestEdit("testcases/enums/Main.hx", "LocalScopeVar", 3610, 3621),
		];
		checkRename({fileName: "testcases/enums/IdentifierType.hx", toName: "LocalScopeVar", pos: 77}, edits, async);
	}

	public function testRenameCall(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/enums/IdentifierType.hx", "FunctionCall", 53, 57),
			makeReplaceTestEdit("testcases/enums/Main.hx", "FunctionCall", 178, 182),
			makeReplaceTestEdit("testcases/enums/Main.hx", "FunctionCall", 211, 215),
			makeReplaceTestEdit("testcases/enums/Main.hx", "FunctionCall", 1101, 1105),
			makeReplaceTestEdit("testcases/enums/Main.hx", "FunctionCall", 1395, 1399),
			makeReplaceTestEdit("testcases/enums/Main.hx", "FunctionCall", 1702, 1706),
			makeReplaceTestEdit("testcases/enums/Main.hx", "FunctionCall", 2254, 2258),
			makeReplaceTestEdit("testcases/enums/Main.hx", "FunctionCall", 3553, 3557),
			makeReplaceTestEdit("testcases/enums/Main.hx", "FunctionCall", 3586, 3590),
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
			makeReplaceTestEdit("testcases/enums/Main.hx", "GlobalScopeVar", 2395, 2407),
			makeReplaceTestEdit("testcases/enums/Main.hx", "GlobalScopeVar", 2546, 2558),
			makeReplaceTestEdit("testcases/enums/Main.hx", "GlobalScopeVar", 3742, 3754),
		];
		checkRename({fileName: "testcases/enums/IdentifierType.hx", toName: "GlobalScopeVar", pos: 103}, edits, async);
	}

	public function testRenameBedroom1(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/enums/Main.hx", "MasterBedroom", 2740, 2748),
			makeReplaceTestEdit("testcases/enums/Main.hx", "MasterBedroom", 3137, 3145),
			makeReplaceTestEdit("testcases/enums/Main.hx", "MasterBedroom", 3408, 3416),
			makeReplaceTestEdit("testcases/enums/SmokeDetector.hx", "MasterBedroom", 127, 135),
		];
		checkRename({fileName: "testcases/enums/SmokeDetector.hx", toName: "MasterBedroom", pos: 132}, edits, async);
	}
}
