package refactor.rename;

import refactor.discover.Identifier;
import refactor.discover.IdentifierPos;
import refactor.discover.Type;
import refactor.discover.TypeList;
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

	// public static function replaceTypeHintsUses(context:RefactorContext, changelist:Changelist, type:Type, identifier:Identifier) {
	// 	var allUses:Array<Identifier> = context.nameMap.getIdentifiers(type.name.name);
	// 	allUses = allUses.concat(context.nameMap.getIdentifiers(type.getFullModulName()));
	// 	for (use in allUses) {
	// 		switch (use.type) {
	// 			case TypeHint:
	// 				if (use.parent == null) {
	// 					continue;
	// 				}
	// 				switch (use.parent.type) {
	// 					// case ModuleLevelStaticVar:
	// 					// case ModuleLevelStaticMethod:
	// 					// case AbstractFrom:
	// 					// case AbstractTo:
	// 					// case Property:
	// 					// case FieldVar:
	// 					// case Method:
	// 					// case TypedefField:
	// 					// case StructureField:
	// 					// case CallOrAccess:
	// 					case ScopedLocal(scopeEnd, _):
	// 						var prefix:String = '${use.parent.name}.';
	// 						// var allUses2:Array<Identifier> = use.defineType.getIdentifiers('$prefix${identifier.name}');
	// 						var allUses2:Array<Identifier> = use.defineType.findAllIdentifiers((i) -> i.name == '$prefix${identifier.name}'
	// 							|| i.name.startsWith('$prefix${identifier.name}.'));
	// 						var scopeStart:Int = use.pos.start;
	// 						for (use2 in allUses2) {
	// 							if (use2.pos.start < scopeStart) {
	// 								continue;
	// 							}
	// 							if (use2.pos.start > scopeEnd) {
	// 								continue;
	// 							}
	// 							var pos:IdentifierPos = {
	// 								fileName: use2.pos.fileName,
	// 								start: use2.pos.start + prefix.length,
	// 								end: use2.pos.end
	// 							};
	// 							if (use2.name.startsWith('$prefix${identifier.name}.')) {
	// 								pos.end = use2.pos.start + '$prefix${identifier.name}'.length;
	// 							}
	// 							changelist.addChange(use2.pos.fileName, ReplaceText(context.what.toName, pos), use2);
	// 						}
	// 					default:
	// 				}
	// 			default:
	// 		}
	// 	}
	// }

	public static function matchesType(context:RefactorContext, searchTypeOf:SearchTypeOf, searchType:TypeHintType):Bool {
		function printTypeHint(hintType:TypeHintType):String {
			return switch (hintType) {
				case KnownType(type):
					'KnownType($type)';
				case UnknownType(name):
					'UnknownType($name)';
			}
		}

		var identifierType:Null<TypeHintType> = findTypeOfIdentifier(context, searchTypeOf);
		if (identifierType == null) {
			context.verboseLog('could not find type of candidate "${searchTypeOf.name}" for static extension of ${printTypeHint(searchType)}');
			return false;
		}
		return switch ([identifierType, searchType]) {
			case [UnknownType(name1), UnknownType(name2)]:
				name1 == name2;
			case [KnownType(type1), KnownType(type2)]:
				(type1.getFullModulName() == type2.getFullModulName());
			default:
				context.verboseLog('types do not match for static extension ${searchTypeOf.name}:${printTypeHint(identifierType)} != ${printTypeHint(searchType)}');
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
						case UnknownType(_):
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
				case Property | FieldVar(_) | Method(_):
					fieldCandidate = use;
				case TypedefField(_):
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
		if ((candidate == null) || (candidate.uses == null)) {
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
				case Property | FieldVar(_) | Method(_) | TypedefField(_) | EnumField:
					candidate = use;
					break;
				default:
			}
		}
		if ((candidate == null) || (candidate.uses == null)) {
			switch (containerType.name.type) {
				// case Abstract:
				case Class:
					var baseType:Null<Type> = findBaseClass(context.typeList, containerType);
					if (baseType == null) {
						return null;
					}
					return findField(context, baseType, name);
				case Typedef:
				default:
			}
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

	public static function findBaseClass(typeList:TypeList, type:Type):Null<Type> {
		var baseClasses:Array<Identifier> = type.findAllIdentifiers((i) -> i.type.match(Extends));
		for (base in baseClasses) {
			var candidateTypes:Array<Type> = typeList.findTypeName(base.name);
			for (candidate in candidateTypes) {
				switch (type.file.importsModule(candidate.file.getPackage(), candidate.file.getMainModulName(), candidate.name.name)) {
					case None:
					case ImportedWithAlias(_):
					case Global | SamePackage | Imported:
						return candidate;
				}
			}
		}
		return null;
	}

	public static function typeFromTypeHint(context:RefactorContext, hint:Identifier):TypeHintType {
		var parts:Array<String> = hint.name.split(".");
		var typeName:String = parts.pop();

		var allTypes:Array<Type> = context.typeList.findTypeName(typeName);
		if (parts.length > 0) {
			for (type in allTypes) {
				if (type.getFullModulName() == hint.name) {
					return KnownType(type);
				}
			}
			return UnknownType(hint.name);
		}
		for (type in allTypes) {
			switch (hint.file.importsModule(type.file.getPackage(), type.file.getMainModulName(), type.name.name)) {
				case None:
				case ImportedWithAlias(_):
				case Global | SamePackage | Imported:
					return KnownType(type);
			}
		}
		return UnknownType(hint.name);
	}

	public static function replaceStaticExtension(context:RefactorContext, changelist:Changelist, identifier:Identifier) {
		var allUses:Array<Identifier> = context.nameMap.matchIdentifierPart(identifier.name, true);

		if (identifier.uses == null) {
			return;
		}
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
			context.verboseLog("could not find first parameter for static extension");
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
			context.verboseLog("could not find type of first parameter for static extension");
			return;
		}

		for (use in allUses) {
			var object:String = "";
			if (use.name == identifier.name) {
				if (use.parent != null) {
					switch (firstParamType) {
						case null:
						case KnownType(type):
							if (use.parent.name == type.name.name) {
								changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, use.pos), use);
								continue;
							}
						case UnknownType(name):
							if (use.parent.name == name) {
								changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, use.pos), use);
								continue;
							}
					}
				}
				object = use.name;
			} else {
				object = use.name.substr(0, use.name.length - identifier.name.length - 1);
			}

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
