package refactor.refactor;

class RewriteFinalsToVarsTest extends RefactorTestBase {
	function setupClass() {
		setupTestSources(["testcases/classes"]);
	}

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
}
