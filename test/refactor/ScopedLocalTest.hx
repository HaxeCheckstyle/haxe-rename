package refactor;

import refactor.TestEditableDocument.TestEdit;

class ScopedLocalTest extends TestBase {
	function setupClass() {
		setupData(["testcases/scopedlocal"]);
	}

	public function testRenameContextParameter() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 498, 505),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext.fileList.getFile", 564, 588),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext.what.fileName", 589, 610),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext.what.pos", 709, 725),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext.what.toName", 805, 824),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 953, 960),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 1084, 1091),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 1242, 1249),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 1382, 1389),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 1858, 1865),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "refactorContext", 2071, 2078),

		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "refactorContext", pos: 504}, edits);
	}

	public function testRenameScopeEndCaseCapture() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "endPos", 2016, 2024),
			makeReplaceTestEdit("testcases/scopedlocal/Refactor.hx", "endPos", 2098, 2106),
		];
		refactorAndCheck({fileName: "testcases/scopedlocal/Refactor.hx", toName: "endPos", pos: 2020}, edits);
	}
}
