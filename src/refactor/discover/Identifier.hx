package refactor.discover;

class Identifier {
	public var type:IdentifierType;
	public var name:String;
	public var pos:IdentifierPos;
	public var uses:Null<Array<Identifier>>;
	public var file:File;
	public var parent:Null<Identifier>;
	public var defineType:Null<Type>;
	public var edited:Bool;

	public function new(type:IdentifierType, name:String, pos:IdentifierPos, nameMap:NameMap, file:File, defineType:Null<Type>) {
		this.type = type;
		this.name = name;
		this.pos = pos;
		this.file = file;
		this.defineType = defineType;
		parent = null;
		edited = false;

		if (defineType != null) {
			defineType.addIdentifier(this);
		}
		nameMap.addIdentifier(this);
	}

	public function reset() {
		edited = false;
	}

	public function addUse(identifier:Null<Identifier>) {
		if (identifier == null) {
			return;
		}
		if (uses == null) {
			uses = [];
		}
		uses.push(identifier);
		identifier.parent = this;
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
		results.sort(sortIdentifier);
		return results;
	}

	public static function sortIdentifier(a:Identifier, b:Identifier):Int {
		if (a.pos.fileName < b.pos.fileName) {
			return -1;
		}
		if (a.pos.fileName > b.pos.fileName) {
			return 1;
		}
		if (a.pos.start < b.pos.start) {
			return -1;
		}
		if (a.pos.start > b.pos.start) {
			return 1;
		}
		return 0;
	}

	public function getTypeHint():Null<Identifier> {
		if (uses == null) {
			return null;
		}
		for (use in uses) {
			switch (use.type) {
				case TypeHint:
					return use;
				default:
			}
		}
		return null;
	}

	public function toString():String {
		return '$name ${pos.fileName}@${pos.start}-${pos.end} (${type.typeToString()})';
	}
}
