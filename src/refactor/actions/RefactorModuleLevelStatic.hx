package refactor.actions;

import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.edits.Changelist;

class RefactorModuleLevelStatic {
	public static function refactorModuleLevelStatic(context:RefactorContext, file:File, identifier:Identifier) {
		var changelist:Changelist = new Changelist(context);
		// var allUses:Array<Identifier> = context.nameMap.getIdentifiers(identifier.name);
		// for (use in allUses) {
		// 	changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, use.pos));
		// }

		var packageName:String = file.getPackage();
		var mainModulName:String = file.getMainModulName();

		var fullQualified:String = '$packageName.$mainModulName.${identifier.name}';
		var withModul:String = '$mainModulName.${identifier.name}';
		var importModul:String = '$packageName.$mainModulName';

		var allUses:Array<Identifier> = context.nameMap.getIdentifiers(importModul);
		for (use in allUses) {
			if (!use.type.match(ImportModul)) {
				continue;
			}
		}

		changelist.execute();
	}
}
