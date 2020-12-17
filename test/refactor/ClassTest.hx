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
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "ItemClass", 38, 48),
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "ItemClass", 111, 121),
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "ItemClass", 163, 173),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "ItemClass", 142, 152),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "ItemClass", 159, 169),
			makeReplaceTestEdit("testcases/classes/ChildHelper.hx", "ItemClass", 72, 82),
			makeReplaceTestEdit("testcases/classes/ChildHelper.hx", "ItemClass", 123, 133),
			makeReplaceTestEdit("testcases/classes/ChildHelper.hx", "ItemClass", 142, 152),
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
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "classes.pack.ChildClass", 30, 48),
			makeInsertTestEdit("testcases/classes/StaticUsing.hx", "import classes.pack.ChildClass;\n", 18),
			makeInsertTestEdit("testcases/classes/ChildHelper.hx", "import classes.pack.ChildClass;\n", 18),
			makeMoveTestEdit("testcases/classes/ChildClass.hx", "testcases/classes/pack/ChildClass.hx"),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "classes.pack", 8, 15),
		];
		refactorAndCheck({fileName: "testcases/classes/ChildClass.hx", toName: "classes.pack", pos: 10}, edits);
	}

	public function testRenameTypedef() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ChildList", 107, 119),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "ChildList", 189, 201),
		];
		refactorAndCheck({fileName: "testcases/classes/ChildClass.hx", toName: "ChildList", pos: 194}, edits);
	}

	public function testRenameStaticExtentionSum() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "sumChilds", 182, 185),
			makeReplaceTestEdit("testcases/classes/ChildHelper.hx", "sumChilds", 62, 65),
		];
		refactorAndCheck({fileName: "testcases/classes/ChildHelper.hx", toName: "sumChilds", pos: 64}, edits);
	}

	public function testRenameStaticExtentionPrint() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "printChild", 151, 156),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "printChild", 210, 215),
		];
		refactorAndCheck({fileName: "testcases/classes/pack/SecondChildHelper.hx", toName: "printChild", pos: 153}, edits);
	}

	public function testRenameStaticExtentionPrintText() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "logText", 225, 234),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "logText", 248, 257),
		];
		refactorAndCheck({fileName: "testcases/classes/pack/SecondChildHelper.hx", toName: "logText", pos: 229}, edits);
	}
}
