package refactor.refactor;

class RefactorExtractTypeTest extends RefactorTestBase {
	function setupClass() {
		setupTestSources(["testcases/classes", "testcases/typedefs"]);
	}

	function testFailExtractTypeChildClass(async:Async) {
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
			makeRemoveTestEdit("testcases/classes/StaticUsing.hx", 555, 637),
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

	function testExtractTypeUserConfig(async:Async) {
		var edits:Array<TestEdit> = [
			makeRemoveTestEdit("testcases/typedefs/Types.hx", 247, 811),
			makeCreateTestEdit("testcases/typedefs/UserConfig.hx"),
			makeInsertTestEdit("testcases/typedefs/UserConfig.hx",
				"package typedefs;\n\n"
				+ "import haxe.extern.EitherType;\n\n"
				+ "typedef UserConfig = {\n"
				+ "	var enableCodeLens:Bool;\n"
				+ "	var enableDiagnostics:Bool;\n"
				+ "	var enableServerView:Bool;\n"
				+ "	var enableSignatureHelpDocumentation:Bool;\n"
				+ "	var diagnosticsPathFilter:String;\n"
				+ "	var displayPort:EitherType<Int, String>;\n"
				+ "	var buildCompletionCache:Bool;\n"
				+ "	var enableCompletionCacheWarning:Bool;\n"
				+ "	var useLegacyCompletion:Bool;\n"
				+ "	var codeGeneration:CodeGenerationConfig;\n"
				+ "	var exclude:Array<String>;\n"
				+ "	var postfixCompletion:PostfixCompletionConfig;\n"
				+ "	var importsSortOrder:ImportsSortOrderConfig;\n"
				+ "	var maxCompletionItems:Int;\n"
				+ "	var renameSourceFolders:Array<String>;\n"
				+ "}",
				0, Format(0, false)),
		];
		checkRefactor(RefactorExtractType, {fileName: "testcases/typedefs/Types.hx", posStart: 260, posEnd: 260}, edits, async);
	}
}
