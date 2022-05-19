package refactor;

class ScopedLocalTest extends TestBase {
	function setupClass() {
		setupTestSources(["testcases/scopedlocal"]);
	}

	public function testRenameContextParameter(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 460, 467),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 526, 533),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 551, 558),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 671, 678),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 767, 774),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 909, 916),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 1038, 1045),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 1194, 1201),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 1332, 1339),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 1806, 1813),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 2017, 2024),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "refactorContext", pos: 463}, edits, async);
	}

	public function testRenameScopeEndCaseCapture(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "endPos", 1964, 1972),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "endPos", 2044, 2052),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "endPos", pos: 1968}, edits, async);
	}

	public function testRenamePackNameParameter(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/StringInterpolation.hx", "packageName", 171, 179),
			makeReplaceTestEdit("testcases/scopedlocal/StringInterpolation.hx", "packageName", 276, 284),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/StringInterpolation.hx", toName: "packageName", pos: 175}, edits, async);
	}

	public function testRenameBaseTypeParameter(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/StringInterpolation.hx", "base", 188, 196),
			makeReplaceTestEdit("testcases/scopedlocal/StringInterpolation.hx", "base", 287, 295),
			makeReplaceTestEdit("testcases/scopedlocal/StringInterpolation.hx", "base", 1124, 1132),
			makeReplaceTestEdit("testcases/scopedlocal/StringInterpolation.hx", "base", 1428, 1436),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/StringInterpolation.hx", toName: "base", pos: 191}, edits, async);
	}

	public function testRenameBaseTypeParameterFromUse(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 460, 467),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 526, 533),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 551, 558),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 671, 678),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 767, 774),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 909, 916),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 1038, 1045),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 1194, 1201),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 1332, 1339),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 1806, 1813),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 2017, 2024),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "refactorContext", pos: 2020}, edits, async);
	}

	public function testRenameFileNameParameterWithStructureFields(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Structure.hx", "file", 99, 107),
			makeReplaceTestEdit("testcases/scopedlocal/Structure.hx", "file", 182, 190),
			makeReplaceTestEdit("testcases/scopedlocal/Structure.hx", "file", 229, 237),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Structure.hx", toName: "file", pos: 102}, edits, async);
	}

	public function testRenameFooVar(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2104, 2107),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2139, 2142),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2187, 2190),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "file", pos: 2105}, edits, async);
	}

	public function testRenameFooArray(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2104, 2107),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2139, 2142),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2187, 2190),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "file", pos: 2140}, edits, async);
	}

	public function testRenameFooItem(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2132, 2135),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2155, 2158),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "file", pos: 2133}, edits, async);
	}

	public function testRenameFooItem2(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2173, 2176),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2203, 2206),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "file", pos: 2174}, edits, async);
	}

	public function testRenameValItem(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2180, 2183),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2218, 2221),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "file", pos: 2181}, edits, async);
	}

	public function testRenameParameterValue(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2271, 2276),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2300, 2305),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "data", pos: 2274}, edits, async);
	}

	public function testRenameParameterValue2(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2426, 2431),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2453, 2458),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "data", pos: 2429}, edits, async);
	}

	public function testRenameLocalValue(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2290, 2295),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2323, 2328),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "data", pos: 2291}, edits, async);
	}

	public function testRenameLocalValue2(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2290, 2295),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2323, 2328),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "data", pos: 2326}, edits, async);
	}

	public function testRenameLocalValue3(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2445, 2450),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2477, 2482),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "data", pos: 2447}, edits, async);
	}

	public function testRenameLocalValue4(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2445, 2450),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2477, 2482),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "data", pos: 2479}, edits, async);
	}

	public function testRenameFieldValue(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2237, 2242),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2315, 2320),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2375, 2380),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2390, 2395),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2467, 2472),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "data", pos: 2239}, edits, async);
	}
}
