package refactor.rename;

import refactor.ITyper;
import refactor.VerboseLogger;
import refactor.discover.FileList;
import refactor.discover.NameMap;
import refactor.discover.TypeList;

typedef CanRenameContext = {
	var nameMap:NameMap;
	var fileList:FileList;
	var typeList:TypeList;
	var what:RenameWhat;
	var verboseLog:VerboseLogger;
	var typer:Null<ITyper>;
}
