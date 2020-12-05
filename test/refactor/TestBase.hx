package refactor;

import haxe.PosInfos;
import refactor.TestEditableDocument;
import refactor.actions.Refactor;
import refactor.actions.RefactorResult;
import refactor.actions.RefactorWhat;
import refactor.discover.FileList;
import refactor.discover.NameMap;
import refactor.discover.UsageCollector;
import refactor.discover.UsageContext;
import refactor.edits.FileEdit;
import refactor.edits.IEditableDocument;

class TestBase implements ITest {
	var usageContext:UsageContext;

	public function new() {}

	function setupClass() {
		usageContext = {
			fileName: "",
			file: null,
			usageCollector: new UsageCollector(),
			nameMap: new NameMap(),
			fileList: new FileList(),
			type: null
		};

		Cli.traverseSources(["testcases/interfaces"], usageContext);
		usageContext.usageCollector.updateImportHx(usageContext);
	}

	function refactorAndCheck(what:RefactorWhat, edits:Array<TestEdit>, ?pos:PosInfos) {
		var editList:TestEditList = new TestEditList();

		var result:RefactorResult = Refactor.refactor({
			nameMap: usageContext.nameMap,
			fileList: usageContext.fileList,
			what: what,
			forRealExecute: true,
			docFactory: function(fileName:String):IEditableDocument {
				return editList.newDoc(fileName);
			}
		});
		Assert.equals(Done, result, pos);
		Assert.equals(editList.docCounter, editList.docFinishedCounter, pos);
		Assert.equals(edits.length, editList.edits.length);
		for (index in 0...edits.length) {
			var expected:TestEdit = edits[index];
			var actual:TestEdit = editList.edits[index];
			Assert.equals(expected.fileName, actual.fileName, pos);
			Assert.equals(fileEditToString(expected.edit), fileEditToString(actual.edit), pos);
		}
	}

	function fileEditToString(edit:FileEdit):String {
		return switch (edit) {
			case Move(newFileName):
				'Move $newFileName';
			case ReplaceText(text, pos):
				'ReplaceText "$text" ${pos.fileName}@${pos.start}-${pos.end}';
			case InsertText(text, pos):
				'InsertText "$text" ${pos.fileName}@${pos.start}-${pos.end}';
			case RemoveText(pos):
				'RemoveText ${pos.fileName}@${pos.start}-${pos.end}';
		}
	}
}
