package refactor.edits;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

class EditableDocument implements IEditableDocument {
	var originalContent:String;
	var originalFileName:String;
	var fileName:String;
	var refactoredContent:StringBuf;
	var lastPos:Int;

	public function new(fileName:String) {
		this.fileName = fileName;
		this.originalFileName = fileName;
		originalContent = File.getContent(fileName);
		refactoredContent = new StringBuf();
		lastPos = 0;
	}

	public function addEdit(edit:FileEdit) {
		switch (edit) {
			case Move(newFileName):
				fileName = newFileName;
			case ReplaceText(text, pos):
				refactoredContent.add(originalContent.substring(lastPos, pos.start));
				refactoredContent.add(text);
				lastPos = pos.end;
			case InsertText(text, pos):
				refactoredContent.add(originalContent.substring(lastPos, pos.start));
				refactoredContent.add(text);
				lastPos = pos.start;
			case RemoveText(pos):
				refactoredContent.add(originalContent.substring(lastPos, pos.start));
				lastPos = pos.end;
		}
	}

	public function endEdits() {
		if (lastPos < originalContent.length) {
			refactoredContent.add(originalContent.substring(lastPos, originalContent.length));
		}
		var folder:String = Path.directory(fileName);
		if (!FileSystem.isDirectory(folder)) {
			FileSystem.createDirectory(folder);
		}

		File.saveContent(fileName, refactoredContent.toString());
		if (fileName != originalFileName) {
			FileSystem.deleteFile(originalFileName);
		}
	}
}
