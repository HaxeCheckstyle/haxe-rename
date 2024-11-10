package refactor;

import haxe.PosInfos;
import refactor.edits.Changelist;
import refactor.edits.FileEdit;
import refactor.edits.IEditableDocument;

class TestEditableDocument implements IEditableDocument {
	var editList:TestEditList;
	var fileName:String;

	public function new(fileName:String, editList:TestEditList) {
		this.editList = editList;
		this.fileName = fileName;
	}

	public function addChange(edit:FileEdit) {
		switch (edit) {
			case CreateFile(newFileName):
				Assert.equals(fileName, newFileName);
			case DeleteFile(oldFileName):
				Assert.equals(fileName, oldFileName);
			case Move(newFileName):
				Assert.notEquals(fileName, newFileName);
			case ReplaceText(_, pos, _):
				Assert.equals(fileName, pos.fileName);
			case InsertText(_, pos, _):
				Assert.equals(fileName, pos.fileName);
			case RemoveText(pos):
				Assert.equals(fileName, pos.fileName);
		}
		editList.edits.push({
			fileName: fileName,
			edit: edit,
			pos: null
		});
	}

	public function endEdits() {
		editList.docFinishedCounter++;
	}
}

typedef TestEdit = {
	var fileName:String;
	var edit:FileEdit;
	var pos:PosInfos;
}

class TestEditList {
	public var edits:Array<TestEdit>;
	public var docCounter:Int;
	public var docFinishedCounter:Int;

	public function new() {
		edits = [];
		docCounter = 0;
		docFinishedCounter = 0;
	}

	public function newDoc(fileName:String):IEditableDocument {
		docCounter++;
		return new TestEditableDocument(fileName, this);
	}

	public function sortEdits() {
		edits.sort(sortFileEdits);
	}

	function sortFileEdits(a:TestEdit, b:TestEdit):Int {
		if (a.fileName > b.fileName) {
			return 1;
		}
		if (a.fileName < b.fileName) {
			return -1;
		}
		var offsetA:Int = switch (a.edit) {
			case CreateFile(_): 0;
			case DeleteFile(_): 9999;
			case Move(_): 0;
			case InsertText(_, pos, _): pos.start;
			case ReplaceText(_, pos, _): pos.start;
			case RemoveText(pos): pos.start;
		};
		var offsetB:Int = switch (b.edit) {
			case CreateFile(_): 0;
			case DeleteFile(_): 9999;
			case Move(_): 0;
			case InsertText(_, pos, _): pos.start;
			case ReplaceText(_, pos, _): pos.start;
			case RemoveText(pos): pos.start;
		};
		if (offsetA < offsetB) {
			return -1;
		}
		if (offsetA > offsetB) {
			return 1;
		}
		return 0;
	}
}
