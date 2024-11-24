package refactor.rename;

class RenameClassTest extends RenameTestBase {
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
		checkRename({fileName: "testcases/classes/Childs.hx", toName: "ChildName", pos: 25}, edits, async);
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
		checkRename({fileName: "testcases/classes/BaseClass.hx", toName: "addData", pos: 128}, edits, async);
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
		checkRename({fileName: "testcases/classes/BaseClass.hx", toName: "listOfData", pos: 44}, edits, async);
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
		checkRename({fileName: "testcases/classes/BaseClass.hx", toName: "listOfData", pos: 163}, edits, async);
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
		checkRename({fileName: "testcases/classes/ChildClass.hx", toName: "ItemClass", pos: 28}, edits, async);
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
		checkRename({fileName: "testcases/classes/ChildClass.hx", toName: "classes.pack", pos: 10}, edits, async);
	}

	public function testRenameTypedef(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "ChildList", 868, 880),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "ChildList", 96, 108),
		];
		checkRename({fileName: "testcases/classes/ChildClass.hx", toName: "ChildList", pos: 872}, edits, async);
	}

	public function testRenameScopeStart(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "scopeStartRenamed", 255, 265),
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "scopeStartRenamed", 404, 414),
		];
		checkRename({fileName: "testcases/classes/ChildClass.hx", toName: "scopeStartRenamed", pos: 259}, edits, async);
	}

	public function testRenameStaticExtentionSum(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/ChildHelper.hx", "sumChilds", 62, 65),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "sumChilds", 182, 185),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "sumChilds", 706, 709),
		];
		checkRename({fileName: "testcases/classes/ChildHelper.hx", toName: "sumChilds", pos: 64}, edits, async);
	}

	public function testRenameStaticExtensionPrint(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "printChild", 210, 215),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "printChild", 368, 373),
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "printChild", 386, 391),
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "printChild", 151, 156),
		];
		checkRename({fileName: "testcases/classes/pack/SecondChildHelper.hx", toName: "printChild", pos: 153}, edits, async);
	}

	public function testRenameStaticExtensionPrintText(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/StaticUsing.hx", "logText", 323, 332),
			makeReplaceTestEdit("testcases/classes/pack/SecondChildHelper.hx", "logText", 225, 234),
		];
		checkRename({fileName: "testcases/classes/pack/SecondChildHelper.hx", toName: "logText", pos: 229}, edits, async);
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
		checkRename({fileName: "testcases/classes/ChildClass.hx", toName: "parentBase", pos: 69}, edits, async);
	}

	public function testRenameIdentifierPos(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/ChildClass.hx", "position", 392, 395),
			makeReplaceTestEdit("testcases/classes/MyIdentifier.hx", "position", 253, 256),
		];
		checkRename({fileName: "testcases/classes/MyIdentifier.hx", toName: "position", pos: 254}, edits, async);
	}

	// TODO requires external typer since built-in will not resolve array access
	// public function testRenameIdentifierName(async:Async) {
	// 	var edits:Array<TestEdit> = [
	// 		makeReplaceTestEdit("testcases/classes/ChildClass.hx", "id", 454, 458),
	// 		makeReplaceTestEdit("testcases/classes/ChildClass.hx", "id", 473, 477),
	// 		makeReplaceTestEdit("testcases/classes/ChildClass.hx", "id", 516, 520),
	// 		makeReplaceTestEdit("testcases/classes/ChildClass.hx", "id", 707, 711),
	// 		makeReplaceTestEdit("testcases/classes/ChildClass.hx", "id", 796, 800),
	// 		makeReplaceTestEdit("testcases/classes/MyIdentifier.hx", "id", 228, 232),
	// 	];
	// 	checkRename({fileName: "testcases/classes/MyIdentifier.hx", toName: "id", pos: 229}, edits, async);
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
		checkRename({fileName: "testcases/classes/JsonClass.hx", toName: "jsonWidth", pos: 74}, edits, async);
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
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "JsonImporter", 801, 810),
			makeReplaceTestEdit("testcases/classes/pack/UseChild.hx", "JsonImporter", 864, 873),
			makeReplaceTestEdit("testcases/classes/pack/UseJson.hx", "JsonImporter", 38, 47),
			makeReplaceTestEdit("testcases/classes/pack/UseJson.hx", "JsonImporter", 165, 174),
		];
		checkRename({fileName: "testcases/classes/JsonClass.hx", toName: "JsonImporter", pos: 28}, edits, async);
	}

	public function testRenameBaseClassParamterWithShadow(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "data", 227, 228),
			makeInsertTestEdit("testcases/classes/BaseClass.hx", "this.", 248),
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "data", 260, 261),
		];
		checkRename({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 227}, edits, async);
	}

	public function testRenameBaseClassParamterWithShadowLocalVar(async:Async) {
		var edits:Array<TestEdit> = [];
		failCanRename({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 298}, 'local var "data" exists', async);
		failRename({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 298}, 'local var "data" exists', async);
	}

	public function testRenameBaseClassCaseLabel(async:Async) {
		var edits:Array<TestEdit> = [];
		failCanRename({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 516},
			"renaming not supported for Case1 testcases/classes/BaseClass.hx@514-519 (CaseLabel(val))", async);
		failRename({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 516},
			"renaming not supported for Case1 testcases/classes/BaseClass.hx@514-519 (CaseLabel(val))", async);
	}

	public function testRenameUseChildClassParentSubPart(async:Async) {
		var edits:Array<TestEdit> = [];
		failCanRename({fileName: "testcases/classes/UseChild.hx", toName: "data", pos: 222}, "could not find identifier to rename", async);
		failRename({fileName: "testcases/classes/UseChild.hx", toName: "data", pos: 222}, "could not find identifier to rename", async);
	}

	public function testRenameBaseClassDataToData(async:Async) {
		var edits:Array<TestEdit> = [];
		failCanRename({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 43}, "could not find identifier to rename", async);
		failRename({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 43}, "could not find identifier to rename", async);
	}

	public function testRenameBaseClassNoIdentifier(async:Async) {
		var edits:Array<TestEdit> = [];
		failCanRename({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 103}, "could not find identifier to rename", async);
		failRename({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 103}, "could not find identifier to rename", async);
	}

	public function testRenameStaticUsingConstructorCall(async:Async) {
		var edits:Array<TestEdit> = [];
		failCanRename({fileName: "testcases/classes/StaticUsing.hx", toName: "NewChildClass", pos: 359},
			"renaming not supported for ChildClass testcases/classes/StaticUsing.hx@355-365 (Call(true))", async);
		failRename({fileName: "testcases/classes/StaticUsing.hx", toName: "NewChildClass", pos: 359},
			"renaming not supported for ChildClass testcases/classes/StaticUsing.hx@355-365 (Call(true))", async);
	}

	public function testRenameBaseClassParamterWithShadow2(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/BaseClass.hx", "data", 386, 387),
			makeInsertTestEdit("testcases/classes/BaseClass.hx", "this.", 407),
		];
		checkRename({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 386}, edits, async);
	}

	public function testRenameBaseClassParamterWithShadowCase(async:Async) {
		var edits:Array<TestEdit> = [];
		failCanRename({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 470}, 'local var "data" exists', async);
		failRename({fileName: "testcases/classes/BaseClass.hx", toName: "data", pos: 470}, 'local var "data" exists', async);
	}

	public function testRenameChildClassExtendsBaseClass(async:Async) {
		var edits:Array<TestEdit> = [];
		failCanRename({fileName: "testcases/classes/ChildClass.hx", toName: "parentBase", pos: 47},
			"renaming not supported for BaseClass testcases/classes/ChildClass.hx@43-52 (Extends)", async);
		failRename({fileName: "testcases/classes/ChildClass.hx", toName: "parentBase", pos: 47},
			"renaming not supported for BaseClass testcases/classes/ChildClass.hx@43-52 (Extends)", async);
	}

	public function testRenameImport(async:Async) {
		var edits:Array<TestEdit> = [];
		failCanRename({fileName: "testcases/classes/MyIdentifier.hx", toName: "refactor.Foo", pos: 44},
			"renaming not supported for refactor.discover.File testcases/classes/MyIdentifier.hx@25-47 (ImportModul)", async);
		failRename({fileName: "testcases/classes/MyIdentifier.hx", toName: "refactor.Foo", pos: 44},
			"renaming not supported for refactor.discover.File testcases/classes/MyIdentifier.hx@25-47 (ImportModul)", async);
	}

	public function testRenameDemoClassAMemberVar(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 235, 245),
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 529, 539),
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 546, 556),
		];
		checkRename({fileName: "testcases/classes/DemoClassA.hx", toName: "wasRenamed", pos: 237}, edits, async);
	}

	public function testRenameDemoClassAMemberVar2(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 235, 245),
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 529, 539),
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 546, 556),
		];
		checkRename({fileName: "testcases/classes/DemoClassA.hx", toName: "wasRenamed", pos: 531}, edits, async);
	}

	public function testRenameDemoClassAMemberVar3(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 235, 245),
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 529, 539),
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 546, 556),
		];
		checkRename({fileName: "testcases/classes/DemoClassA.hx", toName: "wasRenamed", pos: 548}, edits, async);
	}

	public function testRenameDemoClassASomeValue(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 59, 68),
			makeReplaceTestEdit("testcases/classes/DemoClassA.hx", "wasRenamed", 515, 524),
		];
		checkRename({fileName: "testcases/classes/DemoClassA.hx", toName: "wasRenamed", pos: 61}, edits, async);
	}

	public function testRenamePrinter(async:Async) {
		var edits:Array<TestEdit> = [
			makeMoveTestEdit("testcases/classes/Printer.hx", "testcases/classes/PrinterRenamed.hx"),
			makeReplaceTestEdit("testcases/classes/Printer.hx", "PrinterRenamed", 345, 352),
			makeReplaceTestEdit("testcases/classes/Printer.hx", "PrinterRenamed", 507, 514),
			makeReplaceTestEdit("testcases/classes/Printer.hx", "PrinterRenamed", 661, 668),
			makeReplaceTestEdit("testcases/classes/Printer.hx", "PrinterRenamed", 892, 899),
			makeReplaceTestEdit("testcases/classes/Printer.hx", "PrinterRenamed", 1038, 1045),
			makeReplaceTestEdit("testcases/classes/Printer.hx", "PrinterRenamed", 1181, 1188),
			makeReplaceTestEdit("testcases/classes/import.hx", "PrinterRenamed", 88, 95),
			makeReplaceTestEdit("testcases/classes/pack/UsePrinter.hx", "PrinterRenamed", 38, 45),
		];
		checkRename({fileName: "testcases/classes/Printer.hx", toName: "PrinterRenamed", pos: 1184}, edits, async);
	}

	public function testRenameFooX(async:Async) {
		var edits:Array<TestEdit> = [makeReplaceTestEdit("testcases/classes/Foo.hx", "xRenamed", 218, 219),];
		checkRename({fileName: "testcases/classes/Foo.hx", toName: "xRenamed", pos: 218}, edits, async);
	}

	public function testRenameFooResp(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/Foo.hx", "respRenamed", 170, 174),
			makeReplaceTestEdit("testcases/classes/Foo.hx", "respRenamed", 182, 186),
		];
		checkRename({fileName: "testcases/classes/Foo.hx", toName: "respRenamed", pos: 173}, edits, async);
	}

	public function testRenamePrinterMainResultArrow(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/Printer.hx", "resultRenamed", 446, 452),
			makeReplaceTestEdit("testcases/classes/Printer.hx", "resultRenamed", 469, 475),
		];
		checkRename({fileName: "testcases/classes/Printer.hx", toName: "resultRenamed", pos: 448}, edits, async);
	}

	public function testRenamePrinterMainTextArrow(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/Printer.hx", "textRenamed", 644, 648),
			makeReplaceTestEdit("testcases/classes/Printer.hx", "textRenamed", 669, 673),
		];
		checkRename({fileName: "testcases/classes/Printer.hx", toName: "textRenamed", pos: 645}, edits, async);
	}

	public function testRenamePrinterMainResultArrow2(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/Printer.hx", "resultRenamed", 831, 837),
			makeReplaceTestEdit("testcases/classes/Printer.hx", "resultRenamed", 854, 860),
		];
		checkRename({fileName: "testcases/classes/Printer.hx", toName: "resultRenamed", pos: 833}, edits, async);
	}
}
