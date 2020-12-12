package refactor.rename;

import refactor.RefactorContext;
import refactor.RefactorResult;
import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.discover.Type;
import refactor.edits.Changelist;

class RenameInterfaceField {
	public static function refactorInterfaceField(context:RefactorContext, file:File, identifier:Identifier):RefactorResult {
		var changelist:Changelist = new Changelist(context);

		function replaceInType(type:Type, prefix:String, from:String, to:String) {
			var allUses:Array<Identifier> = type.getIdentifiers(prefix + from);
			for (use in allUses) {
				RenameHelper.replaceTextWithPrefix(use, prefix, to, changelist);
			}
		}

		var packName:String = file.getPackage();
		var types:Array<Type> = RenameHelper.findDescendantTypes(context, packName, identifier.defineType);

		// trace(types.map(t -> t.name.name));
		types.push(identifier.defineType);
		for (type in types) {
			// use of field inside interfaces / classes (self + extending / implementing)
			replaceInType(type, "", identifier.name, context.what.toName);

			// super calls inside types
			replaceInType(type, "super.", identifier.name, context.what.toName);

			// this calls inside types
			replaceInType(type, "this.", identifier.name, context.what.toName);

			// property setters / getters
			switch (identifier.type) {
				case InterfaceProperty:
					replaceInType(type, "set_", identifier.name, context.what.toName);
					replaceInType(type, "get_", identifier.name, context.what.toName);
				default:
			}

			// find typehints that use type and rename those
			RenameHelper.replaceTypeHintsUses(context, changelist, type, identifier);

			replaceStaticUse(context, changelist, type, identifier.name);

			// TODO imports with alias
		}
		return changelist.execute();
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
