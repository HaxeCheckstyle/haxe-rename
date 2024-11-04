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
						case Global | SamePackage | Imported | StarImported:
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

	public static function matchesType(context:RefactorContext, searchTypeOf:SearchTypeOf, searchType:TypeHintType):Promise<Bool> {
		return findTypeOfIdentifier(context, searchTypeOf).then(function(identifierType:Null<TypeHintType>):Bool {
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
					if (type1.fullModuleName != type2.fullModuleName) {
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
		});
	}

	static function findTypeWithTyper(context:RefactorContext, fileName:String, pos:Int):Promise<Null<TypeHintType>> {
		if (context.typer == null) {
			return Promise.reject("no typer");
		}
		return context.typer.resolveType(fileName, pos);
	}

	public static function findTypeOfIdentifier(context:RefactorContext, searchTypeOf:SearchTypeOf):Promise<TypeHintType> {
		var parts:Array<String> = searchTypeOf.name.split(".");

		var part:String = parts.shift();
		return findFieldOrScopedLocal(context, searchTypeOf.defineType, part, searchTypeOf.pos).then(function(type:Null<TypeHintType>):Promise<TypeHintType> {
			var index:Int = 0;
			function findFieldForPart(partType:TypeHintType):Promise<TypeHintType> {
				if (index >= parts.length) {
					return Promise.resolve(partType);
				}
				var part:String = parts[index++];
				switch (partType) {
					case null:
						context.verboseLog('unable to determine type of "$part" in ${searchTypeOf.defineType.file.name}@${searchTypeOf.pos}');
						return Promise.reject('unable to determine type of "$part" in ${searchTypeOf.defineType.file.name}@${searchTypeOf.pos}');
					case KnownType(t, params):
						return findField(context, t, part).then(findFieldForPart);
					case UnknownType(name, _):
						return Promise.reject('unable to determine type of "$part" in ${searchTypeOf.defineType.name.name}@${searchTypeOf.pos}');
				}
			}

			return findFieldForPart(type);
		});
	}

	public static function findFieldOrScopedLocal(context:RefactorContext, containerType:Type, name:String, pos:Int):Promise<TypeHintType> {
		return findTypeWithTyper(context, containerType.file.name, pos).catchError(function(msg):Promise<TypeHintType> {
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
						return Promise.resolve(KnownType(use.defineType, []));
					case ScopedLocal(scopeStart, scopeEnd, _):
						if ((pos >= scopeStart) && (pos <= scopeEnd)) {
							candidate = use;
						}
						if (pos == use.pos.start) {
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
				return Promise.resolve(null);
			}

			var typeHint:Null<Identifier> = candidate.getTypeHint();
			switch (candidate.type) {
				case ScopedLocal(_, _, ForLoop(loopIdent)):
					var index:Int = loopIdent.indexOf(candidate);
					var changes:Array<Promise<TypeHintType>> = [];
					for (child in loopIdent) {
						switch (child.type) {
							case ScopedLocal(_, _, ForLoop(_)):
								continue;
							default:
								changes.push(findTypeOfIdentifier(context, {
									name: child.name,
									pos: child.pos.start,
									defineType: containerType
								}).then(function(data:TypeHintType):Promise<TypeHintType> {
									switch (data) {
										case null:
										case KnownType(_, typeParams) | UnknownType(_, typeParams):
											if (typeParams.length <= index) {
												return Promise.reject("not enough type parameters");
											}
											return typeFromTypeHint(context, typeParams[index]);
									}
									return Promise.reject("not found");
								}));
						}
					}

					var winner:Promise<TypeHintType> = cast Promise.race(changes);
					return winner.catchError(function(data:TypeHintType):Promise<TypeHintType> {
						if (typeHint != null) {
							return typeFromTypeHint(context, typeHint);
						}
						return Promise.reject("type not found");
					});
				case ScopedLocal(_, _, Parameter(params)):
					if (typeHint != null) {
						return typeFromTypeHint(context, typeHint);
					}

					var index:Int = params.indexOf(candidate);
					switch (candidate.parent.type) {
						case CaseLabel(switchIdentifier):
							return findFieldOrScopedLocal(context, containerType, switchIdentifier.name,
								switchIdentifier.pos.start).then(function(enumType:TypeHintType) {
								switch (enumType) {
									case null:
										return Promise.resolve(null);
									case KnownType(type, typeParams):
										switch (type.name.type) {
											case Enum:
												var enumFields:Array<Identifier> = type.findAllIdentifiers((i) -> i.name == candidate.parent.name);
												for (field in enumFields) {
													switch (field.type) {
														case EnumField(params):
															if (params.length <= index) {
																return Promise.resolve(null);
															}
															typeHint = params[index].getTypeHint();
															if (typeHint == null) {
																return Promise.resolve(null);
															}
															return typeFromTypeHint(context, typeHint);
														default:
															return Promise.reject("not an enum field");
													}
												}
											default:
										}
									case UnknownType(_, _):
										return Promise.resolve(null);
								}
								return Promise.resolve(enumType);
							});
						default:
					}
				default:
			}
			if (typeHint != null) {
				return typeFromTypeHint(context, typeHint);
			}
			return Promise.resolve(null);
		});
	}

	public static function findField(context:RefactorContext, containerType:Type, name:String):Promise<TypeHintType> {
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
						return Promise.resolve(null);
					}
					return findField(context, baseType, name);
				case Typedef:
				default:
			}
			return Promise.resolve(null);
		}
		for (use in candidate.uses) {
			switch (use.type) {
				case TypeHint:
					return typeFromTypeHint(context, use);
				default:
			}
		}
		return Promise.resolve(null);
	}

	public static function findBaseClass(typeList:TypeList, type:Type):Null<Type> {
		var baseClasses:Array<Identifier> = type.findAllIdentifiers((i) -> i.type.match(Extends));
		for (base in baseClasses) {
			var candidateTypes:Array<Type> = typeList.findTypeName(base.name);
			for (candidate in candidateTypes) {
				switch (type.file.importsModule(candidate.file.getPackage(), candidate.file.getMainModulName(), candidate.name.name)) {
					case None:
					case ImportedWithAlias(_):
					case Global | SamePackage | Imported | StarImported:
						return candidate;
				}
			}
		}
		return null;
	}

	public static function typeFromTypeHint(context:RefactorContext, hint:Identifier):Promise<TypeHintType> {
		if (hint.name == "Null") {
			if ((hint.uses == null) || (hint.uses.length <= 0)) {
				return Promise.reject();
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
				if (type.fullModuleName == hint.name) {
					return Promise.resolve(KnownType(type, typeParams));
				}
			}
			return Promise.resolve(UnknownType(hint.name, typeParams));
		}
		for (type in allTypes) {
			switch (hint.file.importsModule(type.file.getPackage(), type.file.getMainModulName(), type.name.name)) {
				case None:
				case ImportedWithAlias(_):
				case Global | SamePackage | Imported | StarImported:
					return Promise.resolve(KnownType(type, typeParams));
			}
		}
		// TODO if there's no type found maybe it's because of an import alias
		return Promise.resolve(UnknownType(hint.name, typeParams));
	}

	public static function replaceStaticExtension(context:RefactorContext, changelist:Changelist, identifier:Identifier):Promise<Void> {
		var allUses:Array<Identifier> = context.nameMap.matchIdentifierPart(identifier.name, true);

		if (identifier.uses == null) {
			return Promise.resolve(null);
		}
		var firstParam:Null<Identifier> = null;
		for (use in identifier.uses) {
			switch (use.type) {
				case ScopedLocal(_, _, Parameter(_)):
					firstParam = use;
					break;
				default:
			}
		}
		if (firstParam == null) {
			return Promise.resolve(null);
		}
		var changes:Array<Promise<Void>> = [];
		for (use in firstParam.uses) {
			switch (use.type) {
				case TypeHint:
					changes.push(RenameHelper.typeFromTypeHint(context, use).then(function(firstParamType):Promise<Void> {
						if (firstParamType == null) {
							context.verboseLog("could not find type of first parameter for static extension");
							return Promise.resolve(null);
						}

						var innerChanges:Array<Promise<Void>> = [];
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
							innerChanges.push(RenameHelper.matchesType(context, {
								name: object,
								pos: use.pos.start,
								defineType: use.defineType
							}, firstParamType).then(function(matches:Bool) {
								if (matches) {
									RenameHelper.replaceTextWithPrefix(use, '$object.', context.what.toName, changelist);
								}
							}));
						}
						return Promise.all(innerChanges).then(null);
					}));
				default:
			}
		}
		return Promise.all(changes).then(null);
	}

	public static function replaceSingleAccessOrCall(context:RefactorContext, changelist:Changelist, use:Identifier, fromName:String,
			types:Array<Type>):Promise<Void> {
		var name:String = use.name;
		var index:Int = name.lastIndexOf('.$fromName');
		if (index < 0) {
			switch (use.type) {
				case ArrayAccess(posClosing):
					return replaceArrayAccess(context, changelist, use, fromName, types, posClosing);
				default:
			}
			return Promise.resolve(null);
		}
		name = name.substr(0, index);

		var search:SearchTypeOf = {
			name: name,
			pos: use.pos.start,
			defineType: use.defineType
		};
		return RenameHelper.findTypeOfIdentifier(context, search).then(function(typeHint:TypeHintType) {
			switch (typeHint) {
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
		});
	}

	public static function replaceArrayAccess(context:RefactorContext, changelist:Changelist, use:Identifier, fromName:String, types:Array<Type>,
			posClosing:Int):Promise<Void> {
		var name:String = use.name;

		var search:SearchTypeOf = {
			name: name,
			pos: posClosing,
			defineType: use.defineType
		};
		return RenameHelper.findTypeOfIdentifier(context, search).then(function(typeHint:TypeHintType) {
			switch (typeHint) {
				case null:
				case KnownType(type, _):
					for (t in types) {
						if (t != type) {
							continue;
						}
						var pos:IdentifierPos = {
							fileName: use.pos.fileName,
							start: use.pos.start,
							end: use.pos.end
						};
						pos.end = pos.start + fromName.length;
						changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, pos), use);
					}
				case UnknownType(_, _):
			}
		});
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
