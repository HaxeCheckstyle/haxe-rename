package refactor;

import haxe.PosInfos;
import refactor.ITyper;
import refactor.discover.FileList;
import refactor.discover.NameMap;
import refactor.discover.TypeList;
import refactor.edits.IEditableDocument;

typedef RefactorContext = {
	var nameMap:NameMap;
	var fileList:FileList;
	var typeList:TypeList;
	var what:RefactorWhat;
	var forRealExecute:Bool;
	var docFactory:(fileName:String) -> IEditableDocument;
	var verboseLog:VerboseLogger;
	var typer:Null<ITyper>;
}

typedef VerboseLogger = (text:String, ?pos:PosInfos) -> Void;
