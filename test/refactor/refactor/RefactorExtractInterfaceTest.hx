package refactor.refactor;

class RefactorExtractInterfaceTest extends RefactorTestBase {
	function setupClass() {
		setupTestSources(["testcases/classes"]);
	}

	function testFailExtractInterfaceNoClass(async:Async) {
		failCanRefactor(RefactorExtractInterface, {fileName: "testcases/classes/ChildClass.hx", posStart: 875, posEnd: 875}, "unsupported");
		failRefactor(RefactorExtractInterface, {fileName: "testcases/classes/ChildClass.hx", posStart: 875, posEnd: 875},
			"failed to collect data for extract interface", async);
	}

	function testExtractInterfaceBaseClass(async:Async) {
		var edits:Array<TestEdit> = [
			makeInsertTestEdit("testcases/classes/BaseClass.hx", " implements IBaseClass", 33),
			makeCreateTestEdit("testcases/classes/IBaseClass.hx"),
			makeInsertTestEdit("testcases/classes/IBaseClass.hx",
				"package classes;\n\n"
				+ "interface IBaseClass {\n"
				+ "function doSomething(data:Array<String>):Void;\n"
				+ "function doSomething3(d:Array<String>):Void;\n"
				+ "function doSomething4(d:Array<String>):Void;\n"
				+ "function doSomething5(d:Array<String>):Void;\n"
				+ "function doSomething6(d:Array<String>):Bool;\n"
				+ "}",
				0, Format(0, false)),
		];
		addTypeHint("testcases/classes/BaseClass.hx", 131, LibType("Void", "Void", []));
		addTypeHint("testcases/classes/BaseClass.hx", 225, LibType("Void", "Void", []));
		addTypeHint("testcases/classes/BaseClass.hx", 296, LibType("Void", "Void", []));
		addTypeHint("testcases/classes/BaseClass.hx", 384, LibType("Void", "Void", []));
		addTypeHint("testcases/classes/BaseClass.hx", 468, LibType("Bool", "Bool", []));
		checkRefactor(RefactorExtractInterface, {fileName: "testcases/classes/BaseClass.hx", posStart: 27, posEnd: 27}, edits, async);
	}

	function testExtractInterfaceCommentedTest(async:Async) {
		var edits:Array<TestEdit> = [
			makeInsertTestEdit("testcases/classes/CommentedTest.hx", " implements ICommentedTest", 37),
			makeCreateTestEdit("testcases/classes/ICommentedTest.hx"),
			makeInsertTestEdit("testcases/classes/ICommentedTest.hx",
				"package classes;\n\n"
				+ "interface ICommentedTest {\n"
				+ "/**\n"
				+ "\t\t[Description]\n"
				+ "\t**/\n"
				+ "\t function run():Void;\n"
				+ "/**\n"
				+ "\t\t[Description]\n"
				+ "\t**/\n"
				+ "\t function run2():Int;\n"
				+ "}",
				0, Format(0, false)),

		];
		addTypeHint("testcases/classes/CommentedTest.hx", 85, LibType("Void", "Void", []));
		checkRefactor(RefactorExtractInterface, {fileName: "testcases/classes/CommentedTest.hx", posStart: 30, posEnd: 30}, edits, async);
	}
}
