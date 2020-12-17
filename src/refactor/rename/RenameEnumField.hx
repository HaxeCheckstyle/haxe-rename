package refactor.rename;

import refactor.RefactorContext;
import refactor.RefactorResult;
import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.edits.Changelist;

class RenameEnumField {
	public static function refactorEnumField(context:RefactorContext, file:File, identifier:Identifier):RefactorResult {
		var changelist:Changelist = new Changelist(context);
		changelist.addChange(identifier.pos.fileName, ReplaceText(context.what.toName, identifier.pos), identifier);

		var packName:String = file.getPackage();
		var mainModuleName:String = file.getMainModulName();
		var typeName:String = identifier.defineType.name.name;
		var fullModuleypeName:String = identifier.defineType.getFullModulName();
		var allUses:Array<Identifier> = context.nameMap.getIdentifiers('$typeName.${identifier.name}');
		for (use in allUses) {
			switch (use.file.importsModule(packName, mainModuleName, typeName)) {
				case None:
					continue;
				case ImportedWithAlias(alias):
					if (alias != typeName) {
						continue;
					}
				case Global:
				case SamePackage:
				case Imported:
			}
			RenameHelper.replaceTextWithPrefix(use, typeName, context.what.toName, changelist);
		}

		allUses = context.nameMap.getIdentifiers('$fullModuleypeName.${identifier.name}');
		for (use in allUses) {
			RenameHelper.replaceTextWithPrefix(use, fullModuleypeName, context.what.toName, changelist);
		}

		allUses = context.nameMap.getIdentifiers('${identifier.name}');
		for (use in allUses) {
			switch (use.file.importsModule(packName, mainModuleName, typeName)) {
				case None:
					continue;
				case ImportedWithAlias(_):
					continue;
				case Global:
				case SamePackage:
				case Imported:
			}
			switch (use.type) {
				case Access:
				case CaseLabel(switchIdentifier):
					if (!RenameHelper.matchesType(context, {
						name: switchIdentifier.name,
						pos: switchIdentifier.pos.start,
						defineType: switchIdentifier.defineType
					}, KnownType(identifier.defineType))) {
						continue;
					}
				default:
					continue;
			}
			RenameHelper.replaceTextWithPrefix(use, "", context.what.toName, changelist);
		}
		return changelist.execute();
	}
}
