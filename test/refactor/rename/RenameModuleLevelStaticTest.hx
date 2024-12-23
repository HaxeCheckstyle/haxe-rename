package refactor.rename;

class RenameModuleLevelStaticTest extends RenameTestBase {
	function setupClass() {
		setupTestSources(["testcases/modulelevelstatics"]);
	}

	public function testRenameSomeFunction(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/modulelevelstatics/StaticFuncs.hx", "logText", 77, 89),
			makeReplaceTestEdit("testcases/modulelevelstatics/StaticFuncs.hx", "logText", 177, 189),
			makeReplaceTestEdit("testcases/modulelevelstatics/pack/Action.hx", "modulelevelstatics.StaticFuncs.logText", 41, 84),
			makeReplaceTestEdit("testcases/modulelevelstatics/pack/Action.hx", "logText", 136, 148),
			makeReplaceTestEdit("testcases/modulelevelstatics/pack/Command.hx", "logText", 163, 175),
			makeReplaceTestEdit("testcases/modulelevelstatics/pack/Command.hx", "logText", 208, 220),
		];
		checkRename({fileName: "testcases/modulelevelstatics/StaticFuncs.hx", toName: "logText", pos: 177}, edits, async);
	}

	public function testRenameSomeVar(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/modulelevelstatics/StaticFuncs.hx", "logText", 102, 109),
			makeReplaceTestEdit("testcases/modulelevelstatics/StaticFuncs.hx", "logText", 134, 141),
			makeReplaceTestEdit("testcases/modulelevelstatics/pack/Command.hx", "logText", 185, 192),
		];
		checkRename({fileName: "testcases/modulelevelstatics/StaticFuncs.hx", toName: "logText", pos: 137}, edits, async);
	}
}
