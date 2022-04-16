package refactor.rename;

import refactor.RefactorContext;
import refactor.RefactorResult;
import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.discover.IdentifierPos;
import refactor.discover.Type;
import refactor.edits.Changelist;

class RenameField {
	public static function refactorField(context:RefactorContext, file:File, identifier:Identifier, isStatic:Bool):Promise<RefactorResult> {
		var changelist:Changelist = new Changelist(context);

		var packName:String = file.getPackage();
		var types:Array<Type> = RenameHelper.findDescendantTypes(context, packName, identifier.defineType);

		types.push(identifier.defineType);
		var changes:Array<Promise<Void>> = [];
		for (type in types) {
			// use of field inside interfaces / classes (self + extending / implementing)
			replaceInType(changelist, type, "", identifier.name, context.what.toName);
			replaceInTypeWithFieldAccess(changelist, type, "", identifier.name, context.what.toName);

			// super calls inside types
			replaceInType(changelist, type, "super.", identifier.name, context.what.toName);

			// this calls inside types
			replaceInType(changelist, type, "this.", identifier.name, context.what.toName);
			replaceInTypeWithFieldAccess(changelist, type, "this.", identifier.name, context.what.toName);

			// property setters / getters
			switch (identifier.type) {
				case InterfaceProperty:
					replaceInType(changelist, type, "set_", identifier.name, context.what.toName);
					replaceInType(changelist, type, "get_", identifier.name, context.what.toName);
				default:
			}

			if (isStatic) {
				replaceStaticUse(context, changelist, type, identifier.name);
				switch (identifier.type) {
					case Method(true):
						changes.push(RenameHelper.replaceStaticExtension(context, changelist, identifier));
					default:
				}
			}

			// TODO imports with alias
		}
		changes.push(replaceAccessOrCalls(context, changelist, identifier, types));
		return Promise.all(changes).then(function(_):RefactorResult {
			return changelist.execute();
		});
	}

	public static function replaceAccessOrCalls(context:RefactorContext, changelist:Changelist, identifier:Identifier, types:Array<Type>):Promise<Void> {
		var allUses:Array<Identifier> = context.nameMap.matchIdentifierPart(identifier.name, true);
		var changes:Array<Promise<Void>> = [];
		for (use in allUses) {
			changes.push(RenameHelper.replaceSingleAccessOrCall(context, changelist, use, identifier.name, types));
		}
		return Promise.all(changes).then(null);
	}

	static function replaceInType(changelist:Changelist, type:Type, prefix:String, from:String, to:String) {
		var allUses:Array<Identifier> = type.getIdentifiers(prefix + from);
		var scopeEnd:Int = 0;
		for (use in allUses) {
			if (use.pos.start <= scopeEnd) {
				continue;
			}
			switch (use.type) {
				case ScopedLocal(end, _):
					scopeEnd = end;
					continue;
				case StructureField(_):
					continue;
				default:
			}
			RenameHelper.replaceTextWithPrefix(use, prefix, to, changelist);
		}
	}

	static function replaceInTypeWithFieldAccess(changelist:Changelist, type:Type, prefix:String, from:String, to:String) {
		var allUses:Array<Identifier> = type.getStartsWith('$prefix$from.');
		for (use in allUses) {
			var pos:IdentifierPos = {
				fileName: use.pos.fileName,
				start: use.pos.start + prefix.length,
				end: use.pos.start + prefix.length + from.length
			};
			changelist.addChange(use.pos.fileName, ReplaceText(to, pos), use);
		}
	}

	static function replaceStaticUse(context:RefactorContext, changelist:Changelist, type:Type, fromName:String) {
		var packName:String = type.file.getPackage();
		var allUses:Array<Identifier> = context.nameMap.getIdentifiers('${type.name.name}.$fromName');
		for (use in allUses) {
			switch (use.file.importsModule(packName, type.file.getMainModulName(), type.name.name)) {
				case None:
					continue;
				case ImportedWithAlias(_):
					continue;
				case Global | SamePackage | Imported:
			}
			RenameHelper.replaceTextWithPrefix(use, '${type.name.name}.', context.what.toName, changelist);
		}

		var fullModuleName:String = type.getFullModulName();
		var allUses:Array<Identifier> = context.nameMap.getIdentifiers('$fullModuleName.$fromName');
		for (use in allUses) {
			RenameHelper.replaceTextWithPrefix(use, '$fullModuleName.', context.what.toName, changelist);
		}
	}
}
