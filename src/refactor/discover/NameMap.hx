package refactor.discover;

class NameMap {
	final names:Map<String, Array<Identifier>>;

	public function new() {
		names = new Map<String, Array<Identifier>>();
	}

	public function getIdentifiers(name:String):Array<Identifier> {
		var results:Null<Array<Identifier>> = names.get(name);
		if (results == null) {
			return [];
		}
		return results;
	}

	public function addIdentifier(identifier:Identifier) {
		var list:Null<Array<Identifier>> = names.get(identifier.name);
		if (list == null) {
			names.set(identifier.name, [identifier]);
		} else {
			list.push(identifier);
		}
	}

	public function getStartsWith(prefix:String):Array<Identifier> {
		var results:Array<Identifier> = [];
		for (name => list in names) {
			if (name.startsWith(prefix)) {
				results = results.concat(list);
			}
		}
		return results;
	}
}
