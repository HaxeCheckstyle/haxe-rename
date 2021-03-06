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

	public static function matchesType(context:RefactorContext, searchTypeOf:SearchTypeOf, searchType:TypeHintType):Bool {
		var identifierType:Null<TypeHintType> = findTypeOfIdentifier(context, searchTypeOf);
		if (identifierType == null) {
			return false;
		}
		switch ([identifierType, searchType]) {
			case [UnknownType(name1, params1), UnknownType(name2, params2)]:
				if (name1 != name2) {
					return false;
				}
				if (params1.length != params2.length) {
					return false;
				}
				for (index in 0...params1.length) {
					if (params1[index].name != params2[index].name) {
						return false;
					}
				}
				return true;
			case [KnownType(type1, params1), KnownType(type2, params2)]:
				if (type1.getFullModulName() != type2.getFullModulName()) {
					return false;
				}
				if (params1.length != params2.length) {
					return false;
				}
				for (index in 0...params1.length) {
					if (params1[index].name != params2[index].name) {
						return false;
					}
				}
				return true;
			default:
				context.verboseLog('types do not match for static extension ${searchTypeOf.name}:${identifierType.printTypeHint()} != ${searchType.printTypeHint()}');
				return false;
		}
	}

	public static function findTypeOfIdentifier(context:RefactorContext, searchTypeOf:SearchTypeOf):Null<TypeHintType> {
		var parts:Array<String> = searchTypeOf.name.split(".");

		var part:String = parts.shift();
		var type:Null<TypeHintType> = findFieldOrScopedLocal(context, searchTypeOf.defineType, part, searchTypeOf.pos);
		switch (type) {
			case null:
				context.verboseLog('unable to determine type of "$part" in ${searchTypeOf.defineType.name.name}');
				return null;
			case KnownType(t, params):
				for (part in parts) {
					type = findField(context, t, part);
					switch (type) {
						case null:
							return type;
						case KnownType(type, params):
							t = type;
						case UnknownType(_, _):
							return type;
					}
				}
				return type;
			case UnknownType(name, _):
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
				case EnumField(_):
					return KnownType(use.defineType, []);
				case ScopedLocal(scopeEnd, _):
					if ((pos >= use.pos.start) && (pos <= scopeEnd)) {
						candidate = use;
					}
				case CaseLabel(switchIdentifier):
					if (use.pos.start == pos) {
						return findFieldOrScopedLocal(context, containerType, switchIdentifier.name, switchIdentifier.pos.start);
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
		var typeHint:Null<Identifier> = candidate.getTypeHint();
		switch (candidate.type) {
			case ScopedLocal(_, ForLoop(loopIdent)):
				var index:Int = loopIdent.indexOf(candidate);
				for (child in loopIdent) {
					switch (child.type) {
						case ScopedLocal(_, ForLoop(_)):
							continue;
						default:
							var iteratorVar:Null<TypeHintType> = findTypeOfIdentifier(context, {
								name: child.name,
								pos: child.pos.start,
								defineType: containerType
							});
							switch (iteratorVar) {
								case null:
								case KnownType(_, typeParams) | UnknownType(_, typeParams):
									if (typeParams.length <= index) {
										continue;
									}
									return typeFromTypeHint(context, typeParams[index]);
							}
					}
				}
			case ScopedLocal(_, Parameter(params)):
				if (typeHint != null) {
					return typeFromTypeHint(context, typeHint);
				}
				var index:Int = params.indexOf(candidate);
				switch (candidate.parent.type) {
					case CaseLabel(switchIdentifier):
						var enumType:Null<TypeHintType> = findFieldOrScopedLocal(context, containerType, switchIdentifier.name, switchIdentifier.pos.start);
						switch (enumType) {
							case null:
								return null;
							case KnownType(type, typeParams):
								switch (type.name.type) {
									case Enum:
										var enumFields:Array<Identifier> = type.findAllIdentifiers((i) -> i.name == candidate.parent.name);
										for (field in enumFields) {
											switch (field.type) {
												case EnumField(params):
													if (params.length <= index) {
														return null;
													}
													typeHint = params[index].getTypeHint();
													if (typeHint == null) {
														return null;
													}
													return typeFromTypeHint(context, typeHint);
												default:
											}
										}

									default:
								}
							case UnknownType(_, _):
								return null;
						}
					default:
				}

			default:
		}
		if (typeHint != null) {
			return typeFromTypeHint(context, typeHint);
		}
		return null;
	}

	public static function findField(context:RefactorContext, containerType:Type, name:String):Null<TypeHintType> {
		var allUses:Array<Identifier> = containerType.getIdentifiers(name);
		var candidate:Null<Identifier> = null;
		for (use in allUses) {
			switch (use.type) {
				case Property | FieldVar(_) | Method(_) | TypedefField(_) | EnumField(_):
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

	public static function typeFromTypeHint(context:RefactorContext, hint:Identifier):Null<TypeHintType> {
		if (hint.name == "Null") {
			if ((hint.uses == null) || (hint.uses.length <= 0)) {
				return null;
			}
			return typeFromTypeHint(context, hint.uses[0]);
		}

		var parts:Array<String> = hint.name.split(".");
		var typeName:String = parts.pop();

		var typeParams:Array<Identifier> = [];
		if (hint.uses != null) {
			for (use in hint.uses) {
				switch (use.type) {
					case TypedParameter:
						typeParams.push(use);
					default:
				}
			}
		}

		var allTypes:Array<Type> = context.typeList.findTypeName(typeName);
		if (parts.length > 0) {
			for (type in allTypes) {
				if (type.getFullModulName() == hint.name) {
					return KnownType(type, typeParams);
				}
			}
			return UnknownType(hint.name, typeParams);
		}
		for (type in allTypes) {
			switch (hint.file.importsModule(type.file.getPackage(), type.file.getMainModulName(), type.name.name)) {
				case None:
				case ImportedWithAlias(_):
				case Global | SamePackage | Imported:
					return KnownType(type, typeParams);
			}
		}
		// TODO if there's no type found maybe it's because of an import alias
		return UnknownType(hint.name, typeParams);
	}

	public static function replaceStaticExtension(context:RefactorContext, changelist:Changelist, identifier:Identifier) {
		var allUses:Array<Identifier> = context.nameMap.matchIdentifierPart(identifier.name, true);

		if (identifier.uses == null) {
			return;
		}
		var firstParam:Null<Identifier> = null;
		for (use in identifier.uses) {
			switch (use.type) {
				case ScopedLocal(_, Parameter(_)):
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
						case KnownType(type, _):
							if (use.parent.name == type.name.name) {
								changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, use.pos), use);
								continue;
							}
						case UnknownType(name, _):
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

	public static function replaceSingleAccessOrCall(context:RefactorContext, changelist:Changelist, use:Identifier, fromName:String, types:Array<Type>) {
		var name:String = use.name;
		var index:Int = name.lastIndexOf('.$fromName');
		if (index < 0) {
			return;
		}
		name = name.substr(0, index);

		var search:SearchTypeOf = {
			name: name,
			pos: use.pos.start,
			defineType: use.defineType
		};
		var typeResult:Null<TypeHintType> = RenameHelper.findTypeOfIdentifier(context, search);
		switch (typeResult) {
			case null:
			case KnownType(type, _):
				for (t in types) {
					if (t != type) {
						continue;
					}
					var pos:IdentifierPos = {
						fileName: use.pos.fileName,
						start: use.pos.start + name.length + 1,
						end: use.pos.end
					};
					pos.end = pos.start + fromName.length;
					changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, pos), use);
				}
			case UnknownType(_, _):
		}
	}
}

typedef SearchTypeOf = {
	var name:String;
	var pos:Int;
	var defineType:Type;
}

enum TypeHintType {
	KnownType(type:Type, typeParams:TypeParameterList);
	UnknownType(name:String, typeParams:TypeParameterList);
}

typedef TypeParameterList = Array<Identifier>;
