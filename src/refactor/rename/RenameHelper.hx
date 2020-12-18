package refactor.rename;

import refactor.discover.Identifier;
import refactor.discover.IdentifierPos;
import refactor.discover.Type;
import refactor.edits.Changelist;

class RenameHelper {
	public static function replaceTextWithPrefix(use:Identifier, prefix:String, to:String, changelist:Changelist) {
		if (prefix.length <= 0) {
			changelist.addChange(use.pos.fileName, ReplaceText(to, use.pos), use);
		} else {
			var pos:IdentifierPos = {
				fileName: use.pos.fileName,
				start: use.pos.start + prefix.length,
				end: use.pos.end
			};
			changelist.addChange(use.pos.fileName, ReplaceText(to, pos), use);
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
						case ScopedLocal(scopeEnd, _):
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

	public static function matchesType(context:RefactorContext, searchTypeOf:SearchTypeOf, searchType:TypeHintType):Bool {
		var identifierType:Null<TypeHintType> = findTypeOfIdentifier(context, searchTypeOf);
		if (identifierType == null) {
			return false;
		}
		return switch ([identifierType, searchType]) {
			case [UnknownType(name1), UnknownType(name2)]:
				name1 == name2;
			case [KnownType(type1), KnownType(type2)]:
				(type1.getFullModulName() == type2.getFullModulName());
			default:
				false;
		}
	}

	public static function findTypeOfIdentifier(context:RefactorContext, searchTypeOf:SearchTypeOf):Null<TypeHintType> {
		var parts:Array<String> = searchTypeOf.name.split(".");

		var part:String = parts.shift();
		var type:Null<TypeHintType> = findFieldOrScopedLocal(context, searchTypeOf.defineType, part, searchTypeOf.pos);
		switch (type) {
			case null:
				return null;
			case KnownType(t):
				for (part in parts) {
					type = findField(context, t, part);
					switch (type) {
						case null:
							return type;
						case KnownType(type):
							t = type;
						case UnknownType(name):
							return type;
					}
				}
				return type;
			case UnknownType(name):
				return type;
		}
	}

	public static function findFieldOrScopedLocal(context:RefactorContext, containerType:Type, name:String, pos:Int):Null<TypeHintType> {
		var allUses:Array<Identifier> = containerType.getIdentifiers(name);
		var candidate:Null<Identifier> = null;
		var fieldCandidate:Null<Identifier> = null;
		for (use in allUses) {
			switch (use.type) {
				case Property | FieldVar | Method(_):
					fieldCandidate = use;
				case TypedefField:
					fieldCandidate = use;
				case EnumField:
					fieldCandidate = use;
				case ScopedLocal(scopeEnd, _):
					if ((pos >= use.pos.start) && (pos <= scopeEnd)) {
						candidate = use;
					}
				default:
			}
		}
		if (candidate == null) {
			candidate = fieldCandidate;
		}
		if (candidate == null) {
			return null;
		}
		for (use in candidate.uses) {
			switch (use.type) {
				case TypeHint:
					return typeFromTypeHint(context, use);
				default:
			}
		}
		return null;
	}

	public static function findField(context:RefactorContext, containerType:Type, name:String):Null<TypeHintType> {
		var allUses:Array<Identifier> = containerType.getIdentifiers(name);
		var candidate:Null<Identifier> = null;
		for (use in allUses) {
			switch (use.type) {
				case Property | FieldVar | Method(_) | TypedefField | EnumField:
					candidate = use;
				default:
			}
		}
		if (candidate == null) {
			return null;
		}
		for (use in candidate.uses) {
			switch (use.type) {
				case TypeHint:
					return typeFromTypeHint(context, use);
				default:
			}
		}
		return null;
	}

	public static function typeFromTypeHint(context:RefactorContext, hint:Identifier):TypeHintType {
		var allUses:Array<Identifier> = context.nameMap.getIdentifiers(hint.name);
		for (use in allUses) {
			switch (use.type) {
				case Abstract | Class | Enum | Interface | Typedef:
					switch (hint.file.importsModule(use.file.getPackage(), use.file.getMainModulName(), use.name)) {
						case None:
						case Global | SamePackage | Imported | ImportedWithAlias(_):
							return KnownType(use.file.getType(use.name));
					}
				default:
			}
		}
		return UnknownType(hint.name);
	}

	public static function replaceStaticExtension(context:RefactorContext, changelist:Changelist, identifier:Identifier) {
		var allUses:Array<Identifier> = context.nameMap.matchIdentifierPart(identifier.name, true);

		var firstParam:Null<Identifier> = null;
		for (use in identifier.uses) {
			switch (use.type) {
				case ScopedLocal(_, Parameter):
					firstParam = use;
					break;
				default:
			}
		}
		if (firstParam == null) {
			return;
		}

		var firstParamType:Null<TypeHintType> = null;
		for (use in firstParam.uses) {
			switch (use.type) {
				case TypeHint:
					firstParamType = RenameHelper.typeFromTypeHint(context, use);
				default:
			}
		}
		if (firstParamType == null) {
			return;
		}

		for (use in allUses) {
			var object:String = use.name.substr(0, use.name.length - identifier.name.length - 1);

			// TODO check for using as well!
			if (!RenameHelper.matchesType(context, {
				name: object,
				pos: use.pos.start,
				defineType: use.defineType
			}, firstParamType)) {
				continue;
			}

			RenameHelper.replaceTextWithPrefix(use, '$object.', context.what.toName, changelist);
		}
	}
}

typedef SearchTypeOf = {
	var name:String;
	var pos:Int;
	var defineType:Type;
}

enum TypeHintType {
	KnownType(type:Type);
	UnknownType(name:String);
}
