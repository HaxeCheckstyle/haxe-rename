package refactor;

import refactor.ITyper;
import refactor.VerboseLogger;
import refactor.discover.FileList;
import refactor.discover.NameMap;
import refactor.discover.TypeList;

typedef CacheAndTyperContext = {
	var nameMap:NameMap;
	var fileList:FileList;
	var typeList:TypeList;
	var verboseLog:VerboseLogger;
	var typer:Null<ITyper>;
}
