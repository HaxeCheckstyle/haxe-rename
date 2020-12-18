package refactor;

import haxe.PosInfos;
import refactor.Refactor;
import refactor.RefactorResult;
import refactor.RefactorWhat;
import refactor.TestEditableDocument;
import refactor.discover.FileList;
import refactor.discover.NameMap;
import refactor.discover.TraverseSources;
import refactor.discover.UsageCollector;
import refactor.discover.UsageContext;
import refactor.edits.FileEdit;

class TestBase implements ITest {
	var usageContext:UsageContext;

	public function new() {}

	function setupData(srcFolders:Array<String>) {
		usageContext = {
			fileName: "",
			file: null,
			usageCollector: new UsageCollector(),
			nameMap: new NameMap(),
			fileList: new FileList(),
			type: null
		};

		TraverseSources.traverseSources(srcFolders, usageContext);
		usageContext.usageCollector.updateImportHx(usageContext);
	}

	@:access(refactor.discover.NameMap)
	function setup() {
		for (key => list in usageContext.nameMap.names) {
			for (identifier in list) {
				identifier.edited = false;
			}
		}
	}

	function refactorAndCheck(what:RefactorWhat, edits:Array<TestEdit>, ?pos:PosInfos) {
		var editList:TestEditList = new TestEditList();

		var result:RefactorResult = Refactor.rename({
			nameMap: usageContext.nameMap,
			fileList: usageContext.fileList,
			what: what,
			forRealExecute: true,
			docFactory: (fileName) -> editList.newDoc(fileName),
			verboseLog: function(text:String) {}
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

	function makeMoveTestEdit(oldFileName:String, newFileName):TestEdit {
		return {
			fileName: oldFileName,
			edit: Move(newFileName)
		}
	}

	function makeReplaceTestEdit(fileName:String, text:String, start:Int, end:Int):TestEdit {
		return {
			fileName: fileName,
			edit: ReplaceText(text, {fileName: fileName, start: start, end: end})
		}
	}

	function makeInsertTestEdit(fileName:String, text:String, pos:Int):TestEdit {
		return {
			fileName: fileName,
			edit: InsertText(text, {fileName: fileName, start: pos, end: pos})
		}
	}

	function makeRemoveTestEdit(fileName:String, start:Int, end:Int):TestEdit {
		return {
			fileName: fileName,
			edit: RemoveText({fileName: fileName, start: start, end: end})
		}
	}
}
