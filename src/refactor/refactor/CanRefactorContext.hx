package refactor.refactor;

import refactor.discover.FileReaderFunc;

typedef CanRefactorContext = CacheAndTyperContext & {
	var what:RefactorWhat;
	var fileReader:FileReaderFunc;
	var converter:ByteToCharConverterFunc;
}

typedef ByteToCharConverterFunc = (string:String, byteOffset:Int) -> Int;
