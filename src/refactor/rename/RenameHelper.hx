package refactor.rename;

import refactor.discover.Identifier;
import refactor.discover.IdentifierPos;
import refactor.discover.Type;
import refactor.edits.Changelist;

class RenameHelper {
	public static function replaceTextWithPrefix(use:Identifier, prefix:String, to:String, changelist:Changelist) {
		if (prefix.length <= 0) {
			changelist.addChange(use.pos.fileName, ReplaceText(to, use.pos));
		} else {
			var pos:IdentifierPos = {
				fileName: use.pos.fileName,
				start: use.pos.start + prefix.length,
				end: use.pos.end
			};
			changelist.addChange(use.pos.fileName, ReplaceText(to, pos));
		}
	}

	public static function findDescendantTypes(context:RefactorContext, packName:String, baseType:Type):Array<Type> {
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
					var search:String = switch (use.file.importsModule(baseType.file.getPackage(), baseType.file.getMainModulName(), baseType.name.name)) {
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
			for (t in findDescendantTypes(context, type.file.getPackage(), type)) {
				pushType(t);
			}
		}
		return types;
	}

	public static function replaceTypeHintsUses(context:RefactorContext, changelist:Changelist, type:Type, identifier:Identifier) {
		var allUses:Array<Identifier> = context.nameMap.getIdentifiers(type.name.name);
		allUses = allUses.concat(context.nameMap.getIdentifiers(type.getFullModulName()));
		for (use in allUses) {
			switch (use.type) {
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
							var prefix:String = '${use.parent.name}.';
							var allUses2:Array<Identifier> = use.defineType.getIdentifiers('$prefix${identifier.name}');
							var scopeStart:Int = use.pos.start;
							for (use2 in allUses2) {
								if (use2.pos.start < scopeStart) {
									continue;
								}
								if (use2.pos.start > scopeEnd) {
									continue;
								}
								RenameHelper.replaceTextWithPrefix(use2, prefix, context.what.toName, changelist);
							}
						default:
					}
				default:
			}
		}
	}
}
