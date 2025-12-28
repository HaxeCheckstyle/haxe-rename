package refactor.rename;

class RenameScopedLocalTest extends RenameTestBase {
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
		checkRename({fileName: "testcases/scopedlocal/Refactor.hx", toName: "refactorContext", pos: 463}, edits, async);
	}

	public function testRenameScopeEndCaseCapture(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "endPos", 1964, 1972),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "endPos", 2044, 2052),
		];
		checkRename({fileName: "testcases/scopedlocal/Refactor.hx", toName: "endPos", pos: 1968}, edits, async);
	}

	public function testRenamePackNameParameter(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/StringInterpolation.hx", "packageName", 171, 179),
			makeReplaceTestEdit("testcases/scopedlocal/StringInterpolation.hx", "packageName", 276, 284),
		];
		checkRename({fileName: "testcases/scopedlocal/StringInterpolation.hx", toName: "packageName", pos: 175}, edits, async);
	}

	public function testRenameBaseTypeParameter(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/StringInterpolation.hx", "base", 188, 196),
			makeReplaceTestEdit("testcases/scopedlocal/StringInterpolation.hx", "base", 287, 295),
			makeReplaceTestEdit("testcases/scopedlocal/StringInterpolation.hx", "base", 1124, 1132),
			makeReplaceTestEdit("testcases/scopedlocal/StringInterpolation.hx", "base", 1428, 1436),
		];
		checkRename({fileName: "testcases/scopedlocal/StringInterpolation.hx", toName: "base", pos: 191}, edits, async);
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
		checkRename({fileName: "testcases/scopedlocal/Refactor.hx", toName: "refactorContext", pos: 2020}, edits, async);
	}

	public function testRenameFileNameParameterWithStructureFields(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Structure.hx", "file", 99, 107),
			makeReplaceTestEdit("testcases/scopedlocal/Structure.hx", "file", 182, 190),
			makeReplaceTestEdit("testcases/scopedlocal/Structure.hx", "file", 229, 237),
		];
		checkRename({fileName: "testcases/scopedlocal/Structure.hx", toName: "file", pos: 102}, edits, async);
	}

	public function testRenameFooVar(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2104, 2107),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2139, 2142),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2187, 2190),
		];
		checkRename({fileName: "testcases/scopedlocal/Refactor.hx", toName: "file", pos: 2105}, edits, async);
	}

	public function testRenameFooArray(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2104, 2107),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2139, 2142),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2187, 2190),
		];
		checkRename({fileName: "testcases/scopedlocal/Refactor.hx", toName: "file", pos: 2140}, edits, async);
	}

	public function testRenameFooItem(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2132, 2135),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2155, 2158),
		];
		checkRename({fileName: "testcases/scopedlocal/Refactor.hx", toName: "file", pos: 2133}, edits, async);
	}

	public function testRenameFooItem2(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2173, 2176),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2203, 2206),
		];
		checkRename({fileName: "testcases/scopedlocal/Refactor.hx", toName: "file", pos: 2174}, edits, async);
	}

	public function testRenameValItem(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2180, 2183),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "file", 2218, 2221),
		];
		checkRename({fileName: "testcases/scopedlocal/Refactor.hx", toName: "file", pos: 2181}, edits, async);
	}

	public function testRenameParameterValue(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2271, 2276),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2300, 2305),
		];
		checkRename({fileName: "testcases/scopedlocal/Refactor.hx", toName: "data", pos: 2274}, edits, async);
	}

	public function testRenameParameterValue2(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2426, 2431),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2453, 2458),
		];
		checkRename({fileName: "testcases/scopedlocal/Refactor.hx", toName: "data", pos: 2429}, edits, async);
	}

	public function testRenameLocalValue(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2290, 2295),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2323, 2328),
		];
		checkRename({fileName: "testcases/scopedlocal/Refactor.hx", toName: "data", pos: 2291}, edits, async);
	}

	public function testRenameLocalValue2(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2290, 2295),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2323, 2328),
		];
		checkRename({fileName: "testcases/scopedlocal/Refactor.hx", toName: "data", pos: 2326}, edits, async);
	}

	public function testRenameLocalValue3(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2445, 2450),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2477, 2482),
		];
		checkRename({fileName: "testcases/scopedlocal/Refactor.hx", toName: "data", pos: 2447}, edits, async);
	}

	public function testRenameLocalValue4(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2445, 2450),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2477, 2482),
		];
		checkRename({fileName: "testcases/scopedlocal/Refactor.hx", toName: "data", pos: 2479}, edits, async);
	}

	public function testRenameFieldValue(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2237, 2242),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2315, 2320),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2375, 2380),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2390, 2395),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "data", 2467, 2472),
		];
		checkRename({fileName: "testcases/scopedlocal/Refactor.hx", toName: "data", pos: 2239}, edits, async);
	}

	public function testIssue13RenameUID(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Issue13.hx", "uniqueID", 150, 153),
			makeReplaceTestEdit("testcases/scopedlocal/Issue13.hx", "uniqueID", 183, 186),
			makeReplaceTestEdit("testcases/scopedlocal/Issue13.hx", "uniqueID", 266, 269),
			makeReplaceTestEdit("testcases/scopedlocal/Issue13.hx", "uniqueID", 288, 291),
		];
		checkRename({fileName: "testcases/scopedlocal/Issue13.hx", toName: "uniqueID", pos: 152}, edits, async);
	}

	public function testIssue13RenameFooParameter(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Issue13.hx", "count", 324, 327),
			makeReplaceTestEdit("testcases/scopedlocal/Issue13.hx", "count", 351, 354),
		];
		checkRename({fileName: "testcases/scopedlocal/Issue13.hx", toName: "count", pos: 325}, edits, async);
	}

	public function testIssue13RenameFooLocal(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Issue13.hx", "count", 408, 411),
			makeReplaceTestEdit("testcases/scopedlocal/Issue13.hx", "count", 433, 436),
		];
		checkRename({fileName: "testcases/scopedlocal/Issue13.hx", toName: "count", pos: 409}, edits, async);
	}

	public function testIssue14RenameAnimFinal(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Issue14.hx", "myAnimation", 93, 97),
			makeReplaceTestEdit("testcases/scopedlocal/Issue14.hx", "myAnimation", 114, 118),
			makeReplaceTestEdit("testcases/scopedlocal/Issue14.hx", "myAnimation", 157, 161),
		];
		checkRename({fileName: "testcases/scopedlocal/Issue14.hx", toName: "myAnimation", pos: 96}, edits, async);
	}

	public function testIssue14RenameFooInterpolation(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Issue14.hx", "value", 225, 228),
			makeReplaceTestEdit("testcases/scopedlocal/Issue14.hx", "value", 242, 245),
			makeReplaceTestEdit("testcases/scopedlocal/Issue14.hx", "value", 258, 261),
		];
		checkRename({fileName: "testcases/scopedlocal/Issue14.hx", toName: "value", pos: 227}, edits, async);
	}

	public function testRenameDiff(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "difference", 2538, 2542),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "difference", 2573, 2577),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "difference", 2595, 2599),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "difference", 2635, 2639),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "difference", 2679, 2683),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "difference", 2769, 2773),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "difference", 2844, 2848),
		];
		checkRename({fileName: "testcases/scopedlocal/Refactor.hx", toName: "difference", pos: 2540}, edits, async);
	}
}
