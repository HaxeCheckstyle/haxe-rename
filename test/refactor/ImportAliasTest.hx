package refactor;

import refactor.TestEditableDocument.TestEdit;

class ImportAliasTest extends TestBase {
	function setupClass() {
		setupData(["testcases/importalias"]);
	}

	public function testRenameImportHxAlias() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/importalias/pack/Child.hx", "typeof", 89, 97),
			makeReplaceTestEdit("testcases/importalias/import.hx", "typeof", 45, 53),
			makeReplaceTestEdit("testcases/importalias/Main.hx", "typeof", 121, 129),
		];
		refactorAndCheck({fileName: "testcases/importalias/import.hx", toName: "typeof", pos: 47}, edits);
	}

	public function testRenameMainAlias() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/importalias/Main.hx", "typeof", 45, 57),
			makeReplaceTestEdit("testcases/importalias/Main.hx", "typeof", 161, 173),
		];
		refactorAndCheck({fileName: "testcases/importalias/Main.hx", toName: "typeof", pos: 50}, edits);
	}
}
