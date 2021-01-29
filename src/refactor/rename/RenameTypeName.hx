package refactor.rename;

import haxe.io.Path;
import refactor.RefactorContext;
import refactor.RefactorResult;
import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.discover.IdentifierPos;
import refactor.edits.Changelist;
import refactor.rename.RenameHelper.TypeHintType;

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
		// replace self
		changelist.addChange(identifier.pos.fileName, ReplaceText(context.what.toName, identifier.pos), identifier);

		var allUses:Array<Identifier>;
		// find all fully qualified modul names of type
		if (file.packageIdentifier != null) {
			var fullName:String = identifier.defineType.getFullModulName();
			var parts:Array<String> = fullName.split(".");
			parts.pop();
			var prefix:String = parts.join(".") + ".";
			allUses = context.nameMap.getIdentifiers(fullName);
			if (allUses != null) {
				for (use in allUses) {
					RenameHelper.replaceTextWithPrefix(use, prefix, context.what.toName, changelist);
				}
			}
		}
		allUses = context.nameMap.matchIdentifierPart(identifier.name, true);
		for (use in allUses) {
			if (use.defineType == null) {
				continue;
			}
			switch (use.file.importsModule(packName, mainModuleName, identifier.name)) {
				case None:
					continue;
				case ImportedWithAlias(alias):
					if (alias != identifier.name) {
						continue;
					}
				case Global | SamePackage | Imported:
			}
			var typeHint:Null<TypeHintType> = RenameHelper.findTypeOfIdentifier(context, {
				name: use.name,
				pos: use.pos.start,
				defineType: use.defineType
			});
			switch (typeHint) {
				case null:
				case KnownType(type, _):
					if (type != identifier.defineType) {
						continue;
					}
				case UnknownType(_):
					continue;
			}
			if (use.name == identifier.name) {
				changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, use.pos), use);
				continue;
			}
			if (use.name.startsWith('${identifier.name}.')) {
				var newPos:IdentifierPos = {
					fileName: use.pos.fileName,
					start: use.pos.start,
					end: use.pos.start + identifier.name.length
				}
				changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, newPos), use);
			}
		}

		return changelist.execute();
	}
}
