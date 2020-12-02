package refactor.actions;

import refactor.actions.RefactorWhat;
import refactor.discover.FileList;
import refactor.discover.NameMap;
import refactor.discover.UsageCollector;
import refactor.edits.IEditableDocument;

typedef RefactorContext = {
	var usageCollector:UsageCollector;
	var nameMap:NameMap;
	var fileList:FileList;
	var what:RefactorWhat;
	var forRealExecute:Bool;
	var docFactory:(fileName:String) -> IEditableDocument;
}
