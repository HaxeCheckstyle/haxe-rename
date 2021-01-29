package refactor.cache;

import sys.FileStat;
import sys.FileSystem;
import refactor.discover.File;
import refactor.discover.NameMap;

class MemCache implements IFileCache {
	var files:Map<String, File>;

	public function new() {
		clear();
	}

	public function save() {}

	public function clear() {
		files = new Map<String, File>();
	}

	public function storeFile(file:File) {
		files.set(file.name, file);
	}

	public function getFile(name:String, nameMap:NameMap):Null<File> {
		var file:Null<File> = files.get(name);
		if (file == null) {
			return null;
		}
		var stat:FileStat = FileSystem.stat(name);

		if ((file.fileDate != stat.mtime.getTime()) || (file.fileSize != stat.size)) {
			files.remove(name);
			return null;
		}
		if (file.packageIdentifier != null) {
			nameMap.addIdentifier(file.packageIdentifier);
		}
		for (i in file.importList) {
			nameMap.addIdentifier(i.moduleName);
			if (i.alias != null) {
				nameMap.addIdentifier(i.alias);
			}
		}
		for (type in file.typeList) {
			nameMap.addIdentifier(type.name);
			for (use in type.uses) {
				nameMap.addIdentifier(use);
			}
		}

		return file;
	}
}
