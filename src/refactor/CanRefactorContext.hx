package refactor;

import refactor.ITyper;
import refactor.RefactorContext;
import refactor.discover.FileList;
import refactor.discover.NameMap;
import refactor.discover.TypeList;

typedef CanRefactorContext = {
	var nameMap:NameMap;
	var fileList:FileList;
	var typeList:TypeList;
	var what:RefactorWhat;
	var verboseLog:VerboseLogger;
	var typer:Null<ITyper>;
}
