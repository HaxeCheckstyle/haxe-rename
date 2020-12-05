package refactor;

import refactor.TestEditableDocument.TestEdit;

class InterfacesTest extends TestBase {
	public function testRenameInterface() {
		var edits:Array<TestEdit> = [
			{
				fileName: "testcases/interfaces/IInterface.hx",
				edit: Move("testcases/interfaces/MyInterface.hx")
			},
			{
				fileName: "testcases/interfaces/IInterface.hx",
				edit: ReplaceText("MyInterface", {
					fileName: "testcases/interfaces/IInterface.hx",
					start: 31,
					end: 41
				})
			},
			{
				fileName: "testcases/interfaces/BaseClass.hx",
				edit: ReplaceText("MyInterface", {
					fileName: "testcases/interfaces/BaseClass.hx",
					start: 48,
					end: 58
				})
			}
		];
		refactorAndCheck({fileName: "testcases/interfaces/IInterface.hx", toName: "MyInterface", pos: 36}, edits);
	}

	public function testRenameInterfaceFieldDoSomething() {
		var edits:Array<TestEdit> = [
			{
				fileName: "testcases/interfaces/IInterface.hx",
				edit: ReplaceText("doIt", {
					fileName: "testcases/interfaces/IInterface.hx",
					start: 75,
					end: 86
				})
			},
			{
				fileName: "testcases/interfaces/BaseClass.hx",
				edit: ReplaceText("doIt", {
					fileName: "testcases/interfaces/BaseClass.hx",
					start: 107,
					end: 118
				})
			},
			{
				fileName: "testcases/interfaces/BaseClass.hx",
				edit: ReplaceText("doIt", {
					fileName: "testcases/interfaces/BaseClass.hx",
					start: 164,
					end: 175
				})
			}
		];
		refactorAndCheck({fileName: "testcases/interfaces/IInterface.hx", toName: "doIt", pos: 78}, edits);
	}

	public function testRenameAnotherInterfaceFieldDoSomething() {
		var edits:Array<TestEdit> = [
			{
				fileName: "testcases/interfaces/pack/sub/IAnotherInterface.hx",
				edit: ReplaceText("doIt", {
					fileName: "testcases/interfaces/pack/sub/IAnotherInterface.hx",
					start: 70,
					end: 81
				})
			}
		];
		refactorAndCheck({fileName: "testcases/interfaces/pack/sub/IAnotherInterface.hx", toName: "doIt", pos: 78}, edits);
	}
}
