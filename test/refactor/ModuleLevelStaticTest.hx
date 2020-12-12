package refactor;

import refactor.TestEditableDocument.TestEdit;

class ModuleLevelStaticTest extends TestBase {
	function setupClass() {
		setupData(["testcases/modulelevelstatics"]);
	}

	public function testRenameSomeFunction() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/modulelevelstatics/pack/Command.hx", "logText", 124, 136),
			makeReplaceTestEdit("testcases/modulelevelstatics/pack/Action.hx", "modulelevelstatics.StaticFuncs.logText", 41, 84),
			makeReplaceTestEdit("testcases/modulelevelstatics/pack/Action.hx", "logText", 136, 148),
			makeReplaceTestEdit("testcases/modulelevelstatics/StaticFuncs.hx", "logText", 77, 89),
			makeReplaceTestEdit("testcases/modulelevelstatics/StaticFuncs.hx", "logText", 177, 189),
		];
		refactorAndCheck({fileName: "testcases/modulelevelstatics/StaticFuncs.hx", toName: "logText", pos: 177}, edits);
	}

	public function testRenameSomeVar() {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/modulelevelstatics/pack/Command.hx", "logText", 146, 153),
			makeReplaceTestEdit("testcases/modulelevelstatics/StaticFuncs.hx", "logText", 102, 109),
			makeReplaceTestEdit("testcases/modulelevelstatics/StaticFuncs.hx", "logText", 134, 141),
		];
		refactorAndCheck({fileName: "testcases/modulelevelstatics/StaticFuncs.hx", toName: "logText", pos: 137}, edits);
	}
}
