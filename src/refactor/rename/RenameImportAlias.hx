package refactor.rename;

import refactor.RefactorContext;
import refactor.RefactorResult;
import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.edits.Changelist;

class RenameImportAlias {
	public static function refactorImportAlias(context:RefactorContext, file:File, identifier:Identifier):RefactorResult {
		var allUses:Array<Identifier> = context.nameMap.getIdentifiers(identifier.name);
		var isImportHx:Bool = (file.getMainModulName() == "import");

		var changelist:Changelist = new Changelist(context);
		for (use in allUses) {
			if (use.file.name == file.name) {
				changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, use.pos), use);
				continue;
			}
			if (isImportHx) {
				if (use.file.importHxFile.name == file.name) {
					changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, use.pos), use);
				}
			}
		}
		return changelist.execute();
	}
}
