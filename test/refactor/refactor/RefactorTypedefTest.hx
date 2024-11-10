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
				+ "\tvar enableCodeLens:Bool;\n"
				+ "\tvar enableDiagnostics:Bool;\n"
				+ "\tvar enableServerView:Bool;\n"
				+ "\tvar enableSignatureHelpDocumentation:Bool;\n"
				+ "\tvar diagnosticsPathFilter:String;\n"
				+ "\tvar displayPort:EitherType<Int, String>;\n"
				+ "\tvar buildCompletionCache:Bool;\n"
				+ "\tvar enableCompletionCacheWarning:Bool;\n"
				+ "\tvar useLegacyCompletion:Bool;\n"
				+ "\tvar codeGeneration:CodeGenerationConfig;\n"
				+ "\tvar exclude:Array<String>;\n"
				+ "\tvar postfixCompletion:PostfixCompletionConfig;\n"
				+ "\tvar importsSortOrder:ImportsSortOrderConfig;\n"
				+ "\tvar maxCompletionItems:Int;\n"
				+ "\tvar renameSourceFolders:Array<String>;\n"
				+ "}",
				0, true),
		];
		checkRefactor(RefactorExtractType, {fileName: "testcases/typedefs/Types.hx", posStart: 260, posEnd: 260}, edits, async);
	}
}
