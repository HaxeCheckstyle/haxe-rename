package scopedlocal;

import refactor.RefactorContext;
import refactor.discover.Identifier;
import refactor.discover.Type;

function findAllTypes(context:RefactorContext, packName:String, baseType:Type):Array<Type> {
	var types:Array<Type> = [];
	var fullModulName:String = '$packName.${baseType.name.name}';

	function pushType(newType:Type) {
		for (type in types) {
			if ((type.file.name == newType.file.name) && (type.name.name == newType.name.name)) {
				return;
			}
		}
		types.push(newType);
	}
	function searchImplementingTypes(types:Array<Type>, search:String) {
		for (type in types) {
			for (use in type.getIdentifiers(search)) {
				switch (use.type) {
					case Extends | Implements:
						pushType(use.defineType);
					case AbstractOver:
						pushType(use.defineType);
					default:
				}
			}
		}
	}

	var allUses:Array<Identifier> = context.nameMap.getIdentifiers(fullModulName);
	for (use in allUses) {
		switch (use.type) {
			case ImportModul:
				var search:String = switch (use.file.importsPackage(fullModulName)) {
					case None:
						continue;
					case Global | SamePackage | Imported:
						baseType.name.name;
					case ImportedWithAlias(alias):
						alias;
				}
				searchImplementingTypes(use.file.typeList, search);
			case Extends | Implements:
				pushType(use.defineType);
			case AbstractOver:
				pushType(use.defineType);
			default:
		}
	}
	allUses = context.nameMap.getIdentifiers(baseType.name.name);
	for (use in allUses) {
		switch (use.type) {
			case Extends | Implements:
				pushType(use.defineType);
			case AbstractOver:
				pushType(use.defineType);
			default:
		}
	}

	for (type in types) {
		for (t in findAllTypes(context, type.file.getPackage(), type)) {
			pushType(t);
		}
	}
	return types;
}
