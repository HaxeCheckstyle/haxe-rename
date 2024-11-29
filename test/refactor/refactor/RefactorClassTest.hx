package refactor.refactor;

class RefactorClassTest extends RefactorTestBase {
	function setupClass() {
		setupTestSources(["testcases/classes"]);
	}

	function testFailExtractTypChildClass(async:Async) {
		failCanRefactor(RefactorExtractType, {fileName: "testcases/classes/ChildClass.hx", posStart: 30, posEnd: 30}, "unsupported");
		failRefactor(RefactorExtractType, {fileName: "testcases/classes/ChildClass.hx", posStart: 30, posEnd: 30}, "failed to collect extract type data",
			async);
	}

	function testFailExtractInterfaceNoClass(async:Async) {
		failCanRefactor(RefactorExtractInterface, {fileName: "testcases/classes/ChildClass.hx", posStart: 875, posEnd: 875}, "unsupported");
		failRefactor(RefactorExtractInterface, {fileName: "testcases/classes/ChildClass.hx", posStart: 875, posEnd: 875},
			"failed to collect extract interface data", async);
	}

	function testExtractTypeListOfChilds(async:Async) {
		var edits:Array<TestEdit> = [
			makeRemoveTestEdit("testcases/classes/ChildClass.hx", 860, 901),
			makeCreateTestEdit("testcases/classes/ListOfChilds.hx"),
			makeInsertTestEdit("testcases/classes/ListOfChilds.hx", "package classes;\n\ntypedef ListOfChilds = Array<ChildClass>;", 0, true),
			makeInsertTestEdit("testcases/classes/pack/UseChild.hx", "import classes.ListOfChilds;\n", 23),
		];
		checkRefactor(RefactorExtractType, {fileName: "testcases/classes/ChildClass.hx", posStart: 873, posEnd: 873}, edits, async);
	}

	function testExtractTypeTextLoader(async:Async) {
		var edits:Array<TestEdit> = [
			makeRemoveTestEdit("testcases/classes/Printer.hx", 1262, 1397),
			makeCreateTestEdit("testcases/classes/TextLoader.hx"),
			makeInsertTestEdit("testcases/classes/TextLoader.hx",
				"package classes;\n\n"
				+ "import js.lib.Promise;\n\n"
				+ "class TextLoader {\n"
				+ "	public function new() {}\n\n"
				+ "	public function load(text:String):Promise<String> {\n"
				+ "		return Promise.resolve(text);\n"
				+ "	}\n"
				+ "}",
				0, true),
			makeInsertTestEdit("testcases/classes/pack/UsePrinter.hx", "import classes.TextLoader;\n", 23),
		];
		checkRefactor(RefactorExtractType, {fileName: "testcases/classes/Printer.hx", posStart: 1273, posEnd: 1283}, edits, async);
	}

	function testExtractTypeContextWithDocComment(async:Async) {
		var edits:Array<TestEdit> = [
			makeCreateTestEdit("testcases/classes/Context.hx"),
			makeInsertTestEdit("testcases/classes/Context.hx",
				"package classes;\n\n"
				+ "using classes.ChildHelper;\n"
				+ "using classes.pack.SecondChildHelper;\n\n"
				+ "/**\n"
				+ " * Context class\n"
				+ " */\n"
				+ "class Context {\n"
				+ "	public static var printFunc:PrintFunc;\n"
				+ "}",
				0, true),
			makeRemoveTestEdit("testcases/classes/StaticUsing.hx", 484, 566),
		];
		checkRefactor(RefactorExtractType, {fileName: "testcases/classes/StaticUsing.hx", posStart: 518, posEnd: 518}, edits, async);
	}

	function testExtractTypeNotDocModule(async:Async) {
		var edits:Array<TestEdit> = [
			makeRemoveTestEdit("testcases/classes/DocModule.hx", 62, 110),
			makeReplaceTestEdit("testcases/classes/ForceRenameCrash.hx", "classes.NotDocModule", 86, 116),
			makeCreateTestEdit("testcases/classes/NotDocModule.hx"),
			makeInsertTestEdit("testcases/classes/NotDocModule.hx",
				"/**\n"
				+ " * file header\n"
				+ " */\n\n"
				+ "package classes;\n\n"
				+ "class NotDocModule {\n"
				+ "	public function new() {}\n"
				+ "}", 0, true),
			makeInsertTestEdit("testcases/classes/pack/UseDocModule.hx", "import classes.NotDocModule;\n", 23),
		];
		checkRefactor(RefactorExtractType, {fileName: "testcases/classes/DocModule.hx", posStart: 73, posEnd: 73}, edits, async);
	}

	function testExtractInterfaceBaseClass(async:Async) {
		var edits:Array<TestEdit> = [
			makeInsertTestEdit("testcases/classes/BaseClass.hx", " implements IBaseClass", 33),
			makeCreateTestEdit("testcases/classes/IBaseClass.hx"),
			makeInsertTestEdit("testcases/classes/IBaseClass.hx",
				"package classes;\n\n"
				+ "interface IBaseClass {\n"
				+ "	function doSomething(data:Array<String>):Void;\n"
				+ "	function doSomething3(d:Array<String>):Void;\n"
				+ "	function doSomething4(d:Array<String>):Void;\n"
				+ "	function doSomething5(d:Array<String>):Void;\n"
				+ "	function doSomething6(d:Array<String>):Void;\n"
				+ "}",
				0, true),
		];
		checkRefactor(RefactorExtractInterface, {fileName: "testcases/classes/BaseClass.hx", posStart: 27, posEnd: 27}, edits, async);
	}
}
