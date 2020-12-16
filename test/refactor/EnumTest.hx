package refactor;

import refactor.TestEditableDocument.TestEdit;

class EnumTest extends TestBase {
	function setupClass() {
		setupData(["testcases/enums"]);
	}

	public function testRenameEnumType() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/enums/Main.hx", "IdentType", 90, 104),
			makeReplaceTestEdit("testcases/enums/Main.hx", "IdentType", 480, 494),
			makeMoveTestEdit("testcases/enums/IdentifierType.hx", "testcases/enums/IdentType.hx"),
			makeReplaceTestEdit("testcases/enums/IdentifierType.hx", "IdentType", 21, 35),
		];
		refactorAndCheck({fileName: "testcases/enums/IdentifierType.hx", toName: "IdentType", pos: 30}, edits);
	}

	public function testRenameScopedLocal() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/enums/Main.hx", "LocalScopeVar", 235, 246),
			makeReplaceTestEdit("testcases/enums/IdentifierType.hx", "LocalScopeVar", 69, 80),
		];
		refactorAndCheck({fileName: "testcases/enums/IdentifierType.hx", toName: "LocalScopeVar", pos: 77}, edits);
	}

	public function testRenameCall() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/enums/Main.hx", "FunctionCall", 178, 182),
			makeReplaceTestEdit("testcases/enums/Main.hx", "FunctionCall", 211, 215),
			makeReplaceTestEdit("testcases/enums/IdentifierType.hx", "FunctionCall", 53, 57),
		];
		refactorAndCheck({fileName: "testcases/enums/IdentifierType.hx", toName: "FunctionCall", pos: 55}, edits);
	}

	public function testRenameScopedGlobal() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/enums/Main.hx", "GlobalScopeVar", 367, 379),
			makeReplaceTestEdit("testcases/enums/IdentifierType.hx", "GlobalScopeVar", 97, 109),
		];
		refactorAndCheck({fileName: "testcases/enums/IdentifierType.hx", toName: "GlobalScopeVar", pos: 103}, edits);
	}
}
