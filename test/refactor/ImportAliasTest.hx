package refactor;

class ImportAliasTest extends TestBase {
	function setupClass() {
		setupTestSources(["testcases/importalias"]);
	}

	public function testRenameImportHxAlias(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/importalias/Main.hx", "typeof", 121, 129),
			makeReplaceTestEdit("testcases/importalias/import.hx", "typeof", 45, 53),
			makeReplaceTestEdit("testcases/importalias/pack/Child.hx", "typeof", 89, 97),
		];
		refactorAndCheck({fileName: "testcases/importalias/import.hx", toName: "typeof", pos: 47}, edits, async);
	}

	public function testRenameMainAlias(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/importalias/Main.hx", "typeof", 45, 57),
			makeReplaceTestEdit("testcases/importalias/Main.hx", "typeof", 161, 173),
		];
		refactorAndCheck({fileName: "testcases/importalias/Main.hx", toName: "typeof", pos: 50}, edits, async);
	}
}
