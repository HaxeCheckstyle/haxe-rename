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

	public function testRenameChildClass() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ItemClass", 38, 48),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ItemClass", 67, 77),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ItemClass", 143, 153),
			makeMoveTestEdit("testcases/classes/ChildClass.hx", "testcases/classes/ItemClass.hx"),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "ItemClass", 24, 34),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "ItemClass", 210, 220),
		];
		refactorAndCheck({fileName: "testcases/classes/ChildClass.hx", toName: "ItemClass", pos: 28}, edits);
	}

	public function testRenameChildPackage() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "classes.pack.ChildClass", 30, 48),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "classes.pack.ChildClass", 59, 77),
			makeMoveTestEdit("testcases/classes/ChildClass.hx", "testcases/classes/pack/ChildClass.hx"),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "classes.pack", 8, 15),
		];
		refactorAndCheck({fileName: "testcases/classes/ChildClass.hx", toName: "classes.pack", pos: 10}, edits);
	}
}
