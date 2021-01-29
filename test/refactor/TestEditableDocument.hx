package refactor;

import haxe.PosInfos;
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
			case Move(newFileName):
				Assert.notEquals(fileName, newFileName);
			case ReplaceText(_, pos):
				Assert.equals(fileName, pos.fileName);
			case InsertText(_, pos):
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
}
