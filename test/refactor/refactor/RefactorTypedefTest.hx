package refactor.refactor;

class RefactorTypedefTest extends RefactorTestBase {
	function setupClass() {
		setupTestSources(["testcases/typedefs"]);
	}

	function testExtractTypeListOfChilds(async:Async) {
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

	function testRewriteVarsToFinalsTestFormatterInputData(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/typedefs/codedata/TestFormatterInputData.hx", "final", 257, 260, NoFormat),
			makeReplaceTestEdit("testcases/typedefs/codedata/TestFormatterInputData.hx", "final", 297, 300, NoFormat),
			makeReplaceTestEdit("testcases/typedefs/codedata/TestFormatterInputData.hx", "final", 334, 337, NoFormat),
			makeReplaceTestEdit("testcases/typedefs/codedata/TestFormatterInputData.hx", "final", 382, 385, NoFormat),
			makeReplaceTestEdit("testcases/typedefs/codedata/TestFormatterInputData.hx", "final", 420, 423, NoFormat),
			makeReplaceTestEdit("testcases/typedefs/codedata/TestFormatterInputData.hx", "final", 452, 455, NoFormat),
		];
		checkRefactor(RefactorRewriteVarsToFinals(true), {fileName: "testcases/typedefs/codedata/TestFormatterInputData.hx", posStart: 245, posEnd: 473},
			edits, async);
	}

	function testRewriteFinalsToVarsTestFormatterInputData(async:Async) {
		failCanRefactor(RefactorRewriteVarsToFinals(false), {fileName: "testcases/typedefs/codedata/TestFormatterInputData.hx", posStart: 245, posEnd: 473},
			"unsupported");
		failRefactor(RefactorRewriteVarsToFinals(false), {fileName: "testcases/typedefs/codedata/TestFormatterInputData.hx", posStart: 245, posEnd: 473},
			"failed to collect data for rewrite vars/finals", async);
	}
}
