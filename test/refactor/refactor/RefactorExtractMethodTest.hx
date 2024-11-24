package refactor.refactor;

class RefactorExtractMethodTest extends RefactorTestBase {
	function setupClass() {
		setupTestSources(["testcases/methods"]);
	}

	function testSimpleNoReturns(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "noReturnsExtract();\n", 94, 131, true),
			makeInsertTestEdit("testcases/methods/Main.hx", "function noReturnsExtract() {\n"
				+ "trace(\"hello 2\");\n"
				+ "		trace(\"hello 3\");\n"
				+ "}\n",
				155, true),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 93, posEnd: 131}, edits, async);
	}

	function testSimpleNoReturnsStatic(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "noReturnsStaticExtract();\n", 222, 259, true),
			makeInsertTestEdit("testcases/methods/Main.hx",
				"static function noReturnsStaticExtract() {\n"
				+ "trace(\"hello 2\");\n"
				+ "		trace(\"hello 3\");\n"
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
				+ "			return false;\n"
				+ "		}\n"
				+ "		if (cond2) {\n"
				+ "			return false;\n"
				+ "		}\n"
				+ "		trace(\"hello 1\");\n"
				+ "		trace(\"hello 2\");\n"
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
				+ "		for (item in items) {\n"
				+ "			var price = item.price;\n"
				+ "			var quantity = item.quantity;\n"
				+ "			total += price * quantity;\n"
				+ "		}\n"
				+ "return total;\n"
				+ "}\n",
				741, true),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 568, posEnd: 720}, edits, async);
	}

	function testCalculateTotalWithLastReturn(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "return calculateTotalExtract(items, total);\n", 569, 737, true),
			makeInsertTestEdit("testcases/methods/Main.hx",
				"function calculateTotalExtract(items:Array<Item>, total:Float):Float {\n"
				+ "// Selected code block to extract\n"
				+ "		for (item in items) {\n"
				+ "			var price = item.price;\n"
				+ "			var quantity = item.quantity;\n"
				+ "			total += price * quantity;\n"
				+ "		}\n"
				+ "\n"
				+ "		return total;\n"
				+ "}\n",
				741, true),
		];
		addTypeHint("testcases/methods/Main.hx", 735, LibType("Float", "Float", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 568, posEnd: 737}, edits, async);
	}

	function testProcessUserWithLastReturn(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "return calculateTotal2Extract(items, total);\n", 1081, 1295, true),
			makeInsertTestEdit("testcases/methods/Main.hx",
				"function calculateTotal2Extract(items:Array<Item>, total:Float) {\n"
				+ "// Selected code block to extract\n"
				+ "		for (item in items) {\n"
				+ "			var price = item.price;\n"
				+ "			var quantity = item.quantity;\n"
				+ "			if (quantity < 0) {\n"
				+ "				return total;\n"
				+ "			}\n"
				+ "			total += price * quantity;\n"
				+ "		}\n\n"
				+ "		return total;\n"
				+ "}\n",
				1299, true),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 1080, posEnd: 1295}, edits, async);
	}

	function testProcessUserWithUseAfterSelection(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx",
				"{\n"
				+ "final result = calculateTotal2Extract(items, total);\n"
				+ "switch (result.ret) {\n"
				+ "case Some(data):\n"
				+ "return data;\n"
				+ "case None:\n"
				+ "total = result.data;\n"
				+ "}\n"
				+ "}\n",
				1081, 1278, true),
			makeInsertTestEdit("testcases/methods/Main.hx",
				"function calculateTotal2Extract(items:Array<Item>, total:Float):{ret:haxe.ds.Option<Float>, ?data:Float} {\n"
				+ "// Selected code block to extract\n"
				+ "		for (item in items) {\n"
				+ "			var price = item.price;\n"
				+ "			var quantity = item.quantity;\n"
				+ "			if (quantity < 0) {\n"
				+ "				return {ret: Some(total)};\n"
				+ "			}\n"
				+ "			total += price * quantity;\n"
				+ "		}\n"
				+ "return {ret: None, data: total};\n"
				+ "}\n",
				1299, true),
		];
		addTypeHint("testcases/methods/Main.hx", 1026, FunctionType([LibType("Array", "Array", [LibType("Item", "Item", [])])], LibType("Float", "Float", [])));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 1080, posEnd: 1278}, edits, async);
	}

	function testCalculateMath(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Math.hx", "calculateExtract(a, b);\n", 106, 122, true),
			makeInsertTestEdit("testcases/methods/Math.hx", "function calculateExtract(a:Int, b:Int):Int {\n"
				+ "return a * b + (a - b);\n"
				+ "}\n", 143, true),
		];
		addTypeHint("testcases/methods/Math.hx", 71, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/Math.hx", 84, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/Math.hx", 102, LibType("Int", "Int", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Math.hx", posStart: 106, posEnd: 122}, edits, async);
	}

	function testCalculateMathWithVar(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Math.hx", "var result = calculateExtract(a, b);\n", 93, 122, true),
			makeInsertTestEdit("testcases/methods/Math.hx",
				"function calculateExtract(a:Int, b:Int):Int {\n"
				+ "var result = a * b + (a - b);\n"
				+ "return result;\n"
				+ "}\n", 143, true),
		];
		addTypeHint("testcases/methods/Math.hx", 71, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/Math.hx", 84, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/Math.hx", 102, LibType("Int", "Int", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Math.hx", posStart: 93, posEnd: 122}, edits, async);
	}

	function testNameProcessor(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/NameProcessor.hx", "var upperNames = processExtract(names);\n", 113, 201, true),
			makeInsertTestEdit("testcases/methods/NameProcessor.hx",
				"function processExtract(names:Array<String>):Array<?> {\n"
				+ "var upperNames = [];\n"
				+ "		for (name in names) {\n"
				+ "			upperNames.push(name.toUpperCase());\n"
				+ "		}\n"
				+ "return upperNames;\n"
				+ "}\n",
				226, true),
		];
		addTypeHint("testcases/methods/NameProcessor.hx", 82, LibType("Array", "Array", [LibType("String", "String", [])]));
		addTypeHint("testcases/methods/NameProcessor.hx", 126, LibType("Array", "Array", [UnknownType("?")]));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/NameProcessor.hx", posStart: 112, posEnd: 201}, edits, async);
	}

	function testArrayHandler(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/ArrayHandler.hx", "var sum = handleExtract(numbers);\n", 105, 157, true),
			makeInsertTestEdit("testcases/methods/ArrayHandler.hx",
				"function handleExtract(numbers:Array<Int>):Int {\n"
				+ "var sum = 0;\n"
				+ "		for (n in numbers) {\n"
				+ "			sum += n;\n"
				+ "		}\n"
				+ "return sum;\n"
				+ "}\n",
				175, true),
		];
		addTypeHint("testcases/methods/ArrayHandler.hx", 82, LibType("Array", "Array", [LibType("Int", "Int", [])]));
		addTypeHint("testcases/methods/ArrayHandler.hx", 111, LibType("Int", "Int", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/ArrayHandler.hx", posStart: 104, posEnd: 157}, edits, async);
	}

	function testAgeChecker(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/AgeChecker.hx", "message = checkExtract(age, message);\n", 105, 179, true),
			makeInsertTestEdit("testcases/methods/AgeChecker.hx",
				"function checkExtract(age:Int, message:String):String {\n"
				+ "if (age < 18) {\n"
				+ "			message = \"Minor\";\n"
				+ "		} else {\n"
				+ "			message = \"Adult\";\n"
				+ "		}\n"
				+ "return message;\n"
				+ "}\n",
				201, true),
		];
		addTypeHint("testcases/methods/AgeChecker.hx", 75, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/AgeChecker.hx", 95, LibType("String", "String", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/AgeChecker.hx", posStart: 104, posEnd: 179}, edits, async);
	}

	function testPersonHandler(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/PersonHandler.hx", "handleExtract(person);\n", 113, 161, true),
			makeInsertTestEdit("testcases/methods/PersonHandler.hx",
				"function handleExtract(person:Any) {\n" + "return \"Name: \" + person.name + \", Age: \" + person.age;\n" + "}\n", 180, true),
		];
		addTypeHint("testcases/methods/PersonHandler.hx", 75, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/PersonHandler.hx", 95, LibType("String", "String", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/PersonHandler.hx", posStart: 113, posEnd: 161}, edits, async);
	}

	function testPersonHandlerWithVar(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/PersonHandler.hx", "var info = handleExtract(person);\n", 102, 161, true),
			makeInsertTestEdit("testcases/methods/PersonHandler.hx",
				"function handleExtract(person:Any) {\n"
				+ "var info = \"Name: \" + person.name + \", Age: \" + person.age;\n"
				+ "return info;\n"
				+ "}\n",
				180, true),
		];
		addTypeHint("testcases/methods/PersonHandler.hx", 75, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/PersonHandler.hx", 95, LibType("String", "String", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/PersonHandler.hx", posStart: 101, posEnd: 161}, edits, async);
	}

	function testContainer(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Container.hx", "var result = processExtract(items, converter);\n", 108, 239, true),
			makeInsertTestEdit("testcases/methods/Container.hx",
				"function processExtract(items:Array<T>, converter:T -> String):Array<String> {\n"
				+ "var result = new Array<String>();\n"
				+ "		for (item in items) {\n"
				+ "			var converted = converter(item);\n"
				+ "			result.push('[${converted}]');\n"
				+ "		}\n"
				+ "return result;\n"
				+ "}\n",
				260, true),
		];
		addTypeHint("testcases/methods/Container.hx", 91, FunctionType([LibType("T", "T", [])], LibType("String", "String", [])));
		addTypeHint("testcases/methods/Container.hx", 117, LibType("Array", "Array", [LibType("String", "String", [])]));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Container.hx", posStart: 107, posEnd: 239}, edits, async);
	}

	function testMacroTools(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/MacroTools.hx", "return buildExtract(fields);\n", 195, 353, true),
			makeInsertTestEdit("testcases/methods/MacroTools.hx",
				"static function buildExtract(fields:Array<Field>):Array<Field> {\n"
				+ "for (field in fields) {\n"
				+ "			switch field.kind {\n"
				+ "				case FFun(f):\n"
				+ "					var expr = f.expr;\n"
				+ "				// Complex manipulation...\n"
				+ "				default:\n"
				+ "			}\n"
				+ "		}\n"
				+ "		return fields;\n"
				+ "}\n",
				357, true),
		];
		addTypeHint("testcases/methods/MacroTools.hx", 163, LibType("Array", "Array", [LibType("Field", "Field", [])]));
		addTypeHint("testcases/methods/MacroTools.hx", 351, LibType("Array", "Array", [LibType("Field", "Field", [])]));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/MacroTools.hx", posStart: 195, posEnd: 353}, edits, async);
	}

	function testMatcherOnlySwitch(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Matcher.hx", "processExtract(value);\n", 84, 284, true),
			makeInsertTestEdit("testcases/methods/Matcher.hx",
				"function processExtract(value:Any) {\n"
				+ "return switch value {\n"
				+ "			case Int(i) if (i > 0): 'Positive: $i';\n"
				+ "			case String(s) if (s.length > 0): 'NonEmpty: $s';\n"
				+ "			case Array(a) if (a.length > 0): 'HasElements: ${a.length}';\n"
				+ "			case _: 'Unknown';\n"
				+ "		}\n"
				+ "}\n",
				288, true),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Matcher.hx", posStart: 84, posEnd: 284}, edits, async);
	}

	function testMatcherWithReturn(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Matcher.hx", "return processExtract(value);\n", 77, 284, true),
			makeInsertTestEdit("testcases/methods/Matcher.hx",
				"function processExtract(value:Any) {\n"
				+ "return switch value {\n"
				+ "			case Int(i) if (i > 0): 'Positive: $i';\n"
				+ "			case String(s) if (s.length > 0): 'NonEmpty: $s';\n"
				+ "			case Array(a) if (a.length > 0): 'HasElements: ${a.length}';\n"
				+ "			case _: 'Unknown';\n"
				+ "		}\n"
				+ "}\n",
				288, true),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Matcher.hx", posStart: 76, posEnd: 284}, edits, async);
	}
}
