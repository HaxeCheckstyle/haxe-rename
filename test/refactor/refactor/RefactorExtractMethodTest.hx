package refactor.refactor;

class RefactorExtractMethodTest extends RefactorTestBase {
	function setupClass() {
		setupTestSources(["testcases/methods"]);
	}

	function testSimpleNoReturns(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "noReturnsExtract();\n", 94, 131, true),
			makeInsertTestEdit("testcases/methods/Main.hx",
				"function noReturnsExtract():Void {\n"
				+ "trace(\"hello 2\");\n"
				+ "\t\ttrace(\"hello 3\");\n"
				+ "}\n", 155, true),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 93, posEnd: 131}, edits, async);
	}

	function testSimpleNoReturnsStatic(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "noReturnsStaticExtract();\n", 222, 259, true),
			makeInsertTestEdit("testcases/methods/Main.hx",
				"static function noReturnsStaticExtract():Void {\n"
				+ "trace(\"hello 2\");\n"
				+ "\t\ttrace(\"hello 3\");\n"
				+ "}\n", 283, true),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 221, posEnd: 259}, edits, async);
	}

	function testEmptyReturns(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "if (!emptyReturnsExtract(cond1, cond2)) {\n" + "return;\n" + "}\n", 342, 439, true),
			makeInsertTestEdit("testcases/methods/Main.hx",
				"function emptyReturnsExtract(cond1:Bool, cond2:Bool):Bool {\n"
				+ "if (cond1) {\n"
				+ "\t\t\treturn false;\n"
				+ "\t\t}\n"
				+ "\t\tif (cond2) {\n"
				+ "\t\t\treturn false;\n"
				+ "\t\t}\n"
				+ "\t\ttrace(\"hello 1\");\n"
				+ "\t\ttrace(\"hello 2\");\n"
				+ "return true;\n"
				+ "}\n",
				483, true),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 341, posEnd: 439}, edits, async);
	}

	function testCalculateTotal(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "total = calculateTotalExtract(items, total);\n", 569, 720, true),
			makeInsertTestEdit("testcases/methods/Main.hx",
				"function calculateTotalExtract(items:Array<Item>, total:Float):Float {\n"
				+ "// Selected code block to extract\n"
				+ "\t\tfor (item in items) {\n"
				+ "\t\t\tvar price = item.price;\n"
				+ "\t\t\tvar quantity = item.quantity;\n"
				+ "\t\t\ttotal += price * quantity;\n"
				+ "\t\t}\n"
				+ "return total;\n"
				+ "}\n",
				741, true),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 568, posEnd: 720}, edits, async);
	}

	function testProcessUser(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "processUserExtract(name, age);\n", 844, 980, true),
			makeInsertTestEdit("testcases/methods/Main.hx",
				"function processUserExtract(name:String, age:Int):Void {\n"
				+ "// Selected code block to extract\n"
				+ "\t\tvar greeting = \"Hello, \" + name;\n"
				+ "\t\tif (age < 18) {\n"
				+ "\t\t\tgreeting += \" (minor)\";\n"
				+ "\t\t}\n"
				+ "\t\ttrace(greeting);\n"
				+ "}\n",
				994, true),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 843, posEnd: 980}, edits, async);
	}
}
