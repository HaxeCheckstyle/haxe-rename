package refactor;

import refactor.TestEditableDocument.TestEdit;

class TypedefTest extends TestBase {
	function setupClass() {
		setupTestSources(["testcases/typedefs"]);
	}

	public function testRenameTypedefType(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "FilePos", 107, 120),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "FilePos", 821, 834),
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "FilePos", 59, 72),
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "FilePos", 166, 179),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Types.hx", toName: "FilePos", pos: 66}, edits, async);
	}

	public function testRenameFilename(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 302, 310),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 398, 406),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 497, 505),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 673, 681),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 735, 743),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 850, 858),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 957, 965),
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "file", 82, 90),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Types.hx", toName: "file", pos: 84}, edits, async);
	}

	public function testRenameFilenameFormObjectLiteral(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 302, 310),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 398, 406),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 497, 505),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 673, 681),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 735, 743),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 850, 858),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 957, 965),
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "file", 82, 90),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Main.hx", toName: "file", pos: 305}, edits, async);
	}

	public function testRenameLine(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 451, 455),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 550, 554),
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "lineNumber", 189, 193),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Types.hx", toName: "lineNumber", pos: 191}, edits, async);
	}

	public function testRenameLinefromObjectLiteral(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 451, 455),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 550, 554),
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "lineNumber", 189, 193),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Main.hx", toName: "lineNumber", pos: 453}, edits, async);
	}

	public function testRenameLinefromObjectLiteral2(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 451, 455),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 550, 554),
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "lineNumber", 189, 193),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Main.hx", toName: "lineNumber", pos: 552}, edits, async);
	}

	public function testRenameTypedefBase(async:Async) {
		var edits:Array<TestEdit> = [];
		failRefactor({fileName: "testcases/typedefs/Types.hx", toName: "Position", pos: 172},
			"renaming not supported for IdentifierPos testcases/typedefs/Types.hx@166-179 (TypedefBase)", async);
	}

	public function testRenameTypedefBase2(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "sourceFolders", 1095, 1114),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "sourceFolders", 1162, 1181),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "sourceFolders", 2270, 2289),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "sourceFolders", 3489, 3508),
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "sourceFolders", 775, 794),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Types.hx", toName: "sourceFolders", pos: 784}, edits, async);
	}
}
