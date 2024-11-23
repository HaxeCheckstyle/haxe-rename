package refactor;

import haxe.PosInfos;
import js.lib.Promise;
import refactor.RefactorResult;
import refactor.TestEditableDocument;
import refactor.TypingHelper.TypeHintType;
import refactor.discover.FileList;
import refactor.discover.NameMap;
import refactor.discover.TraverseSources;
import refactor.discover.TypeList;
import refactor.discover.UsageCollector;
import refactor.discover.UsageContext;
import refactor.edits.FileEdit;

class TestBase implements ITest {
	var usageContext:UsageContext;
	var typer:TestTyper;

	public function new() {
		typer = new TestTyper();
	}

	function setupTestSources(srcFolders:Array<String>) {
		usageContext = {
			fileReader: simpleFileReader,
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
		typer.clear();
		for (key => list in usageContext.nameMap.names) {
			for (identifier in list) {
				identifier.edited = false;
			}
		}
	}

	public function addTypeHint(fileName:String, pos:Int, typeHint:TypeHintType) {
		typer.addTypeHint(fileName, pos, typeHint);
	}

	function fileEditToString(edit:FileEdit):String {
		return switch (edit) {
			case CreateFile(newFileName):
				'Create $newFileName';
			case DeleteFile(fileName):
				'Delete $fileName';
			case Move(newFileName):
				'Move $newFileName';
			case ReplaceText(text, pos, format):
				'ReplaceText "$text" ${pos.fileName}@${pos.start}-${pos.end}${format ? " with format" : ""}';
			case InsertText(text, pos, format):
				'InsertText "$text" ${pos.fileName}@${pos.start}-${pos.end}${format ? " with format" : ""}';
			case RemoveText(pos):
				'RemoveText ${pos.fileName}@${pos.start}-${pos.end}';
		}
	}

	function makeCreateTestEdit(newFileName, ?pos:PosInfos):TestEdit {
		return {
			fileName: newFileName,
			edit: CreateFile(newFileName),
			pos: pos
		}
	}

	function makeMoveTestEdit(oldFileName:String, newFileName, ?pos:PosInfos):TestEdit {
		return {
			fileName: oldFileName,
			edit: Move(newFileName),
			pos: pos
		}
	}

	function makeDeleteTestEdit(oldFileName, ?pos:PosInfos):TestEdit {
		return {
			fileName: oldFileName,
			edit: DeleteFile(oldFileName),
			pos: pos
		}
	}

	function makeReplaceTestEdit(fileName:String, text:String, start:Int, end:Int, format:Bool = false, ?pos:PosInfos):TestEdit {
		return {
			fileName: fileName,
			edit: ReplaceText(text, {fileName: fileName, start: start, end: end}, format),
			pos: pos
		}
	}

	function makeInsertTestEdit(fileName:String, text:String, insertPos:Int, format:Bool = false, ?pos:PosInfos):TestEdit {
		return {
			fileName: fileName,
			edit: InsertText(text, {fileName: fileName, start: insertPos, end: insertPos}, format),
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

	function assertEdits(success:RefactorResult, editList:TestEditList, edits:Array<TestEdit>, pos:PosInfos):Promise<RefactorResult> {
		editList.sortEdits();
		Assert.equals(Done, success, pos);
		Assert.equals(editList.docCounter, editList.docFinishedCounter, pos);
		Assert.equals(edits.length, editList.edits.length, pos);
		if (edits.length == editList.edits.length) {
			for (index in 0...edits.length) {
				var expected:TestEdit = edits[index];
				var actual:TestEdit = editList.edits[index];
				Assert.equals(expected.fileName, actual.fileName, expected.pos);
				Assert.equals(fileEditToString(expected.edit), fileEditToString(actual.edit), expected.pos);
			}
		} else {
			for (edit in editList.edits) {
				Sys.println(fileEditToString(edit.edit));
			}
			Assert.fail("length mismatch - edits were not checked", pos);
		}
		return Promise.resolve(success);
	}
}
