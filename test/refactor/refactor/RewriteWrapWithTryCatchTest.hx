package refactor.refactor;

class RewriteWrapWithTryCatchTest extends RefactorTestBase {
	function setupClass() {
		setupTestSources(["testcases/classes"]);
	}

	function testFailTryCatchCollectDataEmptyFile(async:Async) {
		failCanRefactor(RefactorRewriteWrapWithTryCatch, {fileName: "testcases/classes/BaseClass.hx", posStart: 156, posEnd: 263}, "unsupported");
		failRefactor(RefactorRewriteWrapWithTryCatch, {fileName: "testcases/classes/BaseClass.hx", posStart: 156, posEnd: 263},
			"failed to collect data for rewrite wrap with try catch", async);
	}

	function testFailTryCatchCollectDataReversedPos(async:Async) {
		failCanRefactor(RefactorRewriteWrapWithTryCatch, {fileName: "testcases/classes/BaseClass.hx", posStart: 263, posEnd: 156}, "unsupported");
		failRefactor(RefactorRewriteWrapWithTryCatch, {fileName: "testcases/classes/BaseClass.hx", posStart: 263, posEnd: 156},
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
