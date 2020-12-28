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
		];
		refactorAndCheck({fileName: "testcases/typedefs/Types.hx", toName: "FilePos", pos: 31}, edits);
	}

	public function testRenameFilename() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "file", 50, 58),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 265, 273),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 361, 369),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 460, 468),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Types.hx", toName: "file", pos: 53}, edits);
	}

	public function testRenameFilenameFormObjectLiteral() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "file", 50, 58),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 265, 273),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 361, 369),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "file", 460, 468),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Main.hx", toName: "file", pos: 268}, edits);
	}

	public function testRenameLine() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "lineNumber", 157, 161),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 414, 418),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 513, 517),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Types.hx", toName: "lineNumber", pos: 159}, edits);
	}

	public function testRenameLinefromObjectLiteral() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "lineNumber", 157, 161),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 414, 418),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 513, 517),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Main.hx", toName: "lineNumber", pos: 416}, edits);
	}

	public function testRenameLinefromObjectLiteral2() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/Types.hx", "lineNumber", 157, 161),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 414, 418),
			makeReplaceTestEdit("testcases/typedefs/Main.hx", "lineNumber", 513, 517),
		];
		refactorAndCheck({fileName: "testcases/typedefs/Main.hx", toName: "lineNumber", pos: 515}, edits);
	}
}
