package refactor.refactor;

class RefactorClassTest extends RefactorTestBase {
	function setupClass() {
		setupTestSources(["testcases/classes"]);
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
