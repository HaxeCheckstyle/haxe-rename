package refactor;

import refactor.discover.FileList;
import refactor.discover.NameMap;
import refactor.edits.IEditableDocument;

typedef RefactorContext = {
	var nameMap:NameMap;
	var fileList:FileList;
	var what:RefactorWhat;
	var forRealExecute:Bool;
	var docFactory:(fileName:String) -> IEditableDocument;
}
