package refactor;

import haxe.PosInfos;
import refactor.Refactor;
import refactor.RefactorResult;
import refactor.RefactorWhat;
import refactor.TestEditableDocument;
import refactor.discover.FileList;
import refactor.discover.NameMap;
import refactor.discover.TraverseSources;
import refactor.discover.TypeList;
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
			typeList: new TypeList(),
			type: null,
			cache: null
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
			typeList: usageContext.typeList,
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
			Assert.equals(expected.fileName, actual.fileName, expected.pos);
			Assert.equals(fileEditToString(expected.edit), fileEditToString(actual.edit), expected.pos);
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

	function makeMoveTestEdit(oldFileName:String, newFileName, ?pos:PosInfos):TestEdit {
		return {
			fileName: oldFileName,
			edit: Move(newFileName),
			pos: pos
		}
	}

	function makeReplaceTestEdit(fileName:String, text:String, start:Int, end:Int, ?pos:PosInfos):TestEdit {
		return {
			fileName: fileName,
			edit: ReplaceText(text, {fileName: fileName, start: start, end: end}),
			pos: pos
		}
	}

	function makeInsertTestEdit(fileName:String, text:String, insertPos:Int, ?pos:PosInfos):TestEdit {
		return {
			fileName: fileName,
			edit: InsertText(text, {fileName: fileName, start: insertPos, end: insertPos}),
			pos: pos
		}
	}

	function makeRemoveTestEdit(fileName:String, start:Int, end:Int, ?pos:PosInfos):TestEdit {
		return {
			fileName: fileName,
			edit: RemoveText({fileName: fileName, start: start, end: end}),
			pos: pos
		}
	}
}
