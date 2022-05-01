package refactor;

class PackageTest extends TestBase {
	function setupClass() {
		setupTestSources(["testcases/packages"]);
	}

	public function testRenameTypesModul(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/packages/Main.hx", "packages.sub.Types.Type3", 53, 73),
			makeReplaceTestEdit("testcases/packages/Main.hx", "packages.sub.Types", 82, 96),
			makeReplaceTestEdit("testcases/packages/Main.hx", "packages.sub.Type1", 289, 303),
			makeMoveTestEdit("testcases/packages/Types.hx", "testcases/packages/sub/Types.hx"),
			makeReplaceTestEdit("testcases/packages/Types.hx", "packages.sub", 8, 16),

		];
		refactorAndCheck({fileName: "testcases/packages/Types.hx", toName: "packages.sub", pos: 12}, edits, async);
	}

	public function testRenameMoreTypesModul(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/packages/Main.hx", "packages.sub.MoreTypes", 26, 44),
			makeMoveTestEdit("testcases/packages/MoreTypes.hx", "testcases/packages/sub/MoreTypes.hx"),
			makeReplaceTestEdit("testcases/packages/MoreTypes.hx", "packages.sub", 8, 16),
		];
		refactorAndCheck({fileName: "testcases/packages/MoreTypes.hx", toName: "packages.sub", pos: 12}, edits, async);
	}

	public function testRenameOtherTypesModul(async:Async) {
		var edits:Array<TestEdit> = [
			makeInsertTestEdit("testcases/packages/Main.hx", "import packages.sub.OtherTypes;\n", 19),
			makeReplaceTestEdit("testcases/packages/Main.hx", "packages.sub.OtherTypes", 202, 221),
			makeReplaceTestEdit("testcases/packages/Main.hx", "packages.sub.OtherTypes.OtherTypeA", 240, 270),
			makeMoveTestEdit("testcases/packages/OtherTypes.hx", "testcases/packages/sub/OtherTypes.hx"),
			makeReplaceTestEdit("testcases/packages/OtherTypes.hx", "packages.sub", 8, 16),
		];
		refactorAndCheck({fileName: "testcases/packages/OtherTypes.hx", toName: "packages.sub", pos: 12}, edits, async);
	}

	public function testRenameHelperTypesModul(async:Async) {
		var edits:Array<TestEdit> = [
			makeMoveTestEdit("testcases/packages/HelperTypes.hx", "testcases/packages/sub/HelperTypes.hx"),
			makeReplaceTestEdit("testcases/packages/HelperTypes.hx", "packages.sub", 8, 16),
			makeReplaceTestEdit("testcases/packages/import.hx", "packages.sub.HelperTypes", 26, 46),
		];
		refactorAndCheck({fileName: "testcases/packages/HelperTypes.hx", toName: "packages.sub", pos: 12}, edits, async);
	}
}
