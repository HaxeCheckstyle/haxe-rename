package refactor.refactor;

class RefactorExtractMethodTest extends RefactorTestBase {
	function setupClass() {
		setupTestSources(["testcases/methods"]);
	}

	function testFailCollectDataEmptyFile(async:Async) {
		failCanRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Empty.hx", posStart: 80, posEnd: 131}, "unsupported");
		failRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Empty.hx", posStart: 80, posEnd: 131}, "failed to collect data for extract method",
			async);
	}

	function testFailCollectDataEmptyRange(async:Async) {
		failCanRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 0, posEnd: 0}, "unsupported");
		failRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 0, posEnd: 0}, "failed to collect data for extract method",
			async);
	}

	function testFailCollectData(async:Async) {
		failCanRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 80, posEnd: 131}, "unsupported");
		failRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 80, posEnd: 131}, "failed to collect data for extract method",
			async);
	}

	function testFailCollectDataReverse(async:Async) {
		failCanRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 131, posEnd: 80}, "unsupported");
		failRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 131, posEnd: 80}, "failed to collect data for extract method",
			async);
	}

	function testFailNoParentFunction(async:Async) {
		failCanRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 1962, posEnd: 1999}, "unsupported");
		failRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 1962, posEnd: 1999},
			"failed to collect data for extract method", async);
	}

	function testFailAssignmentInLocalFunction(async:Async) {
		failCanRefactor(RefactorExtractMethod, {fileName: "testcases/methods/LambdaExample.hx", posStart: 675, posEnd: 680}, "unsupported");
		failRefactor(RefactorExtractMethod, {fileName: "testcases/methods/LambdaExample.hx", posStart: 675, posEnd: 680},
			"failed to collect data for extract method", async);
	}

	function testSimpleNoReturns(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "noReturnsExtract();", 94, 131, Format(2, true)),
			makeInsertTestEdit("testcases/methods/Main.hx",
				"function noReturnsExtract():Void {\n"
				+ "trace(\"hello 2\");\n"
				+ "		trace(\"hello 3\");\n"
				+ "}\n", 155, Format(1, false)),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 93, posEnd: 131}, edits, async);
	}

	function testSimpleNoReturnsStatic(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "noReturnsStaticExtract();", 222, 259, Format(2, true)),
			makeInsertTestEdit("testcases/methods/Main.hx",
				"static function noReturnsStaticExtract():Void {\n"
				+ "trace(\"hello 2\");\n"
				+ "		trace(\"hello 3\");\n"
				+ "}\n", 283, Format(1, false)),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 221, posEnd: 259}, edits, async);
	}

	function testEmptyReturns(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "if (!emptyReturnsExtract(cond1, cond2)) {\n" + "return;\n" + "}", 342, 439, Format(2, true)),
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
				483, Format(1, false)),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 341, posEnd: 439}, edits, async);
	}

	function testCalculateTotal(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "total = calculateTotalExtract(items, total);", 569, 720, Format(2, true)),
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
				741, Format(1, false)),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 568, posEnd: 720}, edits, async);
	}

	function testCalculateTotalJustVars(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx",
				"var price;\n"
				+ "var quantity;\n"
				+ "{\nfinal data = calculateTotalExtract(item);\n"
				+ "price = data.price;\n"
				+ "quantity = data.quantity;\n"
				+ "}",
				630, 686, Format(3, true)),
			makeInsertTestEdit("testcases/methods/Main.hx",
				"function calculateTotalExtract(item:Item):{price:Float, quantity:Float} {\n"
				+ "var price = item.price;\n"
				+ "			var quantity = item.quantity;\n"
				+ "return {\n"
				+ "price: price,\n"
				+ "quantity: quantity,\n"
				+ "};\n"
				+ "}\n",
				741, Format(1, false)),
		];
		addTypeHint("testcases/methods/Main.hx", 613, LibType("Item", "Item", []));
		addTypeHint("testcases/methods/Main.hx", 638, LibType("Float", "Float", []));
		addTypeHint("testcases/methods/Main.hx", 668, LibType("Float", "Float", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 629, posEnd: 686}, edits, async);
	}

	function testCalculateTotalWithLastReturn(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "return calculateTotalExtract(items, total);", 569, 737, Format(2, true)),
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
				741, Format(1, false)),
		];
		addTypeHint("testcases/methods/Main.hx", 514, LibType("Float", "Float", []));
		addTypeHint("testcases/methods/Main.hx", 735, LibType("Float", "Float", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 568, posEnd: 737}, edits, async);
	}

	function testProcessUserWithLastReturn(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "return calculateTotal2Extract(items, total);", 1081, 1295, Format(2, true)),
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
				1299, Format(1, false)),
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
				+ "}",
				1081, 1278, Format(2, true)),
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
				1299, Format(1, false)),
		];
		addTypeHint("testcases/methods/Main.hx", 1026, FunctionType([LibType("Array", "Array", [LibType("Item", "Item", [])])], LibType("Float", "Float", [])));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 1080, posEnd: 1278}, edits, async);
	}

	function testCalcConditionalLevel(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "count = calcConditionalLevelExtract(token, count);", 1388, 1543, Format(2, true)),
			makeInsertTestEdit("testcases/methods/Main.hx",
				"function calcConditionalLevelExtract(token:tokentree.TokenTree, count:Int):Int {\n"
				+ "while ((token != null) && (token.tok != Root)) {\n"
				+ "			switch (token.tok) {\n"
				+ "				case Sharp(\"if\"):\n"
				+ "					count++;\n"
				+ "				default:\n"
				+ "			}\n"
				+ "			token = token.parent;\n"
				+ "		}\n"
				+ "return count;\n"
				+ "}\n",
				1600, Format(1, false)),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 1387, posEnd: 1543}, edits, async);
	}

	function testCalcConditionalLevelWithVar(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "var count = calcConditionalLevelExtract(token);", 1366, 1543, Format(2, true)),
			makeInsertTestEdit("testcases/methods/Main.hx",
				"function calcConditionalLevelExtract(token:tokentree.TokenTree):Int {\n"
				+ "var count:Int = -1;\n"
				+ "		while ((token != null) && (token.tok != Root)) {\n"
				+ "			switch (token.tok) {\n"
				+ "				case Sharp(\"if\"):\n"
				+ "					count++;\n"
				+ "				default:\n"
				+ "			}\n"
				+ "			token = token.parent;\n"
				+ "		}\n"
				+ "return count;\n"
				+ "}\n",
				1600, Format(1, false)),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 1365, posEnd: 1543}, edits, async);
	}

	function testAllEmptyReturns(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "allEmptyReturnsExtract();", 1722, 1809, Format(2, true)),
			makeInsertTestEdit("testcases/methods/Main.hx",
				"function allEmptyReturnsExtract():Void {\n"
				+ "trace(\"hello 1\");\n"
				+ "		trace(\"hello 2\");\n"
				+ "		trace(\"hello 3\");\n"
				+ "		trace(\"hello 4\");\n"
				+ "		return;\n"
				+ "}\n",
				1813, Format(1, false)),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 1721, posEnd: 1809}, edits, async);
	}

	function testStringInterpolation(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Main.hx", "return interpolationExtract(data);", 1884, 1937, Format(2, true)),
			makeInsertTestEdit("testcases/methods/Main.hx",
				"static function interpolationExtract(data:Dynamic):String {\n" + "return cast '${data.a}_${data.b}_${data.c}_${false}';\n" + "}\n", 1941,
				Format(1, false)),
		];
		addTypeHint("testcases/methods/Main.hx", 1857, LibType("String", "String", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Main.hx", posStart: 1887, posEnd: 1937}, edits, async);
	}

	function testDemoSimple(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Demo.hx", "doSomethingExtract();", 161, 252, Format(2, true)),
			makeInsertTestEdit("testcases/methods/Demo.hx",
				"function doSomethingExtract():Void {\n"
				+ "doNothing();\n"
				+ "		trace(\"I'm here\");\n"
				+ "		doNothing();\n"
				+ "		trace(\"yep, still here\");\n"
				+ "		doNothing();\n"
				+ "}\n",
				467, Format(1, false)),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Demo.hx", posStart: 160, posEnd: 252}, edits, async);
	}

	function testDemoSwitch(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Demo.hx", "doSomethingExtract(cond, val, text);", 262, 463, Format(2, true)),
			makeInsertTestEdit("testcases/methods/Demo.hx",
				"function doSomethingExtract(cond:Bool, val:Int, text:Null<String>):Float {\n"
				+ "return switch [cond, val] {\n"
				+ "			case [true, 0]:\n"
				+ "				std.Math.random() * val;\n"
				+ "			case [true, _]:\n"
				+ "				val + val;\n"
				+ "			case [false, 10]:\n"
				+ "				Std.parseFloat(text);\n"
				+ "			case [_, _]:\n"
				+ "				std.Math.NEGATIVE_INFINITY;\n"
				+ "		}\n"
				+ "}\n",
				467, Format(1, false)),
		];
		addTypeHint("testcases/methods/Demo.hx", 61, LibType("Float", "Float", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Demo.hx", posStart: 262, posEnd: 463}, edits, async);
	}

	function testDemoReturnSwitch(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Demo.hx", "return doSomethingExtract(cond, val, text);", 255, 463, Format(2, true)),
			makeInsertTestEdit("testcases/methods/Demo.hx",
				"function doSomethingExtract(cond:Bool, val:Int, text:Null<String>):Float {\n"
				+ "return switch [cond, val] {\n"
				+ "			case [true, 0]:\n"
				+ "				std.Math.random() * val;\n"
				+ "			case [true, _]:\n"
				+ "				val + val;\n"
				+ "			case [false, 10]:\n"
				+ "				Std.parseFloat(text);\n"
				+ "			case [_, _]:\n"
				+ "				std.Math.NEGATIVE_INFINITY;\n"
				+ "		}\n"
				+ "}\n",
				467, Format(1, false)),
		];
		addTypeHint("testcases/methods/Demo.hx", 61, LibType("Float", "Float", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Demo.hx", posStart: 254, posEnd: 463}, edits, async);
	}

	function testDemoCodeAndSwitch(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Demo.hx", "return doSomethingExtract(cond, val, text);", 161, 463, Format(2, true)),
			makeInsertTestEdit("testcases/methods/Demo.hx",
				"function doSomethingExtract(cond:Bool, val:Int, text:Null<String>):Float {\n"
				+ "doNothing();\n"
				+ "		trace(\"I'm here\");\n"
				+ "		doNothing();\n"
				+ "		trace(\"yep, still here\");\n"
				+ "		doNothing();\n"
				+ "		return switch [cond, val] {\n"
				+ "			case [true, 0]:\n"
				+ "				std.Math.random() * val;\n"
				+ "			case [true, _]:\n"
				+ "				val + val;\n"
				+ "			case [false, 10]:\n"
				+ "				Std.parseFloat(text);\n"
				+ "			case [_, _]:\n"
				+ "				std.Math.NEGATIVE_INFINITY;\n"
				+ "		}\n"
				+ "}\n",
				467, Format(1, false)),
		];
		addTypeHint("testcases/methods/Demo.hx", 61, LibType("Float", "Float", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Demo.hx", posStart: 160, posEnd: 463}, edits, async);
	}

	function testDemoConditionAndCode(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Demo.hx",
				"switch (doSomethingExtract(cond, text)) {\n"
				+ "case Some(data):\n"
				+ "return data;\n"
				+ "case None:\n"
				+ "}", 112, 252, Format(2, true)),
			makeInsertTestEdit("testcases/methods/Demo.hx",
				"function doSomethingExtract(cond:Bool, text:Null<String>):haxe.ds.Option<Float> {\n"
				+ "if (cond && text == null) {\n"
				+ "			return Some(0.0);\n"
				+ "		}\n"
				+ "		doNothing();\n"
				+ "		trace(\"I'm here\");\n"
				+ "		doNothing();\n"
				+ "		trace(\"yep, still here\");\n"
				+ "		doNothing();\n"
				+ "return None;\n"
				+ "}\n",
				467, Format(1, false)),
		];
		addTypeHint("testcases/methods/Demo.hx", 61, LibType("Float", "Float", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Demo.hx", posStart: 111, posEnd: 252}, edits, async);
	}

	function testCalculateMath(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Math.hx", "calculateExtract(a, b);", 106, 122, Format(2, true)),
			makeInsertTestEdit("testcases/methods/Math.hx", "function calculateExtract(a:Int, b:Int):Int {\n" + "return a * b + (a - b);\n" + "}\n", 143,
				Format(1, false)),
		];
		addTypeHint("testcases/methods/Math.hx", 71, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/Math.hx", 84, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/Math.hx", 102, LibType("Int", "Int", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Math.hx", posStart: 106, posEnd: 122}, edits, async);
	}

	function testCalculateMathWithVar(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Math.hx", "var result = calculateExtract(a, b);", 93, 122, Format(2, true)),
			makeInsertTestEdit("testcases/methods/Math.hx",
				"function calculateExtract(a:Int, b:Int):Int {\n"
				+ "var result = a * b + (a - b);\n"
				+ "return result;\n"
				+ "}\n", 143, Format(1, false)),
		];
		addTypeHint("testcases/methods/Math.hx", 71, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/Math.hx", 84, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/Math.hx", 102, LibType("Int", "Int", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Math.hx", posStart: 93, posEnd: 122}, edits, async);
	}

	function testNameProcessor(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/NameProcessor.hx", "var upperNames = processExtract(names);", 113, 201, Format(2, true)),
			makeInsertTestEdit("testcases/methods/NameProcessor.hx",
				"function processExtract(names:Array<String>):Array<?> {\n"
				+ "var upperNames = [];\n"
				+ "		for (name in names) {\n"
				+ "			upperNames.push(name.toUpperCase());\n"
				+ "		}\n"
				+ "return upperNames;\n"
				+ "}\n",
				226, Format(1, false)),
		];
		addTypeHint("testcases/methods/NameProcessor.hx", 82, LibType("Array", "Array", [LibType("String", "String", [])]));
		addTypeHint("testcases/methods/NameProcessor.hx", 126, LibType("Array", "Array", [UnknownType("?")]));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/NameProcessor.hx", posStart: 112, posEnd: 201}, edits, async);
	}

	function testArrayHandler(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/ArrayHandler.hx", "var sum = handleExtract(numbers);", 105, 157, Format(2, true)),
			makeInsertTestEdit("testcases/methods/ArrayHandler.hx",
				"function handleExtract(numbers:Array<Int>):Int {\n"
				+ "var sum = 0;\n"
				+ "		for (n in numbers) {\n"
				+ "			sum += n;\n"
				+ "		}\n"
				+ "return sum;\n"
				+ "}\n",
				175, Format(1, false)),
		];
		addTypeHint("testcases/methods/ArrayHandler.hx", 82, LibType("Array", "Array", [LibType("Int", "Int", [])]));
		addTypeHint("testcases/methods/ArrayHandler.hx", 111, LibType("Int", "Int", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/ArrayHandler.hx", posStart: 104, posEnd: 157}, edits, async);
	}

	function testAgeChecker(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/AgeChecker.hx", "message = checkExtract(age, message);", 105, 179, Format(2, true)),
			makeInsertTestEdit("testcases/methods/AgeChecker.hx",
				"function checkExtract(age:Int, message:String):String {\n"
				+ "if (age < 18) {\n"
				+ "			message = \"Minor\";\n"
				+ "		} else {\n"
				+ "			message = \"Adult\";\n"
				+ "		}\n"
				+ "return message;\n"
				+ "}\n",
				201, Format(1, false)),
		];
		addTypeHint("testcases/methods/AgeChecker.hx", 75, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/AgeChecker.hx", 95, LibType("String", "String", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/AgeChecker.hx", posStart: 104, posEnd: 179}, edits, async);
	}

	function testPersonHandler(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/PersonHandler.hx", "handleExtract(person);", 113, 161, Format(2, true)),
			makeInsertTestEdit("testcases/methods/PersonHandler.hx",
				"function handleExtract(person:{name:String, age:Int}) {\n" + "return \"Name: \" + person.name + \", Age: \" + person.age;\n" + "}\n", 180,
				Format(1, false)),
		];
		addTypeHint("testcases/methods/PersonHandler.hx", 75, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/PersonHandler.hx", 95, LibType("String", "String", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/PersonHandler.hx", posStart: 113, posEnd: 161}, edits, async);
	}

	function testPersonHandlerWithVar(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/PersonHandler.hx", "var info = handleExtract(person);", 102, 161, Format(2, true)),
			makeInsertTestEdit("testcases/methods/PersonHandler.hx",
				"function handleExtract(person:{name:String, age:Int}) {\n"
				+ "var info = \"Name: \" + person.name + \", Age: \" + person.age;\n"
				+ "return info;\n"
				+ "}\n",
				180, Format(1, false)),
		];
		addTypeHint("testcases/methods/PersonHandler.hx", 75, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/PersonHandler.hx", 95, LibType("String", "String", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/PersonHandler.hx", posStart: 101, posEnd: 161}, edits, async);
	}

	function testContainer(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Container.hx", "var result = processExtract(items, converter);", 108, 239, Format(2, true)),
			makeInsertTestEdit("testcases/methods/Container.hx",
				"function processExtract<T>(items:Array<T>, converter:T -> String):Array<String> {\n"
				+ "var result = new Array<String>();\n"
				+ "		for (item in items) {\n"
				+ "			var converted = converter(item);\n"
				+ "			result.push('[${converted}]');\n"
				+ "		}\n"
				+ "return result;\n"
				+ "}\n",
				260, Format(1, false)),
		];
		addTypeHint("testcases/methods/Container.hx", 91, FunctionType([LibType("T", "T", [])], LibType("String", "String", [])));
		addTypeHint("testcases/methods/Container.hx", 117, LibType("Array", "Array", [LibType("String", "String", [])]));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Container.hx", posStart: 107, posEnd: 239}, edits, async);
	}

	function testMacroTools(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/MacroTools.hx", "return buildExtract(fields);", 195, 353, Format(2, true)),
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
				357, Format(1, false)),
		];
		addTypeHint("testcases/methods/MacroTools.hx", 133, LibType("Array", "Array", [LibType("Field", "Field", [])]));
		addTypeHint("testcases/methods/MacroTools.hx", 163, LibType("Array", "Array", [LibType("Field", "Field", [])]));
		addTypeHint("testcases/methods/MacroTools.hx", 351, LibType("Array", "Array", [LibType("Field", "Field", [])]));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/MacroTools.hx", posStart: 195, posEnd: 353}, edits, async);
	}

	function testMatcherOnlySwitch(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Matcher.hx", "processExtract(value);", 84, 284, Format(2, true)),
			makeInsertTestEdit("testcases/methods/Matcher.hx",
				"function processExtract(value:Any) {\n"
				+ "return switch value {\n"
				+ "			case Int(i) if (i > 0): 'Positive: $i';\n"
				+ "			case String(s) if (s.length > 0): 'NonEmpty: $s';\n"
				+ "			case Array(a) if (a.length > 0): 'HasElements: ${a.length}';\n"
				+ "			case _: 'Unknown';\n"
				+ "		}\n"
				+ "}\n",
				288, Format(1, false)),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Matcher.hx", posStart: 84, posEnd: 284}, edits, async);
	}

	function testMatcherWithReturn(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/Matcher.hx", "return processExtract(value);", 77, 284, Format(2, true)),
			makeInsertTestEdit("testcases/methods/Matcher.hx",
				"function processExtract(value:Any) {\n"
				+ "return switch value {\n"
				+ "			case Int(i) if (i > 0): 'Positive: $i';\n"
				+ "			case String(s) if (s.length > 0): 'NonEmpty: $s';\n"
				+ "			case Array(a) if (a.length > 0): 'HasElements: ${a.length}';\n"
				+ "			case _: 'Unknown';\n"
				+ "		}\n"
				+ "}\n",
				288, Format(1, false)),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/Matcher.hx", posStart: 76, posEnd: 284}, edits, async);
	}

	function testTypeProcessor(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/TypeProcessor.hx", "processExtract(item, compare);", 114, 221, Format(2, true)),
			makeInsertTestEdit("testcases/methods/TypeProcessor.hx",
				"function processExtract<T:Base, U:IComparable>(item:T, compare:U):Void {\n"
				+ "var result = item.process();\n"
				+ "		if (compare.compareTo(result) > 0) {\n"
				+ "			item.update(compare.getValue());\n"
				+ "		}\n"
				+ "}\n",
				225, Format(1, false)),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/TypeProcessor.hx", posStart: 113, posEnd: 221}, edits, async);
	}

	function testFunctionProcessor(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/FunctionProcessor.hx", "processExtract(callback, value, text);", 143, 211, Format(2, true)),
			makeInsertTestEdit("testcases/methods/FunctionProcessor.hx",
				"function processExtract(callback:(Int, String) -> Bool, value:Int, text:String):Void {\n"
				+ "if (callback(value, text)) {\n"
				+ "			trace('Success: $value, $text');\n"
				+ "		}\n"
				+ "}\n",
				215, Format(1, false)),
		];
		addTypeHint("testcases/methods/FunctionProcessor.hx", 79,
			FunctionType([LibType("Int", "Int", []), LibType("String", "String", [])], LibType("Bool", "Bool", [])));
		addTypeHint("testcases/methods/FunctionProcessor.hx", 112, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/FunctionProcessor.hx", 129, LibType("String", "String", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/FunctionProcessor.hx", posStart: 142, posEnd: 211}, edits, async);
	}

	function testArrayTools(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/ArrayTools.hx", "return processItemsExtract(arr, fn);", 117, 231, Format(2, true)),
			makeInsertTestEdit("testcases/methods/ArrayTools.hx",
				"static function processItemsExtract<T>(arr:Array<T>, fn:T -> Bool):Array<T> {\n"
				+ "var results = new Array<T>();\n"
				+ "		for (item in arr) {\n"
				+ "			if (fn(item))\n"
				+ "				results.push(item);\n"
				+ "		}\n"
				+ "		return results;\n"
				+ "}\n",
				235, Format(1, false)),
		];
		addTypeHint("testcases/methods/ArrayTools.hx", 82, LibType("Array", "Array", [LibType("T", "T", [])]));
		addTypeHint("testcases/methods/ArrayTools.hx", 102, FunctionType([LibType("T", "T", [])], LibType("Bool", "Bool", [])));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/ArrayTools.hx", posStart: 115, posEnd: 231}, edits, async);
	}

	function testExceptionHandlerTry(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/ExceptionHandler.hx", "processExtract();", 86, 152, Format(3, true)),
			makeInsertTestEdit("testcases/methods/ExceptionHandler.hx",
				"function processExtract():Void {\n"
				+ "var data = getData();\n"
				+ "			validateData(data);\n"
				+ "			processData(data);\n"
				+ "}\n", 795,
				Format(1, false)),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/ExceptionHandler.hx", posStart: 85, posEnd: 152}, edits, async);
	}

	function testExceptionHandlerCatch(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/ExceptionHandler.hx", "processExtract();", 193, 250, Format(3, true)),
			makeInsertTestEdit("testcases/methods/ExceptionHandler.hx",
				"function processExtract():Void {\n"
				+ "logError(e);\n"
				+ "			throw new ProcessingException(e.message);\n"
				+ "}\n", 795, Format(1, false)),
		];
		addTypeHint("testcases/methods/ExceptionHandler.hx", 69, LibType("Void", "Void", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/ExceptionHandler.hx", posStart: 192, posEnd: 250}, edits, async);
	}

	function testExceptionHandlerTryWithThrow(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/ExceptionHandler.hx", "processExtract();", 266, 404, Format(3, true)),
			makeInsertTestEdit("testcases/methods/ExceptionHandler.hx",
				"function processExtract():Void {\n"
				+ "var data = getData();\n"
				+ "			if (data.value > 10) {\n"
				+ "				return;\n"
				+ "			}\n"
				+ "			throw new InvalidDataException(\"value should not be smaller than 11\");\n"
				+ "}\n",
				795, Format(1, false)),
		];
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/ExceptionHandler.hx", posStart: 265, posEnd: 404}, edits, async);
	}

	function testExceptionHandlerTryWithThrowNotLast(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/ExceptionHandler.hx", "processExtract();", 518, 689, Format(3, true)),
			makeInsertTestEdit("testcases/methods/ExceptionHandler.hx",
				"function processExtract():Void {\n"
				+ "var data = getData();\n"
				+ "			if (data.value > 10) {\n"
				+ "				throw new InvalidDataException(\"value should not be larger than 10\");\n"
				+ "			}\n"
				+ "			validateData(data);\n"
				+ "			processData(data);\n"
				+ "}\n",
				795, Format(1, false)),
		];
		addTypeHint("testcases/methods/ExceptionHandler.hx", 69, LibType("Void", "Void", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/ExceptionHandler.hx", posStart: 517, posEnd: 689}, edits, async);
	}

	function testMetadataProcessor(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/MetadataProcessor.hx", "processExtract(meta, results);", 220, 575, Format(2, true)),
			makeInsertTestEdit("testcases/methods/MetadataProcessor.hx",
				"function processExtract(meta:Dynamic<Dynamic<Array<Dynamic>>>, results:Map<String, Array<String>>):Void {\n"
				+ "for (field in Reflect.fields(meta)) {\n"
				+ "			var fieldMeta = Reflect.field(meta, field);\n"
				+ "			if (Reflect.hasField(fieldMeta, \"meta\")) {\n"
				+ "				var metaValues = Reflect.field(fieldMeta, \"meta\");\n"
				+ "				if (Std.isOfType(metaValues, Array)) {\n"
				+ "					var values = cast(metaValues, Array<Dynamic>);\n"
				+ "					results.set(field, [for (v in values) Std.string(v)]);\n"
				+ "				}\n"
				+ "			}\n"
				+ "		}\n"
				+ "}\n",
				676, Format(1, false)),
		];
		addTypeHint("testcases/methods/MetadataProcessor.hx", 132, LibType("Dynamic", "Dynamic", [
			LibType("Dynamic", "Dynamic", [LibType("Array", "Array", [LibType("Dynamic", "Dynamic", [])])])
		]));
		addTypeHint("testcases/methods/MetadataProcessor.hx", 179, LibType("Map", "Map", [
			LibType("String", "String", []),
			LibType("Array", "Array", [LibType("String", "String", [])])
		]));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/MetadataProcessor.hx", posStart: 219, posEnd: 575}, edits, async);
	}

	function testMetadataProcessorWithResults(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/MetadataProcessor.hx", "var results = processExtract(meta);", 169, 575, Format(2, true)),
			makeInsertTestEdit("testcases/methods/MetadataProcessor.hx",
				"function processExtract(meta:Dynamic<Dynamic<Array<Dynamic>>>):Map<String, Array<String>> {\n"
				+ "var results = new Map<String, Array<String>>();\n\n"
				+ "		for (field in Reflect.fields(meta)) {\n"
				+ "			var fieldMeta = Reflect.field(meta, field);\n"
				+ "			if (Reflect.hasField(fieldMeta, \"meta\")) {\n"
				+ "				var metaValues = Reflect.field(fieldMeta, \"meta\");\n"
				+ "				if (Std.isOfType(metaValues, Array)) {\n"
				+ "					var values = cast(metaValues, Array<Dynamic>);\n"
				+ "					results.set(field, [for (v in values) Std.string(v)]);\n"
				+ "				}\n"
				+ "			}\n"
				+ "		}\n"
				+ "return results;\n"
				+ "}\n",
				676, Format(1, false)),
		];
		addTypeHint("testcases/methods/MetadataProcessor.hx", 132, LibType("Dynamic", "Dynamic", [
			LibType("Dynamic", "Dynamic", [LibType("Array", "Array", [LibType("Dynamic", "Dynamic", [])])])
		]));
		addTypeHint("testcases/methods/MetadataProcessor.hx", 179, LibType("Map", "Map", [
			LibType("String", "String", []),
			LibType("Array", "Array", [LibType("String", "String", [])])
		]));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/MetadataProcessor.hx", posStart: 168, posEnd: 575}, edits, async);
	}

	function testMetadataProcessorPrint(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/MetadataProcessor.hx", "processExtract(results);", 579, 672, Format(2, true)),
			makeInsertTestEdit("testcases/methods/MetadataProcessor.hx",
				"function processExtract(results:Map<String, Array<String>>):Void {\n"
				+ "for (field => values in results) {\n"
				+ "			trace('Field: $field, Meta: ${values.join(\", \")}');\n"
				+ "		}\n"
				+ "}\n",
				676, Format(1, false)),
		];
		addTypeHint("testcases/methods/MetadataProcessor.hx", 179, LibType("Map", "Map", [
			LibType("String", "String", []),
			LibType("Array", "Array", [LibType("String", "String", [])])
		]));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/MetadataProcessor.hx", posStart: 578, posEnd: 672}, edits, async);
	}

	function testLambdaExample(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/LambdaExample.hx", "processExtract", 156, 230, Format(2, true)),
			makeInsertTestEdit("testcases/methods/LambdaExample.hx",
				"function processExtract(n:Int):Int {\n"
				+ "var temp = n * multiplier;\n"
				+ "			return temp + this.multiplier;\n"
				+ "}\n", 236,
				Format(1, false)),
		];
		addTypeHint("testcases/methods/LambdaExample.hx", 156, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/LambdaExample.hx", 159, LibType("Int", "Int", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/LambdaExample.hx", posStart: 156, posEnd: 230}, edits, async);
	}

	function testLambdaExampleCallback(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/LambdaExample.hx", "processCallbackExtract", 281, 337, Format(2, true)),
			makeInsertTestEdit("testcases/methods/LambdaExample.hx",
				"function processCallbackExtract(n:Int, m:Int):Int {\n"
				+ "var temp = n * m;\n"
				+ "			return temp + m;\n"
				+ "}\n", 343, Format(1, false)),
		];
		addTypeHint("testcases/methods/LambdaExample.hx", 282, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/LambdaExample.hx", 285, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/LambdaExample.hx", 289, LibType("Int", "Int", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/LambdaExample.hx", posStart: 281, posEnd: 337}, edits, async);
	}

	function testLambdaExampleCallbackFunc(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/LambdaExample.hx", "processCallbackFuncExtract", 392, 453, Format(2, true)),
			makeInsertTestEdit("testcases/methods/LambdaExample.hx",
				"function processCallbackFuncExtract(n:Int, m:Int):Int {\n"
				+ "var temp = n * m;\n"
				+ "			return temp + m;\n"
				+ "}\n", 459, Format(1, false)),
		];
		addTypeHint("testcases/methods/LambdaExample.hx", 401, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/LambdaExample.hx", 404, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/LambdaExample.hx", 399, LibType("Int", "Int", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/LambdaExample.hx", posStart: 392, posEnd: 453}, edits, async);
	}

	function testLambdaExampleSimple(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/LambdaExample.hx", "processSimpleExtract", 669, 679, Format(2, true)),
			makeInsertTestEdit("testcases/methods/LambdaExample.hx", "function processSimpleExtract(n:Int):Int {\n"
				+ "n * n\n"
				+ "}\n", 685, Format(1, false)),
		];
		addTypeHint("testcases/methods/LambdaExample.hx", 669, LibType("Int", "Int", []));
		addTypeHint("testcases/methods/LambdaExample.hx", 672, LibType("Int", "Int", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/LambdaExample.hx", posStart: 669, posEnd: 679}, edits, async);
	}

	function testLambdaExampleNamedCallbackFunc(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/LambdaExample.hx", "", 727, 806, Format(2, true)),
			makeInsertTestEdit("testcases/methods/LambdaExample.hx",
				"function processCB(n:Int, m:Int):Int {\n"
				+ "var temp = n * m;\n"
				+ "			return temp + m;\n"
				+ "}\n", 836, Format(1, false)),
		];
		addTypeHint("testcases/methods/LambdaExample.hx", 744, LibType("Int", "Int", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/LambdaExample.hx", posStart: 726, posEnd: 806}, edits, async);
	}

	function testEditDocInner(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/TestEditDoc.hx", "text = addChangeExtract(range, text);", 388, 485, Format(4, true)),
			makeInsertTestEdit("testcases/methods/TestEditDoc.hx",
				"function addChangeExtract(range:TestRange, text:String):String {\n"
				+ "if (range.start.character != 0) {\n"
				+ "					range.start.character = 0;\n"
				+ "					text = text.ltrim();\n"
				+ "				}\n"
				+ "return text;\n"
				+ "}\n",
				538, Format(1, false)),
		];
		addTypeHint("testcases/methods/TestEditDoc.hx", 170, LibType("TestRange", "TestRange", []));
		addTypeHint("testcases/methods/TestEditDoc.hx", 235, LibType("String", "String", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/TestEditDoc.hx", posStart: 387, posEnd: 485}, edits, async);
	}

	function testEditDocInnerWithEdit(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/TestEditDoc.hx", "text = addChangeExtract(text, filePath, range);", 346, 485, Format(4, true)),
			makeInsertTestEdit("testcases/methods/TestEditDoc.hx",
				"function addChangeExtract(text:String, filePath:String, range:TestRange):String {\n"
				+ "text = formatSnippet(filePath, text);\n"
				+ "				if (range.start.character != 0) {\n"
				+ "					range.start.character = 0;\n"
				+ "					text = text.ltrim();\n"
				+ "				}\n"
				+ "return text;\n"
				+ "}\n",
				538, Format(1, false)),
		];
		addTypeHint("testcases/methods/TestEditDoc.hx", 170, LibType("TestRange", "TestRange", []));
		addTypeHint("testcases/methods/TestEditDoc.hx", 235, LibType("String", "String", []));
		addTypeHint("testcases/methods/TestEditDoc.hx", 262, LibType("String", "String", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/TestEditDoc.hx", posStart: 345, posEnd: 485}, edits, async);
	}

	function testEditDocInnerWithSwitch(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/TestEditDoc.hx", "var text = addChangeExtract(range);", 193, 489, Format(2, true)),
			makeInsertTestEdit("testcases/methods/TestEditDoc.hx",
				"function addChangeExtract(range:TestRange):String {\n"
				+ "final f:FormatType = Format(10);\n"
				+ "		var text = \"text\";\n"
				+ "		final filePath = \"import.hx\";\n"
				+ "		switch (f) {\n"
				+ "			case NoFormat:\n"
				+ "			case Format(indentOffset):\n"
				+ "				text = formatSnippet(filePath, text);\n"
				+ "				if (range.start.character != 0) {\n"
				+ "					range.start.character = 0;\n"
				+ "					text = text.ltrim();\n"
				+ "				}\n"
				+ "		}\n"
				+ "return text;\n"
				+ "}\n",
				538, Format(1, false)),
		];
		addTypeHint("testcases/methods/TestEditDoc.hx", 170, LibType("TestRange", "TestRange", []));
		addTypeHint("testcases/methods/TestEditDoc.hx", 235, LibType("String", "String", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/TestEditDoc.hx", posStart: 192, posEnd: 489}, edits, async);
	}

	function testEditDocInnerWithRange(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/TestEditDoc.hx",
				"var range;\n"
				+ "var text;\n"
				+ "{\n"
				+ "final data = addChangeExtract();\n"
				+ "range = data.range;\n"
				+ "text = data.text;\n"
				+ "}", 160,
				489, Format(2, true)),
			makeInsertTestEdit("testcases/methods/TestEditDoc.hx",
				"function addChangeExtract():{range:TestRange, text:String} {\n"
				+ "final range = posToRange(100);\n"
				+ "		final f:FormatType = Format(10);\n"
				+ "		var text = \"text\";\n"
				+ "		final filePath = \"import.hx\";\n"
				+ "		switch (f) {\n"
				+ "			case NoFormat:\n"
				+ "			case Format(indentOffset):\n"
				+ "				text = formatSnippet(filePath, text);\n"
				+ "				if (range.start.character != 0) {\n"
				+ "					range.start.character = 0;\n"
				+ "					text = text.ltrim();\n"
				+ "				}\n"
				+ "		}\n"
				+ "return {\n"
				+ "range: range,\n"
				+ "text: text,\n"
				+ "};\n"
				+ "}\n",
				538, Format(1, false)),
		];
		addTypeHint("testcases/methods/TestEditDoc.hx", 170, LibType("TestRange", "TestRange", []));
		addTypeHint("testcases/methods/TestEditDoc.hx", 235, LibType("String", "String", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/TestEditDoc.hx", posStart: 159, posEnd: 489}, edits, async);
	}

	function testSomeHelper(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/methods/SomeHelper.hx", "arrayAccessExtract(types, type, use, fromName, changelist, context);", 821, 1168,
				Format(5, true)),
			makeInsertTestEdit("testcases/methods/SomeHelper.hx",
				"static function arrayAccessExtract(types:Array<Type>, type:Type, use:Identifier, fromName:String, changelist:Changelist, context:RenameContext):Void {\n"
				+ "for (t in types) {\n"
				+ "						if (t != type) {\n"
				+ "							continue;\n"
				+ "						}\n"
				+ "						var pos:IdentifierPos = {\n"
				+ "							fileName: use.pos.fileName,\n"
				+ "							start: use.pos.start,\n"
				+ "							end: use.pos.end\n"
				+ "						};\n"
				+ "						pos.end = pos.start + fromName.length;\n"
				+ "						changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, pos, NoFormat), use);\n"
				+ "					}\n"
				+ "}\n",
				1313, Format(1, false)),
		];
		addTypeHint("testcases/methods/SomeHelper.hx", 807, LibType("Type", "Type", []));
		checkRefactor(RefactorExtractMethod, {fileName: "testcases/methods/SomeHelper.hx", posStart: 820, posEnd: 1168}, edits, async);
	}
}
