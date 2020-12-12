package refactor;

import refactor.TestEditableDocument.TestEdit;

class ClassTest extends TestBase {
	function setupClass() {
		setupData(["testcases/classes"]);
	}

	public function testRenameBaseClassMethod() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "addData", 114, 125),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "addData", 156, 167),
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "addData", 121, 132),
		];
		refactorAndCheck({fileName: "testcases/classes/BaseClass.hx", toName: "addData", pos: 128}, edits);
	}

	public function testRenameBaseClassVar() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 41, 45),
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 89, 93),
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 162, 166),
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 174, 178),
		];
		refactorAndCheck({fileName: "testcases/classes/BaseClass.hx", toName: "listOfData", pos: 44}, edits);
	}
}
