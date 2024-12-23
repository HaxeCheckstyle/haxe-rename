package refactor.refactor;

class RewriteVarsToFinalsTest extends RefactorTestBase {
	function setupClass() {
		setupTestSources(["testcases/classes", "testcases/typedefs"]);
	}

	function testRewriteVarsToFinalsPrinter(async:Async) {
		failCanRefactor(RefactorRewriteVarsToFinals(true), {fileName: "testcases/classes/Printer.hx", posStart: 129, posEnd: 1079}, "unsupported");
		failRefactor(RefactorRewriteVarsToFinals(true), {fileName: "testcases/classes/Printer.hx", posStart: 129, posEnd: 1079},
			"failed to collect data for rewrite vars/finals", async);
	}

	function testRewriteVarsToFinalsPrinterReversedPos(async:Async) {
		failCanRefactor(RefactorRewriteVarsToFinals(true), {fileName: "testcases/classes/Printer.hx", posStart: 1079, posEnd: 129}, "unsupported");
		failRefactor(RefactorRewriteVarsToFinals(true), {fileName: "testcases/classes/Printer.hx", posStart: 1079, posEnd: 129},
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
