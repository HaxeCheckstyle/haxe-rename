package refactor.discover;

class Type {
	var nameMap:NameMap;
	var uses:Array<Identifier>;

	public var file:File;
	public var name:Identifier;

	public function new(file:File, name:Identifier) {
		this.name = name;
		this.file = file;
		nameMap = new NameMap();
		uses = [];
	}

	public function addIdentifier(identifier:Identifier) {
		nameMap.addIdentifier(identifier);
		uses.push(identifier);
	}

	public function getIdentifiers(search:String):Array<Identifier> {
		return nameMap.getIdentifiers(search);
	}

	public function findIdentifier(offset:Int):Null<Identifier> {
		for (use in uses) {
			var identifier:Null<Identifier> = use.findIdentifier(offset);
			if (identifier != null) {
				return use;
			}
		}
		return null;
	}

	public function findAllIdentifiers(matcher:IdentifierMatcher):Array<Identifier> {
		var results:Array<Identifier> = [];
		for (use in uses) {
			if (matcher(use)) {
				results.push(use);
			}
		}
		return results;
	}

	public function getStartsWith(prefix:String):Array<Identifier> {
		return nameMap.getStartsWith(prefix);
	}
}
