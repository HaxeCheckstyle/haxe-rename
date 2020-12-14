package refactor.rename;

import haxe.io.Path;
import refactor.RefactorContext;
import refactor.RefactorResult;
import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.discover.IdentifierPos;
import refactor.edits.Changelist;

class RenameTypeName {
	public static function refactorTypeName(context:RefactorContext, file:File, identifier:Identifier):RefactorResult {
		var changelist:Changelist = new Changelist(context);
		var packName:String = file.getPackage();
		var mainModuleName:String = file.getMainModulName();
		var path:Path = new Path(file.name);
		if (mainModuleName == identifier.name) {
			// type and filename are identical -> move file
			var newFileName:String = Path.join([path.dir, context.what.toName]) + "." + path.ext;
			changelist.addChange(file.name, Move(newFileName), null);
		}

		var allUses:Null<Array<Identifier>> = context.nameMap.getIdentifiers(identifier.name);
		if (allUses != null) {
			for (use in allUses) {
				switch (use.file.importsModule(packName, mainModuleName, identifier.name)) {
					case None:
						continue;
					case ImportedWithAlias(alias):
						if (alias != identifier.name) {
							continue;
						}
					case Global | SamePackage | Imported:
				}
				changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, use.pos), use);
			}
		}

		allUses = context.nameMap.getStartsWith(identifier.name + ".");
		if (allUses != null) {
			for (use in allUses) {
				var newPos:IdentifierPos = {
					fileName: use.pos.fileName,
					start: use.pos.start,
					end: use.pos.start + identifier.name.length
				}
				changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, newPos), use);
			}
		}

		if (file.packageIdentifier != null) {
			// find all fully qualified modul names of type
			var prefix:String = file.packageIdentifier.name + ".";
			allUses = context.nameMap.getIdentifiers(prefix + identifier.name);
			if (allUses != null) {
				for (use in allUses) {
					RenameHelper.replaceTextWithPrefix(use, prefix, context.what.toName, changelist);
				}
			}
		}

		// TODO handle duplicate type names
		return changelist.execute();
	}
}
