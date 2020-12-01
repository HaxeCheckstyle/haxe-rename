package refactor.discover;

class File {
	public var name:String;
	public var packageIdentifier:Null<Identifier>;
	public var importList:Array<Import>;
	public var typeList:Array<Identifier>;
	public var importInsertPos:Int;

	public function new(name:String, packageIdentifier:Null<Identifier>, importList:Array<Import>, typeList:Array<Identifier>, importInsertPos:Int) {
		this.name = name;
		this.packageIdentifier = packageIdentifier;
		this.importList = importList;
		this.typeList = typeList;
		this.importInsertPos = importInsertPos;
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
