package refactor.discover;

class NameMap {
	final names:IdentifierMap;
	final parts:IdentifierMap;

	public function new() {
		names = new IdentifierMap();
		parts = new IdentifierMap();
	}

	public function getIdentifiers(name:String):Array<Identifier> {
		var results:Null<Array<Identifier>> = names.get(name);
		if (results == null) {
			return [];
		}
		results.sort(Identifier.sortIdentifier);
		return results;
	}

	public function getIdentifier(name:String, file:String, pos:Int):Null<Identifier> {
		var results:Null<Array<Identifier>> = names.get(name);
		if (results == null) {
			return null;
		}
		for (ident in results) {
			if (ident.file.name != file) {
				continue;
			}
			if (ident.pos.start == pos) {
				return ident;
			}
		}
		return null;
	}

	public function addIdentifier(identifier:Identifier) {
		function addToMap(map:IdentifierMap, key:String) {
			var list:Null<Array<Identifier>> = map.get(key);
			if (list == null) {
				map.set(key, [identifier]);
			} else {
				list.push(identifier);
			}
		}
		identifier.reset();
		addToMap(names, identifier.name);
		var nameParts:Array<String> = identifier.name.split(".");
		for (part in nameParts) {
			addToMap(parts, part);
		}
	}

	public function getStartsWith(prefix:String):Array<Identifier> {
		var results:Array<Identifier> = [];
		for (name => list in names) {
			if (name.startsWith(prefix)) {
				results = results.concat(list);
			}
		}
		results.sort(Identifier.sortIdentifier);
		return results;
	}

	public function matchIdentifierPart(name:String, unused:Bool):Array<Identifier> {
		var results:Null<Array<Identifier>> = parts.get(name);
		if (results == null) {
			return [];
		}
		if (unused) {
			results = results.filter(i -> !i.edited);
			results.sort(Identifier.sortIdentifier);
		}
		return results;
	}
}

typedef IdentifierMap = Map<String, Array<Identifier>>;
