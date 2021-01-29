package refactor;

import refactor.TestEditableDocument.TestEdit;

class ClassTest extends TestBase {
	function setupClass() {
		setupData(["testcases/classes"]);
	}

	public function testRenameChildsTypeName() {
		var edits:Array<TestEdit> = [
			makeMoveTestEdit("testcases/classes/Childs.hx", "testcases/classes/ChildName.hx"),
			makeReplaceTestEdit("testcases/classes/Childs.hx", "ChildName", 24, 30),
			makeReplaceTestEdit("testcases/classes/Childs.hx", "ChildName", 106, 112),
			makeReplaceTestEdit("testcases/classes/Childs.hx", "ChildName", 167, 173),
			makeReplaceTestEdit("testcases/classes/Childs.hx", "ChildName", 212, 218),
		];
		refactorAndCheck({fileName: "testcases/classes/Childs.hx", toName: "ChildName", pos: 25}, edits);
	}

	public function testRenameBaseClassMethod() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "addData", 239, 250),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "addData", 355, 366),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "addData", 464, 475),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "addData", 145, 156),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "addData", 187, 198),
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
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 248, 252),
		];
		refactorAndCheck({fileName: "testcases/classes/BaseClass.hx", toName: "listOfData", pos: 44}, edits);
	}

	public function testRenameChildClass() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ItemClass", 38, 48),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ItemClass", 67, 77),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ItemClass", 143, 153),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ItemClass", 210, 220),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ItemClass", 299, 309),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ItemClass", 423, 433),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ItemClass", 510, 520),
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "ItemClass", 38, 48),
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "ItemClass", 111, 121),
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "ItemClass", 163, 173),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "ItemClass", 142, 152),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "ItemClass", 159, 169),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "ItemClass", 280, 290),
			makeReplaceTestEdit("testcases/classes/EnumType.hx", "ItemClass", 75, 85),
			makeReplaceTestEdit("testcases/classes/ChildHelper.hx", "ItemClass", 72, 82),
			makeReplaceTestEdit("testcases/classes/ChildHelper.hx", "ItemClass", 123, 133),
			makeReplaceTestEdit("testcases/classes/ChildHelper.hx", "ItemClass", 142, 152),
			makeMoveTestEdit("testcases/classes/ChildClass.hx", "testcases/classes/ItemClass.hx"),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "ItemClass", 24, 34),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "ItemClass", 625, 635),
		];
		refactorAndCheck({fileName: "testcases/classes/ChildClass.hx", toName: "ItemClass", pos: 28}, edits);
	}

	public function testRenameChildPackage() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "classes.pack.ChildClass", 30, 48),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "classes.pack.ChildClass", 59, 77),
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "classes.pack.ChildClass", 30, 48),
			makeInsertTestEdit("testcases/classes/StaticUsing.hx", "import classes.pack.ChildClass;\n", 18),
			makeInsertTestEdit("testcases/classes/EnumType.hx", "import classes.pack.ChildClass;\n", 18),
			makeInsertTestEdit("testcases/classes/ChildHelper.hx", "import classes.pack.ChildClass;\n", 18),
			makeMoveTestEdit("testcases/classes/ChildClass.hx", "testcases/classes/pack/ChildClass.hx"),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "classes.pack", 8, 15),
		];
		refactorAndCheck({fileName: "testcases/classes/ChildClass.hx", toName: "classes.pack", pos: 10}, edits);
	}

	public function testRenameTypedef() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ChildList", 107, 119),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "ChildList", 604, 616),
		];
		refactorAndCheck({fileName: "testcases/classes/ChildClass.hx", toName: "ChildList", pos: 605}, edits);
	}

	public function testRenameStaticExtentionSum() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "sumChilds", 182, 185),
			makeReplaceTestEdit("testcases/classes/ChildHelper.hx", "sumChilds", 62, 65),
		];
		refactorAndCheck({fileName: "testcases/classes/ChildHelper.hx", toName: "sumChilds", pos: 64}, edits);
	}

	public function testRenameStaticExtensionPrint() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "printChild", 151, 156),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "printChild", 210, 215),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "printChild", 293, 298),
		];
		refactorAndCheck({fileName: "testcases/classes/pack/SecondChildHelper.hx", toName: "printChild", pos: 153}, edits);
	}

	public function testRenameStaticExtensionPrintText() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "logText", 225, 234),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "logText", 248, 257),
		];
		refactorAndCheck({fileName: "testcases/classes/pack/SecondChildHelper.hx", toName: "logText", pos: 229}, edits);
	}

	public function testRenameChildClassParent() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "parentBase", 232, 238),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "parentBase", 348, 354),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "parentBase", 457, 463),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "parentBase", 566, 572),
			makeReplaceTestEdit("testcases/classes/ChildHelper.hx", "parentBase", 310, 316),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "parentBase", 67, 73),
		];
		refactorAndCheck({fileName: "testcases/classes/ChildClass.hx", toName: "parentBase", pos: 69}, edits);
	}

	public function testRenameIdentifierPos() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/MyIdentifier.hx", "position", 253, 256),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "position", 387, 390),
		];
		refactorAndCheck({fileName: "testcases/classes/MyIdentifier.hx", toName: "position", pos: 254}, edits);
	}

	public function testRenameJsonClassWidth() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "jsonWidth", 72, 77),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "jsonWidth", 194, 199),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "jsonWidth", 374, 379),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "jsonWidth", 449, 454),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "jsonWidth", 463, 468),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "jsonWidth", 620, 625),
		];
		refactorAndCheck({fileName: "testcases/classes/JsonClass.hx", toName: "jsonWidth", pos: 74}, edits);
	}
}
