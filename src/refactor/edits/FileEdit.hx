package refactor.edits;

import refactor.discover.IdentifierPos;

enum FileEdit {
	CreateFile(newFileName:String);
	DeleteFile(fileName:String);
	Move(newFileName:String);
	ReplaceText(text:String, pos:IdentifierPos);
	InsertText(text:String, pos:IdentifierPos);
	RemoveText(pos:IdentifierPos);
}
