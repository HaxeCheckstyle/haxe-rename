package refactor.refactor;

class RefactorClassTest extends RefactorTestBase {
	function setupClass() {
		setupTestSources(["testcases/classes"]);
	}

	// Extract Type

	function testFailExtractTypChildClass(async:Async) {
		failCanRefactor(RefactorExtractType, {fileName: "testcases/classes/ChildClass.hx", posStart: 30, posEnd: 30}, "unsupported");
		failRefactor(RefactorExtractType, {fileName: "testcases/classes/ChildClass.hx", posStart: 30, posEnd: 30}, "failed to collect data for extract type",
			async);
	}

	function testExtractTypeListOfChilds(async:Async) {
		var edits:Array<TestEdit> = [
			makeRemoveTestEdit("testcases/classes/ChildClass.hx", 860, 901),
			makeCreateTestEdit("testcases/classes/ListOfChilds.hx"),
			makeInsertTestEdit("testcases/classes/ListOfChilds.hx", "package classes;\n\ntypedef ListOfChilds = Array<ChildClass>;", 0, Format(0, false)),
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
				0, Format(0, false)),
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
				0, Format(0, false)),
			makeRemoveTestEdit("testcases/classes/StaticUsing.hx", 557, 639),
		];
		checkRefactor(RefactorExtractType, {fileName: "testcases/classes/StaticUsing.hx", posStart: 590, posEnd: 590}, edits, async);
	}

	function testExtractTypeNotDocModule(async:Async) {
		var edits:Array<TestEdit> = [
			makeRemoveTestEdit("testcases/classes/DocModule.hx", 62, 169),
			makeReplaceTestEdit("testcases/classes/ForceRenameCrash.hx", "classes.NotDocModule", 86, 116),
			makeCreateTestEdit("testcases/classes/NotDocModule.hx"),
			makeInsertTestEdit("testcases/classes/NotDocModule.hx",
				"/**\n"
				+ " * file header\n"
				+ " */\n\n"
				+ "package classes;\n\n"
				+ "class NotDocModule {\n"
				+ "	public function new() {}\n\n"
				+ "	public function doSomething() {\n"
				+ "		trace(\"something\");\n"
				+ "	}\n"
				+ "}",
				0, Format(0, false)),
			makeInsertTestEdit("testcases/classes/pack/UseDocModule.hx", "import classes.NotDocModule;\n", 23),
		];
		checkRefactor(RefactorExtractType, {fileName: "testcases/classes/DocModule.hx", posStart: 73, posEnd: 73}, edits, async);
	}

	// Extract Interface

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

	// Rewrite Finals to Vars

	function testRewriteFinalsToVarsJsonClass(async:Async) {
		failCanRefactor(RefactorRewriteVarsToFinals(false), {fileName: "testcases/classes/JsonClass.hx", posStart: 18, posEnd: 696}, "unsupported");
		failRefactor(RefactorRewriteVarsToFinals(false), {fileName: "testcases/classes/JsonClass.hx", posStart: 18, posEnd: 696},
			"failed to collect data for rewrite vars/finals", async);
	}

	function testRewriteFinalsToVarsPrinter(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/Printer.hx", "var", 147, 152, NoFormat),
			makeReplaceTestEdit("testcases/classes/Printer.hx", "var", 225, 230, NoFormat),
		];
		checkRefactor(RefactorRewriteVarsToFinals(false), {fileName: "testcases/classes/Printer.hx", posStart: 129, posEnd: 1079}, edits, async);
	}

	// Rewrite Vars To Finals

	function testRewriteVarsToFinalsPrinter(async:Async) {
		failCanRefactor(RefactorRewriteVarsToFinals(true), {fileName: "testcases/classes/Printer.hx", posStart: 129, posEnd: 1079}, "unsupported");
		failRefactor(RefactorRewriteVarsToFinals(true), {fileName: "testcases/classes/Printer.hx", posStart: 129, posEnd: 1079},
			"failed to collect data for rewrite vars/finals", async);
	}

	function testRewriteVarsToFinalsJsonClass(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "final", 37, 40, NoFormat),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "final", 50, 53, NoFormat),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "final", 68, 71, NoFormat),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "final", 84, 87, NoFormat),
			makeReplaceTestEdit("testcases/classes/JsonClass.hx", "final", 301, 304, NoFormat),
		];
		checkRefactor(RefactorRewriteVarsToFinals(true), {fileName: "testcases/classes/JsonClass.hx", posStart: 18, posEnd: 696}, edits, async);
	}

	// Wrap with Try…Catch

	function testFailTryCatchCollectDataEmptyFile(async:Async) {
		failCanRefactor(RefactorRewriteWrapWithTryCatch, {fileName: "testcases/classes/BaseClass.hx", posStart: 156, posEnd: 263}, "unsupported");
		failRefactor(RefactorRewriteWrapWithTryCatch, {fileName: "testcases/classes/BaseClass.hx", posStart: 156, posEnd: 263},
			"failed to collect data for rewrite wrap with try catch", async);
	}

	function testRewriteWrapTryCatchJsonClass(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/classes/JsonClass.hx",
				"try {\n"
				+ "var newgroup:Null<JsonClass> = new JsonClass(group.id, group.type, group.width);\n"
				+ "		newgroup.id = group.id;\n"
				+ "		newgroup.type = group.type;\n"
				+ "		newgroup.width = group.width;\n"
				+ "		newgroup.maxWidth = group.maxWidth;\n\n"
				+ "		return newgroup;\n"
				+ "}\n"
				+ "catch (e:haxe.Exception) {\n"
				+ "// TODO: handle exception\n"
				+ "trace (e.details());\n"
				+ "}",
				301, 527, Format(2, true)),
		];
		checkRefactor(RefactorRewriteWrapWithTryCatch, {fileName: "testcases/classes/JsonClass.hx", posStart: 300, posEnd: 527}, edits, async);
	}
}
