package refactor.rename;

import refactor.discover.Identifier;
import refactor.discover.IdentifierPos;
import refactor.discover.Type;
import refactor.discover.TypeList;
import refactor.edits.Changelist;
import refactor.typing.TypeHintType;
import refactor.typing.TypingHelper;

class RenameHelper {
	public static function replaceTextWithPrefix(use:Identifier, prefix:String, to:String, changelist:Changelist) {
		if (prefix.length <= 0) {
			changelist.addChange(use.pos.fileName, ReplaceText(to, use.pos, false), use);
		} else {
			var pos:IdentifierPos = {
				fileName: use.pos.fileName,
				start: use.pos.start + prefix.length,
				end: use.pos.end
			};
			changelist.addChange(use.pos.fileName, ReplaceText(to, pos, false), use);
		}
	}

	public static function replaceStaticExtension(context:RenameContext, changelist:Changelist, identifier:Identifier):Promise<Void> {
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
					changes.push(TypingHelper.typeFromTypeHint(context, use).then(function(firstParamType):Promise<Void> {
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
										case ClasspathType(type, _):
											if (use.parent.name == type.name.name) {
												changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, use.pos, false), use);
												continue;
											}
										case LibType(name, _):
											if (use.parent.name == name) {
												changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, use.pos, false), use);
												continue;
											}
										case StructType(fields):
											continue;
										case FunctionType(args, retVal):
											continue;
										case UnknownType(name):
											continue;
									}
								}
								object = use.name;
							} else {
								object = use.name.substr(0, use.name.length - identifier.name.length - 1);
							}
							// TODO check for using as well!

							innerChanges.push(TypingHelper.matchesType(context, {
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

	public static function replaceSingleAccessOrCall(context:RenameContext, changelist:Changelist, use:Identifier, fromName:String,
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
		return TypingHelper.findTypeOfIdentifier(context, search).then(function(typeHint:TypeHintType) {
			switch (typeHint) {
				case null:
				case ClasspathType(type, _):
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
						changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, pos, false), use);
					}
				case LibType(_, _) | UnknownType(_):
				case FunctionType(_, _) | StructType(_):
			}
		});
	}

	public static function replaceArrayAccess(context:RenameContext, changelist:Changelist, use:Identifier, fromName:String, types:Array<Type>,
			posClosing:Int):Promise<Void> {
		var name:String = use.name;

		var search:SearchTypeOf = {
			name: name,
			pos: posClosing,
			defineType: use.defineType
		};
		return TypingHelper.findTypeOfIdentifier(context, search).then(function(typeHint:TypeHintType) {
			switch (typeHint) {
				case null:
				case ClasspathType(type, _):
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
						changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, pos, false), use);
					}
				case LibType(_, _) | UnknownType(_):
					trace("TODO " + typeHint.typeHintToString());
				case FunctionType(_, _) | StructType(_):
					trace("TODO " + typeHint.typeHintToString());
			}
		});
	}
}
