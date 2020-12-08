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
		var path:Path = new Path(file.name);
		var changelist:Changelist = new Changelist(context);
		if (path.file == identifier.name) {
			// type and filename are identical -> move file
			var newFileName:String = Path.join([path.dir, context.what.toName]) + "." + path.ext;
			changelist.addChange(file.name, Move(newFileName));
		}

		var allUses:Null<Array<Identifier>> = context.nameMap.getIdentifiers(identifier.name);
		if (allUses != null) {
			for (use in allUses) {
				changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, use.pos));
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
				changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, newPos));
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

			// find all fully qualified modul names of type
			for (type in file.typeList) {
				if (type.name.name == identifier.name) {
					continue;
				}
				var fullSubModulName:String = identifier.name + "." + type.name;
				var newFullSubModulName:String = context.what.toName + "." + type.name;
				allUses = context.nameMap.getIdentifiers(prefix + fullSubModulName);
				if (allUses != null) {
					for (use in allUses) {
						RenameHelper.replaceTextWithPrefix(use, prefix, newFullSubModulName, changelist);
					}
				}
			}
		}

		// TODO handle duplicate type names
		return changelist.execute();
	}
}
