package refactor.rename;

class RenamePackageTest extends RenameTestBase {
	function setupClass() {
		setupTestSources(["testcases/packages"]);
	}

	public function testRenameTypesModul(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/packages/Main.hx", "packages.sub.Types.Type3", 75, 95),
			makeReplaceTestEdit("testcases/packages/Main.hx", "packages.sub.Types", 104, 118),
			makeReplaceTestEdit("testcases/packages/Main.hx", "packages.sub.Type1", 311, 325),
			makeMoveTestEdit("testcases/packages/Types.hx", "testcases/packages/sub/Types.hx"),
			makeReplaceTestEdit("testcases/packages/Types.hx", "packages.sub", 8, 16),

		];
		checkRename({fileName: "testcases/packages/Types.hx", toName: "packages.sub", pos: 12}, edits, async);
	}

	public function testRenameMoreTypesModul(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/packages/Main.hx", "packages.sub.MoreTypes", 48, 66),
			makeMoveTestEdit("testcases/packages/MoreTypes.hx", "testcases/packages/sub/MoreTypes.hx"),
			makeReplaceTestEdit("testcases/packages/MoreTypes.hx", "packages.sub", 8, 16),
		];
		checkRename({fileName: "testcases/packages/MoreTypes.hx", toName: "packages.sub", pos: 12}, edits, async);
	}

	public function testRenameOtherTypesModul(async:Async) {
		var edits:Array<TestEdit> = [
			makeInsertTestEdit("testcases/packages/Main.hx", "import packages.sub.OtherTypes;\n", 19),
			makeReplaceTestEdit("testcases/packages/Main.hx", "packages.sub.OtherTypes", 224, 243),
			makeReplaceTestEdit("testcases/packages/Main.hx", "packages.sub.OtherTypes.OtherTypeA", 262, 292),
			makeMoveTestEdit("testcases/packages/OtherTypes.hx", "testcases/packages/sub/OtherTypes.hx"),
			makeReplaceTestEdit("testcases/packages/OtherTypes.hx", "packages.sub", 8, 16),
		];
		checkRename({fileName: "testcases/packages/OtherTypes.hx", toName: "packages.sub", pos: 12}, edits, async);
	}

	public function testRenameHelperTypesModul(async:Async) {
		var edits:Array<TestEdit> = [
			makeMoveTestEdit("testcases/packages/HelperTypes.hx", "testcases/packages/sub/HelperTypes.hx"),
			makeReplaceTestEdit("testcases/packages/HelperTypes.hx", "packages.sub", 8, 16),
			makeReplaceTestEdit("testcases/packages/import.hx", "packages.sub.HelperTypes", 26, 46),
		];
		checkRename({fileName: "testcases/packages/HelperTypes.hx", toName: "packages.sub", pos: 12}, edits, async);
	}

	public function testRenameHelperECTypesModul(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/packages/Main.hx", "packages.sub.ECTypeA", 26, 39),
			makeMoveTestEdit("testcases/packages/kages/ECTypes.hx", "testcases/packages/packages/sub/ECTypes.hx"),
			makeReplaceTestEdit("testcases/packages/kages/ECTypes.hx", "packages.sub", 8, 13),
		];
		checkRename({fileName: "testcases/packages/kages/ECTypes.hx", toName: "packages.sub", pos: 10}, edits, async);
	}
}
