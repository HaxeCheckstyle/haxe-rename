package refactor.refactor;

class RefactorExtractConstructorParams extends RefactorTestBase {
	function setupClass() {
		setupTestSources(["testcases/constructor"]);
	}

	function testFailExtractParamsNotConstructor(async:Async) {
		failCanRefactor(RefactorExtractConstructorParams, {fileName: "testcases/constructor/Point.hx", posStart: 148, posEnd: 148}, "unsupported");
		failRefactor(RefactorExtractConstructorParams, {fileName: "testcases/constructor/Point.hx", posStart: 148, posEnd: 148},
			"failed to collect extract method data", async);
	}

	function testExtractParamsEmptyNew(async:Async) {
		failCanRefactor(RefactorExtractConstructorParams, {fileName: "testcases/constructor/Point.hx", posStart: 247, posEnd: 247}, "unsupported");
		failRefactor(RefactorExtractConstructorParams, {fileName: "testcases/constructor/Point.hx", posStart: 247, posEnd: 247},
			"failed to collect extract method data", async);
	}

	function testExtractParamsYAndText(async:Async) {
		var edits:Array<TestEdit> = [
			makeInsertTestEdit("testcases/constructor/Point.hx", "final z:Int;\nfinal text:String;\n", 39, Format(1)),
			makeInsertTestEdit("testcases/constructor/Point.hx", "this.z = z;\nthis.text = text;\n", 109, Format(2)),
		];
		checkRefactor(RefactorExtractConstructorParams, {fileName: "testcases/constructor/Point.hx", posStart: 58, posEnd: 58}, edits, async);
	}

	function testExtractParamsMain(async:Async) {
		var edits:Array<TestEdit> = [
			makeInsertTestEdit("testcases/constructor/Point.hx", "final x:Int;\n", 275, Format(1)),
			makeInsertTestEdit("testcases/constructor/Point.hx", "this.x = x;\n", 304, Format(2)),
		];
		checkRefactor(RefactorExtractConstructorParams, {fileName: "testcases/constructor/Point.hx", posStart: 294, posEnd: 294}, edits, async);
	}
}
