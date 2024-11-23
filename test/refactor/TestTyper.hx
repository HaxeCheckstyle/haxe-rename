package refactor;

import js.lib.Promise;
import refactor.TypingHelper.TypeHintType;

using refactor.PrintHelper;

class TestTyper implements ITyper {
	var typeHints:Map<String, TypeHintType>;

	public function new() {
		typeHints = new Map<String, TypeHintType>();
	}

	public function clear() {
		typeHints.clear();
	}

	public function addTypeHint(fileName:String, pos:Int, typeHint:TypeHintType) {
		typeHints.set('$fileName@$pos', typeHint);
	}

	public function resolveType(fileName:String, pos:Int):Promise<Null<TypeHintType>> {
		var typeHint:TypeHintType = typeHints.get('$fileName@$pos');
		trace('[TestTyper] resolving $fileName@$pos -> ${typeHint.typeHintToString()}');
		return Promise.resolve(typeHint);
	}
}
