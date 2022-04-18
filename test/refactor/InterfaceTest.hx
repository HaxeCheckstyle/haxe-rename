package refactor;

import refactor.TestEditableDocument.TestEdit;

class InterfaceTest extends TestBase {
	function setupClass() {
		setupTestSources(["testcases/interfaces"]);
	}

	public function testRenameInterface(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/interfaces/BaseClass.hx", "MyInterface", 48, 58),
			makeMoveTestEdit("testcases/interfaces/IInterface.hx", "testcases/interfaces/MyInterface.hx"),
			makeReplaceTestEdit("testcases/interfaces/IInterface.hx", "MyInterface", 31, 41),
			makeReplaceTestEdit("testcases/interfaces/pack/sub2/ISubInterface.hx", "MyInterface", 49, 59),
			makeReplaceTestEdit("testcases/interfaces/pack/sub2/ISubInterface.hx", "MyInterface", 94, 104),
		];
		refactorAndCheck({fileName: "testcases/interfaces/IInterface.hx", toName: "MyInterface", pos: 36}, edits, async);
	}

	public function testMoveInterfacePackage(async:Async) {
		var edits:Array<TestEdit> = [
			makeInsertTestEdit("testcases/interfaces/BaseClass.hx", "import interfaces.pack.sub2.IInterface;\n", 21),
			makeMoveTestEdit("testcases/interfaces/IInterface.hx", "testcases/interfaces/pack/sub2/IInterface.hx"),
			makeReplaceTestEdit("testcases/interfaces/IInterface.hx", "interfaces.pack.sub2", 8, 18),
			makeReplaceTestEdit("testcases/interfaces/pack/sub2/ISubInterface.hx", "interfaces.pack.sub2.IInterface", 38, 59),
		];
		refactorAndCheck({fileName: "testcases/interfaces/IInterface.hx", toName: "interfaces.pack.sub2", pos: 13}, edits, async);
	}

	public function testRenameInterfaceFieldDoSomething(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/interfaces/BaseClass.hx", "doIt", 107, 118),
			makeReplaceTestEdit("testcases/interfaces/BaseClass.hx", "doIt", 164, 175),
			makeReplaceTestEdit("testcases/interfaces/IInterface.hx", "doIt", 75, 86),
			makeReplaceTestEdit("testcases/interfaces/pack/SecondChild.hx", "doIt", 153, 164),
			makeReplaceTestEdit("testcases/interfaces/pack/SecondChild.hx", "doIt", 260, 271),
			makeReplaceTestEdit("testcases/interfaces/pack/SecondChild.hx", "doIt", 392, 403),
		];
		refactorAndCheck({fileName: "testcases/interfaces/IInterface.hx", toName: "doIt", pos: 78}, edits, async);
	}

	public function testRenameInterfaceFieldDoSomethingElse(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/interfaces/BaseClass.hx", "doMore", 142, 157),
			makeReplaceTestEdit("testcases/interfaces/ChildChildClass.hx", "doMore", 166, 181),
			makeReplaceTestEdit("testcases/interfaces/ChildClass.hx", "doMore", 111, 126),
			makeReplaceTestEdit("testcases/interfaces/ChildClass.hx", "doMore", 139, 154),
			makeReplaceTestEdit("testcases/interfaces/IInterface.hx", "doMore", 105, 120),
			makeReplaceTestEdit("testcases/interfaces/pack/AbstractChild.hx", "doMore", 102, 117),
			makeReplaceTestEdit("testcases/interfaces/pack/SecondChild.hx", "doMore", 177, 192),
			makeReplaceTestEdit("testcases/interfaces/pack/SecondChild.hx", "doMore", 283, 298),
			makeReplaceTestEdit("testcases/interfaces/pack/SecondChild.hx", "doMore", 415, 430),
		];
		refactorAndCheck({fileName: "testcases/interfaces/IInterface.hx", toName: "doMore", pos: 110}, edits, async);
	}

	public function testRenameAnotherInterfaceFieldDoNothing(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/interfaces/ChildChildClass.hx", "doIt", 188, 197),
			makeReplaceTestEdit("testcases/interfaces/ChildChildClass.hx", "doIt", 222, 231),
			makeReplaceTestEdit("testcases/interfaces/pack/sub/AnotherClass.hx", "doIt", 211, 220),
			makeReplaceTestEdit("testcases/interfaces/pack/sub/IAnotherInterface.hx", "doIt", 134, 143),
		];
		refactorAndCheck({fileName: "testcases/interfaces/pack/sub/IAnotherInterface.hx", toName: "doIt", pos: 139}, edits, async);
	}

	public function testRenameAnotherInterfaceFieldDoSomething(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/interfaces/pack/sub/AnotherClass.hx", "doIt", 137, 148),
			makeReplaceTestEdit("testcases/interfaces/pack/sub/IAnotherInterface.hx", "doIt", 70, 81),
		];
		refactorAndCheck({fileName: "testcases/interfaces/pack/sub/IAnotherInterface.hx", toName: "doIt", pos: 78}, edits, async);
	}

	public function testRenameAnotherInterfaceFieldSomeVar(async:Async) {
		var edits:Array<TestEdit> = [
			makeReplaceTestEdit("testcases/interfaces/ChildChildClass.hx", "state", 250, 258),
			makeReplaceTestEdit("testcases/interfaces/ChildChildClass.hx", "state", 292, 300),
			makeReplaceTestEdit("testcases/interfaces/ChildChildClass.hx", "state", 358, 366),
			makeReplaceTestEdit("testcases/interfaces/pack/sub/AnotherClass.hx", "state", 92, 100),
			makeReplaceTestEdit("testcases/interfaces/pack/sub/AnotherClass.hx", "state", 241, 249),
			makeReplaceTestEdit("testcases/interfaces/pack/sub/AnotherClass.hx", "state", 307, 315),
			makeReplaceTestEdit("testcases/interfaces/pack/sub/IAnotherInterface.hx", "state", 157, 165),
		];
		refactorAndCheck({fileName: "testcases/interfaces/pack/sub/IAnotherInterface.hx", toName: "state", pos: 160}, edits, async);
	}
}
