package refactor;

class ClassTest extends TestBase {
	function setupClass() {
		setupTestSources(["testcases/classes"]);
	}

	public function testRenameChildsTypeName(async:Async) {
		var edits:Array<TestEdit> = [
			makeMoveTestEdit("testcases/classes/Childs.hx", "testcases/classes/ChildName.hx"),
			makeReplaceTestEdit("testcases/classes/Childs.hx", "ChildName", 24, 30),
			makeReplaceTestEdit("testcases/classes/Childs.hx", "ChildName", 106, 112),
			makeReplaceTestEdit("testcases/classes/Childs.hx", "ChildName", 167, 173),
			makeReplaceTestEdit("testcases/classes/Childs.hx", "ChildName", 212, 218),
		];
		refactorAndCheck({fileName: "testcases/classes/Childs.hx", toName: "ChildName", pos: 25}, edits, async);
	}

	public function testRenameBaseClassMethod(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "addData", 121, 132),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "addData", 145, 156),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "addData", 187, 198),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "addData", 228, 239),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "addData", 344, 355),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "addData", 453, 464),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "addData", 641, 652),
		];
		refactorAndCheck({fileName: "testcases/classes/BaseClass.hx", toName: "addData", pos: 128}, edits, async);
	}

	public function testRenameBaseClassVar(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 41, 45),
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 89, 93),
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 162, 166),
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 174, 178),
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 248, 252),
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 407, 411),
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 425, 429),
		];
		refactorAndCheck({fileName: "testcases/classes/BaseClass.hx", toName: "listOfData", pos: 44}, edits, async);
	}

	public function testRenameBaseClassVarFromSomewhere(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 41, 45),
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 89, 93),
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 162, 166),
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 174, 178),
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 248, 252),
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 407, 411),
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "listOfData", 425, 429),
		];
		refactorAndCheck({fileName: "testcases/classes/BaseClass.hx", toName: "listOfData", pos: 163}, edits, async);
	}

	public function testRenameChildClass(async:Async) {
		var edits:Array<TestEdit> = [
			makeMoveTestEdit("testcases/classes/ChildClass.hx", "testcases/classes/ItemClass.hx"),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "ItemClass", 24, 34),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "ItemClass", 889, 899),
			makeReplaceTestEdit("testcases/classes/ChildHelper.hx", "ItemClass", 72, 82),
			makeReplaceTestEdit("testcases/classes/ChildHelper.hx", "ItemClass", 123, 133),
			makeReplaceTestEdit("testcases/classes/ChildHelper.hx", "ItemClass", 142, 152),
			makeReplaceTestEdit("testcases/classes/EnumType.hx", "ItemClass", 75, 85),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "ItemClass", 142, 152),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "ItemClass", 159, 169),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "ItemClass", 264, 274),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "ItemClass", 355, 365),
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "ItemClass", 38, 48),
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "ItemClass", 111, 121),
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "ItemClass", 163, 173),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ItemClass", 56, 66),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ItemClass", 132, 142),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ItemClass", 199, 209),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ItemClass", 288, 298),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ItemClass", 412, 422),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ItemClass", 499, 509),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ItemClass", 612, 622),
		];
		refactorAndCheck({fileName: "testcases/classes/ChildClass.hx", toName: "ItemClass", pos: 28}, edits, async);
	}

	public function testRenameChildPackage(async:Async) {
		var edits:Array<TestEdit> = [
			makeMoveTestEdit("testcases/classes/ChildClass.hx", "testcases/classes/pack/ChildClass.hx"),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "classes.pack", 8, 15),
			makeInsertTestEdit("testcases/classes/ChildHelper.hx", "import classes.pack.ChildClass;\n", 18),
			makeInsertTestEdit("testcases/classes/EnumType.hx", "import classes.pack.ChildClass;\n", 18),
			makeInsertTestEdit("testcases/classes/StaticUsing.hx", "import classes.pack.ChildClass;\n", 18),
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "classes.pack.ChildClass", 30, 48),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "classes.pack.ChildClass", 48, 66),
		];
		refactorAndCheck({fileName: "testcases/classes/ChildClass.hx", toName: "classes.pack", pos: 10}, edits, async);
	}

	public function testRenameTypedef(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "ChildList", 868, 880),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ChildList", 96, 108),
		];
		refactorAndCheck({fileName: "testcases/classes/ChildClass.hx", toName: "ChildList", pos: 872}, edits, async);
	}

	public function testRenameStaticExtentionSum(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/ChildHelper.hx", "sumChilds", 62, 65),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "sumChilds", 182, 185),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "sumChilds", 706, 709),
		];
		refactorAndCheck({fileName: "testcases/classes/ChildHelper.hx", toName: "sumChilds", pos: 64}, edits, async);
	}

	public function testRenameStaticExtensionPrint(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "printChild", 210, 215),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "printChild", 368, 373),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "printChild", 386, 391),
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "printChild", 151, 156),
		];
		refactorAndCheck({fileName: "testcases/classes/pack/SecondChildHelper.hx", toName: "printChild", pos: 153}, edits, async);
	}

	public function testRenameStaticExtensionPrintText(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "logText", 323, 332),
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "logText", 225, 234),
		];
		refactorAndCheck({fileName: "testcases/classes/pack/SecondChildHelper.hx", toName: "logText", pos: 229}, edits, async);
	}

	public function testRenameChildClassParent(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "parentBase", 67, 73),
			makeReplaceTestEdit("testcases/classes/ChildHelper.hx", "parentBase", 310, 316),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "parentBase", 221, 227),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "parentBase", 337, 343),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "parentBase", 446, 452),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "parentBase", 555, 561),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "parentBase", 634, 640),
		];
		refactorAndCheck({fileName: "testcases/classes/ChildClass.hx", toName: "parentBase", pos: 69}, edits, async);
	}

	public function testRenameIdentifierPos(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "position", 392, 395),
			makeReplaceTestEdit("testcases/classes/MyIdentifier.hx", "position", 253, 256),
		];
		refactorAndCheck({fileName: "testcases/classes/MyIdentifier.hx", toName: "position", pos: 254}, edits, async);
	}

	// requires external typer since built-in will not resolve array access
	// public function testRenameIdentifierName(async:Async) {
	// 	var edits:Array<TestEdit> = [
	// 		makeReplaceTestEdit("testcases/classes/ChildClass.hx", "id", 454, 458),
	// 		makeReplaceTestEdit("testcases/classes/ChildClass.hx", "id", 473, 477),
	// 		makeReplaceTestEdit("testcases/classes/ChildClass.hx", "id", 516, 520),
	// 		makeReplaceTestEdit("testcases/classes/ChildClass.hx", "id", 707, 711),
	// 		makeReplaceTestEdit("testcases/classes/ChildClass.hx", "id", 796, 800),
	// 		makeReplaceTestEdit("testcases/classes/MyIdentifier.hx", "id", 228, 232),
	// 	];
	// 	refactorAndCheck({fileName: "testcases/classes/MyIdentifier.hx", toName: "id", pos: 229}, edits, async);
	// }
	public function testRenameJsonClassWidth(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "jsonWidth", 72, 77),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "jsonWidth", 194, 199),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "jsonWidth", 374, 379),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "jsonWidth", 449, 454),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "jsonWidth", 463, 468),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "jsonWidth", 620, 625),
		];
		refactorAndCheck({fileName: "testcases/classes/JsonClass.hx", toName: "jsonWidth", pos: 74}, edits, async);
	}

	public function testRenameJsonClass(async:Async) {
		var edits:Array<TestEdit> = [
			makeMoveTestEdit("testcases/classes/JsonClass.hx", "testcases/classes/JsonImporter.hx"),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "JsonImporter", 24, 33),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "JsonImporter", 276, 285),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "JsonImporter", 287, 296),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "JsonImporter", 319, 328),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "JsonImporter", 336, 345),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "JsonImporter", 744, 753),
		];
		refactorAndCheck({fileName: "testcases/classes/JsonClass.hx", toName: "JsonImporter", pos: 28}, edits, async);
	}

	public function testRenameBaseClassParamterWithShadow(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "data", 227, 228),
			makeInsertTestEdit("testcases/classes/BaseClass.hx", "this.", 248),
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "data", 260, 261),
		];
		refactorAndCheck({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 227}, edits, async);
	}

	public function testRenameBaseClassParamterWithShadowLocalVar(async:Async) {
		var edits:Array<TestEdit> = [];
		failCanRefactor({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 298}, 'local var "data" exists', async);
		failRefactor({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 298}, 'local var "data" exists', async);
	}

	public function testRenameBaseClassCaseLabel(async:Async) {
		var edits:Array<TestEdit> = [];
		failCanRefactor({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 516},
			"renaming not supported for Case1 testcases/classes/BaseClass.hx@514-519 (CaseLabel(val))", async);
		failRefactor({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 516},
			"renaming not supported for Case1 testcases/classes/BaseClass.hx@514-519 (CaseLabel(val))", async);
	}

	public function testRenameUseChildClassParentSubPart(async:Async) {
		var edits:Array<TestEdit> = [];
		failCanRefactor({fileName: "testcases/classes/UseChild.hx", toName: "data", pos: 222}, "could not find identifier to rename", async);
		failRefactor({fileName: "testcases/classes/UseChild.hx", toName: "data", pos: 222}, "could not find identifier to rename", async);
	}

	public function testRenameBaseClassDataToData(async:Async) {
		var edits:Array<TestEdit> = [];
		failCanRefactor({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 43}, "could not find identifier to rename", async);
		failRefactor({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 43}, "could not find identifier to rename", async);
	}

	public function testRenameBaseClassNoIdentifier(async:Async) {
		var edits:Array<TestEdit> = [];
		failCanRefactor({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 103}, "could not find identifier to rename", async);
		failRefactor({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 103}, "could not find identifier to rename", async);
	}

	public function testRenameStaticUsingConstructorCall(async:Async) {
		var edits:Array<TestEdit> = [];
		failCanRefactor({fileName: "testcases/classes/StaticUsing.hx", toName: "NewChildClass", pos: 359},
			"renaming not supported for ChildClass testcases/classes/StaticUsing.hx@355-365 (Call(true))", async);
		failRefactor({fileName: "testcases/classes/StaticUsing.hx", toName: "NewChildClass", pos: 359},
			"renaming not supported for ChildClass testcases/classes/StaticUsing.hx@355-365 (Call(true))", async);
	}

	public function testRenameBaseClassParamterWithShadow2(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "data", 386, 387),
			makeInsertTestEdit("testcases/classes/BaseClass.hx", "this.", 407),
		];
		refactorAndCheck({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 386}, edits, async);
	}

	public function testRenameBaseClassParamterWithShadowCase(async:Async) {
		var edits:Array<TestEdit> = [];
		failCanRefactor({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 470}, 'local var "data" exists', async);
		failRefactor({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 470}, 'local var "data" exists', async);
	}

	public function testRenameChildClassExtendsBaseClass(async:Async) {
		var edits:Array<TestEdit> = [];
		failCanRefactor({fileName: "testcases/classes/ChildClass.hx", toName: "parentBase", pos: 47},
			"renaming not supported for BaseClass testcases/classes/ChildClass.hx@43-52 (Extends)", async);
		failRefactor({fileName: "testcases/classes/ChildClass.hx", toName: "parentBase", pos: 47},
			"renaming not supported for BaseClass testcases/classes/ChildClass.hx@43-52 (Extends)", async);
	}

	public function testRenameImport(async:Async) {
		var edits:Array<TestEdit> = [];
		failCanRefactor({fileName: "testcases/classes/MyIdentifier.hx", toName: "refactor.Foo", pos: 44},
			"renaming not supported for refactor.discover.File testcases/classes/MyIdentifier.hx@25-47 (ImportModul)", async);
		failRefactor({fileName: "testcases/classes/MyIdentifier.hx", toName: "refactor.Foo", pos: 44},
			"renaming not supported for refactor.discover.File testcases/classes/MyIdentifier.hx@25-47 (ImportModul)", async);
	}

	public function testRenameDemoClassAMemberVar(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 235, 245),
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 529, 539),
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 546, 556),
		];
		refactorAndCheck({fileName: "testcases/classes/DemoClassA.hx", toName: "wasRenamed", pos: 237}, edits, async);
	}

	public function testRenameDemoClassAMemberVar2(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 235, 245),
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 529, 539),
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 546, 556),
		];
		refactorAndCheck({fileName: "testcases/classes/DemoClassA.hx", toName: "wasRenamed", pos: 531}, edits, async);
	}

	public function testRenameDemoClassAMemberVar3(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 235, 245),
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 529, 539),
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 546, 556),
		];
		refactorAndCheck({fileName: "testcases/classes/DemoClassA.hx", toName: "wasRenamed", pos: 548}, edits, async);
	}

	public function testRenameDemoClassASomeValue(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 59, 68),
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 515, 524),
		];
		refactorAndCheck({fileName: "testcases/classes/DemoClassA.hx", toName: "wasRenamed", pos: 61}, edits, async);
	}

	public function testRenamePrinter(async:Async) {
		var edits:Array<TestEdit> = [
			makeMoveTestEdit("testcases/classes/Printer.hx", "testcases/classes/PrinterRenamed.hx"),
			makeReplaceTestEdit("testcases/classes/Printer.hx", "PrinterRenamed", 383, 390),
			makeReplaceTestEdit("testcases/classes/Printer.hx", "PrinterRenamed", 545, 552),
			makeReplaceTestEdit("testcases/classes/Printer.hx", "PrinterRenamed", 699, 706),
			makeReplaceTestEdit("testcases/classes/Printer.hx", "PrinterRenamed", 930, 937),
			makeReplaceTestEdit("testcases/classes/Printer.hx", "PrinterRenamed", 1076, 1083),
			makeReplaceTestEdit("testcases/classes/Printer.hx", "PrinterRenamed", 1219, 1226),
			makeReplaceTestEdit("testcases/classes/import.hx", "PrinterRenamed", 80, 87),
			makeReplaceTestEdit("testcases/classes/pack/UsePrinter.hx", "PrinterRenamed", 58, 65),
		];
		refactorAndCheck({fileName: "testcases/classes/Printer.hx", toName: "PrinterRenamed", pos: 1222}, edits, async);
	}
}
