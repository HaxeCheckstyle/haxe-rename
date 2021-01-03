package refactor;

import refactor.TestEditableDocument.TestEdit;

class TypedefTest extends TestBase {
	function setupClass() {
		setupData(["testcases/typedefs"]);
	}

	public function testRenameTypedefType() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "FilePos", 27, 40),
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "FilePos", 134, 147),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "FilePos", 821, 834),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Types.hx", toName: "FilePos", pos: 31}, edits);
	}

	public function testRenameFilename() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "file", 50, 58),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 302, 310),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 398, 406),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 497, 505),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 673, 681),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 735, 743),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 851, 859),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 957, 965),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Types.hx", toName: "file", pos: 53}, edits);
	}

	public function testRenameFilenameFormObjectLiteral() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "file", 50, 58),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 302, 310),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 398, 406),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 497, 505),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 673, 681),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 735, 743),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 851, 859),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 957, 965),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Main.hx", toName: "file", pos: 305}, edits);
	}

	public function testRenameLine() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "lineNumber", 157, 161),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 451, 455),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 550, 554),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Types.hx", toName: "lineNumber", pos: 159}, edits);
	}

	public function testRenameLinefromObjectLiteral() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "lineNumber", 157, 161),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 451, 455),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 550, 554),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Main.hx", toName: "lineNumber", pos: 453}, edits);
	}

	public function testRenameLinefromObjectLiteral2() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "lineNumber", 157, 161),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 451, 455),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 550, 554),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Main.hx", toName: "lineNumber", pos: 552}, edits);
	}
}
