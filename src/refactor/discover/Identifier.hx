package refactor.discover;

class Identifier {
	public var type:IdentifierType;
	public var name:String;
	public var pos:IdentifierPos;
	public var uses:Null<Array<Identifier>>;
	public var file:File;
	public var parent:Null<Identifier>;
	public var defineType:Null<Type>;

	public function new(type:IdentifierType, name:String, pos:IdentifierPos, nameMap:NameMap, file:File, defineType:Null<Type>, parent:Null<Identifier>) {
		this.type = type;
		this.name = name;
		this.pos = pos;
		this.file = file;
		this.parent = parent;
		this.defineType = defineType;

		if (defineType != null) {
			defineType.addIdentifier(this);
		}
		if (parent != null) {
			parent.addUse(this);
		}
		nameMap.addIdentifier(this);
	}

	public function addUse(identifier:Identifier) {
		if (uses == null) {
			uses = [];
		}
		uses.push(identifier);
	}

	public function containsPos(offset:Int):Bool {
		return ((pos.start <= offset) && (pos.end >= offset));
	}

	public function findIdentifier(offset:Int):Null<Identifier> {
		if (containsPos(offset)) {
			return this;
		}
		if (uses == null) {
			return null;
		}
		for (use in uses) {
			var identifier:Identifier = use.findIdentifier(offset);
			if (identifier != null) {
				return identifier;
			}
		}
		return null;
	}

	public function findAllIdentifiers(matcher:IdentifierMatcher):Array<Identifier> {
		var results:Array<Identifier> = [];
		if (matcher(this)) {
			results.push(this);
		}
		if (uses == null) {
			return results;
		}
		for (use in uses) {
			results = results.concat(use.findAllIdentifiers(matcher));
		}
		return results;
	}
}
