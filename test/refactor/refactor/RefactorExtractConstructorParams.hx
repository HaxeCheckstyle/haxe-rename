package refactor.refactor;

class RefactorExtractConstructorParams extends RefactorTestBase {
	function setupClass() {
		setupTestSources(["testcases/constructor"]);
	}

	function testFailExtractParamsNotConstructor(async:Async) {
		failCanRefactor(RefactorExtractConstructorParams(false), {fileName: "testcases/constructor/Point.hx", posStart: 148, posEnd: 148}, "unsupported");
		failRefactor(RefactorExtractConstructorParams(false), {fileName: "testcases/constructor/Point.hx", posStart: 148, posEnd: 148},
			"failed to collect extract method data", async);
		failCanRefactor(RefactorExtractConstructorParams(true), {fileName: "testcases/constructor/Point.hx", posStart: 148, posEnd: 148}, "unsupported");
		failRefactor(RefactorExtractConstructorParams(true), {fileName: "testcases/constructor/Point.hx", posStart: 148, posEnd: 148},
			"failed to collect extract method data", async);
	}

	function testExtractParamsEmptyNew(async:Async) {
		failCanRefactor(RefactorExtractConstructorParams(false), {fileName: "testcases/constructor/Point.hx", posStart: 247, posEnd: 247}, "unsupported");
		failRefactor(RefactorExtractConstructorParams(false), {fileName: "testcases/constructor/Point.hx", posStart: 247, posEnd: 247},
			"failed to collect extract method data", async);
		failCanRefactor(RefactorExtractConstructorParams(true), {fileName: "testcases/constructor/Point.hx", posStart: 247, posEnd: 247}, "unsupported");
		failRefactor(RefactorExtractConstructorParams(true), {fileName: "testcases/constructor/Point.hx", posStart: 247, posEnd: 247},
			"failed to collect extract method data", async);
	}

	function testExtractParamsYAndTextAsVar(async:Async) {
		var edits:Array<TestEdit> = [
			makeInsertTestEdit("testcases/constructor/Point.hx", "var z:Int;\nvar text:String;\n", 39, Format(1, false)),
			makeInsertTestEdit("testcases/constructor/Point.hx", "this.z = z;\nthis.text = text;\n", 109, Format(2, false)),
		];
		checkRefactor(RefactorExtractConstructorParams(false), {fileName: "testcases/constructor/Point.hx", posStart: 58, posEnd: 58}, edits, async);
	}

	function testExtractParamsMainAsVar(async:Async) {
		var edits:Array<TestEdit> = [
			makeInsertTestEdit("testcases/constructor/Point.hx", "var x:Int;\n", 275, Format(1, false)),
			makeInsertTestEdit("testcases/constructor/Point.hx", "this.x = x;\n", 304, Format(2, false)),
		];
		checkRefactor(RefactorExtractConstructorParams(false), {fileName: "testcases/constructor/Point.hx", posStart: 294, posEnd: 294}, edits, async);
	}

	function testExtractParamsYAndTextAsFinal(async:Async) {
		var edits:Array<TestEdit> = [
			makeInsertTestEdit("testcases/constructor/Point.hx", "final z:Int;\nfinal text:String;\n", 39, Format(1, false)),
			makeInsertTestEdit("testcases/constructor/Point.hx", "this.z = z;\nthis.text = text;\n", 109, Format(2, false)),
		];
		checkRefactor(RefactorExtractConstructorParams(true), {fileName: "testcases/constructor/Point.hx", posStart: 58, posEnd: 58}, edits, async);
	}

	function testExtractParamsMainAsFinal(async:Async) {
		var edits:Array<TestEdit> = [
			makeInsertTestEdit("testcases/constructor/Point.hx", "final x:Int;\n", 275, Format(1, false)),
			makeInsertTestEdit("testcases/constructor/Point.hx", "this.x = x;\n", 304, Format(2, false)),
		];
		checkRefactor(RefactorExtractConstructorParams(true), {fileName: "testcases/constructor/Point.hx", posStart: 294, posEnd: 294}, edits, async);
	}
}
