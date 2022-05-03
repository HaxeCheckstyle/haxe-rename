package refactor;

import haxe.PosInfos;
import refactor.edits.IEditableDocument;

typedef RefactorContext = CanRefactorContext & {
	var what:RefactorWhat;
	var forRealExecute:Bool;
	var docFactory:(fileName:String) -> IEditableDocument;
}

typedef VerboseLogger = (text:String, ?pos:PosInfos) -> Void;
