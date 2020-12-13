package refactor;

import refactor.TestEditableDocument.TestEdit;

class EnumTest extends TestBase {
	function setupClass() {
		setupData(["testcases/enums"]);
	}

	public function testRenameScopedLocal() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/enums/Main.hx", "LocalScopeVar", 219, 230),
			makeReplaceTestEdit("testcases/enums/IdentifierType.hx", "LocalScopeVar", 69, 80),
		];
		refactorAndCheck({fileName: "testcases/enums/IdentifierType.hx", toName: "LocalScopeVar", pos: 77}, edits);
	}

	public function testRenameCall() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/enums/Main.hx", "FunctionCall", 162, 166),
			makeReplaceTestEdit("testcases/enums/Main.hx", "FunctionCall", 195, 199),
			makeReplaceTestEdit("testcases/enums/IdentifierType.hx", "FunctionCall", 53, 57),
		];
		refactorAndCheck({fileName: "testcases/enums/IdentifierType.hx", toName: "FunctionCall", pos: 55}, edits);
	}

	public function testRenameScopedGlobal() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/enums/Main.hx", "GlobalScopeVar", 351, 363),
			makeReplaceTestEdit("testcases/enums/IdentifierType.hx", "GlobalScopeVar", 97, 109),
		];
		refactorAndCheck({fileName: "testcases/enums/IdentifierType.hx", toName: "GlobalScopeVar", pos: 103}, edits);
	}
}
