package refactor;

import refactor.TestEditableDocument.TestEdit;

class ScopedLocalTest extends TestBase {
	function setupClass() {
		setupData(["testcases/scopedlocal"]);
	}

	public function testRenameContextParameter() {
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
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "refactorContext", pos: 463}, edits);
	}

	public function testRenameScopeEndCaseCapture() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "endPos", 1964, 1972),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "endPos", 2044, 2052),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "endPos", pos: 1968}, edits);
	}

	public function testRenamePackNameParameter() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/StringInterpolation.hx", "packageName", 171, 179),
			makeReplaceTestEdit("testcases/scopedlocal/StringInterpolation.hx", "packageName", 276, 284),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/StringInterpolation.hx", toName: "packageName", pos: 175}, edits);
	}

	public function testRenameBaseTypeParameter() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/StringInterpolation.hx", "base", 188, 196),
			makeReplaceTestEdit("testcases/scopedlocal/StringInterpolation.hx", "base", 287, 295),
			makeReplaceTestEdit("testcases/scopedlocal/StringInterpolation.hx", "base", 1124, 1132),
			makeReplaceTestEdit("testcases/scopedlocal/StringInterpolation.hx", "base", 1428, 1436),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/StringInterpolation.hx", toName: "base", pos: 191}, edits);
	}
}
