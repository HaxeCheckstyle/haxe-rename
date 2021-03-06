package refactor.discover;

import sys.FileSystem;
import sys.FileStat;
import haxe.io.Path;

class File {
	public var name:String;
	public var packageIdentifier:Null<Identifier>;
	public var importHxFile:Null<File>;
	public var importList:Array<Import>;
	public var typeList:Array<Type>;
	public var importInsertPos:Int;
	public var fileDate:Float;
	public var fileSize:Int;

	public function new(name:String) {
		this.name = name;

		var stat:FileStat = FileSystem.stat(name);
		fileDate = stat.mtime.getTime();
		fileSize = stat.size;
	}

	public function init(packageIdent:Null<Identifier>, imports:Array<Import>, types:Array<Type>, posForImport:Int) {
		packageIdentifier = packageIdent;
		importList = imports;
		typeList = types;
		importInsertPos = posForImport;
	}

	public function getPackage():String {
		if (packageIdentifier != null) {
			return packageIdentifier.name;
		}
		return "";
	}

	public function importsModule(packName:String, moduleName:String, typeName:String):ImportStatus {
		if (packName.length <= 0) {
			return Global;
		}
		if (packName == getPackage()) {
			return SamePackage;
		}
		var fullModule:String = '$packName.$moduleName';
		var fullSubModule:Null<String> = null;
		if (moduleName == typeName) {
			fullSubModule = '$fullModule.$typeName';
		}
		for (importEntry in importList) {
			if (importEntry.moduleName.name == fullModule) {
				if (importEntry.alias != null) {
					return ImportedWithAlias(importEntry.alias.name);
				}
				return Imported;
			}
			if (importEntry.moduleName.name == fullSubModule) {
				if (importEntry.alias != null) {
					return ImportedWithAlias(importEntry.alias.name);
				}
				return Imported;
			}
		}

		if (importHxFile == null) {
			return None;
		}
		return importHxFile.importsModule(packName, moduleName, typeName);
	}

	public function getMainModulName():String {
		var path:Path = new Path(name);

		return path.file;
	}

	public function getType(typeName:String):Null<Type> {
		for (type in typeList) {
			if (type.name.name == typeName) {
				return type;
			}
		}
		return null;
	}

	public function getIdentifier(pos:Int):Null<Identifier> {
		if (packageIdentifier != null && packageIdentifier.containsPos(pos)) {
			return packageIdentifier;
		}
		for (imp in importList) {
			if (imp.alias != null && imp.alias.containsPos(pos)) {
				return imp.alias;
			}
			if (imp.moduleName.containsPos(pos)) {
				return imp.moduleName;
			}
		}
		for (type in typeList) {
			var identifier:Identifier = type.findIdentifier(pos);
			if (identifier != null) {
				return identifier;
			}
		}
		return null;
	}

	public function findAllIdentifiers(matcher:IdentifierMatcher):Array<Identifier> {
		var results:Array<Identifier> = [];
		if (packageIdentifier != null && matcher(packageIdentifier)) {
			results.push(packageIdentifier);
		}
		for (imp in importList) {
			if (imp.alias != null && matcher(imp.alias)) {
				results.push(imp.alias);
			}
			if (matcher(imp.moduleName)) {
				results.push(imp.moduleName);
			}
		}
		for (type in typeList) {
			results = results.concat(type.findAllIdentifiers(matcher));
		}
		results.sort(Identifier.sortIdentifier);
		return results;
	}
}

typedef Import = {
	var moduleName:Identifier;
	@:optional var alias:Null<Identifier>;
	var starImport:Bool;
}

typedef ImportAlias = {
	var name:String;
	var pos:IdentifierPos;
}

enum ImportStatus {
	None;
	Global;
	SamePackage;
	Imported;
	ImportedWithAlias(alias:String);
}
