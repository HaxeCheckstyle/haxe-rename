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
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "FilePos", 27, 40),
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "FilePos", 134, 147),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Types.hx", toName: "FilePos", pos: 31}, edits, async);
	}

	public function testRenameFilename(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 302, 310),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 398, 406),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 497, 505),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 673, 681),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 735, 743),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 851, 859),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 957, 965),
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "file", 50, 58),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Types.hx", toName: "file", pos: 53}, edits, async);
	}

	public function testRenameFilenameFormObjectLiteral(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 302, 310),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 398, 406),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 497, 505),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 673, 681),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 735, 743),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 851, 859),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 957, 965),
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "file", 50, 58),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Main.hx", toName: "file", pos: 305}, edits, async);
	}

	public function testRenameLine(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 451, 455),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 550, 554),
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "lineNumber", 157, 161),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Types.hx", toName: "lineNumber", pos: 159}, edits, async);
	}

	public function testRenameLinefromObjectLiteral(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 451, 455),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 550, 554),
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "lineNumber", 157, 161),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Main.hx", toName: "lineNumber", pos: 453}, edits, async);
	}

	public function testRenameLinefromObjectLiteral2(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 451, 455),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 550, 554),
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "lineNumber", 157, 161),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Main.hx", toName: "lineNumber", pos: 552}, edits, async);
	}
}
