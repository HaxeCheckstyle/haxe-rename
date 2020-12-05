package refactor.actions;

import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.discover.Type;
import refactor.edits.Changelist;

class RefactorInterfaceField {
	public static function refactorInterfaceField(context:RefactorContext, file:File, identifier:Identifier):RefactorResult {
		var changelist:Changelist = new Changelist(context);

		function replaceInType(type:Type, from:String, to:String) {
			var allUses:Array<Identifier> = type.getIdentifiers(from);
			for (use in allUses) {
				changelist.addChange(use.pos.fileName, ReplaceText(to, use.pos));
			}
		}

		var packName:String = file.getPackage();
		var types:Array<Type> = findAllTypes(context, packName, identifier.defineType);

		// trace(types.map(t -> t.name.name));
		types.push(identifier.defineType);
		for (type in types) {
			// use of field inside interfaces / classes (self + extending / implementing)
			replaceInType(type, identifier.name, context.what.toName);

			// super calls inside types
			replaceInType(type, 'super.${identifier.name}', 'super.${context.what.toName}');

			// this calls inside types
			replaceInType(type, 'this.${identifier.name}', 'this.${context.what.toName}');

			// property setters / getters
			switch (identifier.type) {
				case InterfaceProperty:
					replaceInType(type, 'set_${identifier.name}', 'set_${context.what.toName}');
					replaceInType(type, 'get_${identifier.name}', 'get_${context.what.toName}');
				default:
			}

			// find typehints that use type and rename those
			checkTypeHints(context, changelist, type, identifier);
		}
		return changelist.execute();
	}

	static function checkTypeHints(context:RefactorContext, changelist:Changelist, type:Type, identifier:Identifier) {
		var allUses:Array<Identifier> = context.nameMap.getIdentifiers(type.name.name);
		allUses = allUses.concat(context.nameMap.getIdentifiers('${type.file.getPackage()}.${type.name.name}'));
		for (use in allUses) {
			switch (use.type) {
				case AbstractFrom:
				case AbstractTo:
				case TypeHint:
					if (use.parent == null) {
						continue;
					}
					switch (use.parent.type) {
						// case ModuleLevelStaticVar:
						// case ModuleLevelStaticMethod:
						// case AbstractFrom:
						// case AbstractTo:
						// case Property:
						// case FieldVar:
						// case Method:
						// case TypedefField:
						// case StructureField:
						// case CallOrAccess:
						case ScopedLocal(scopeEnd):
							var allUses2:Array<Identifier> = use.defineType.getIdentifiers('${use.parent.name}.${identifier.name}');
							var scopeStart:Int = use.pos.start;
							for (use2 in allUses2) {
								if (use2.pos.start < scopeStart) {
									continue;
								}
								if (use2.pos.start > scopeEnd) {
									continue;
								}
								changelist.addChange(use2.pos.fileName, ReplaceText('${use.parent.name}.${context.what.toName}', use2.pos));
							}
						default:
					}
				default:
			}
		}
	}

	static function findAllTypes(context:RefactorContext, packName:String, baseType:Type):Array<Type> {
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
}
