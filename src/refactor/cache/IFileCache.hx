package refactor.cache;

import refactor.discover.NameMap;

interface IFileCache {
	function save():Void;
	function clear():Void;
	function storeFile(file:refactor.discover.File):Void;
	function getFile(name:String, nameMap:NameMap):Null<refactor.discover.File>;
}
