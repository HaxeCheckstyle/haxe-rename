package refactor.rename;

import refactor.RefactorContext;
import refactor.RefactorResult;
import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.edits.Changelist;

class RenameEnumField {
	public static function refactorEnumField(context:RefactorContext, file:File, identifier:Identifier):Promise<RefactorResult> {
		var changelist:Changelist = new Changelist(context);
		changelist.addChange(identifier.pos.fileName, ReplaceText(context.what.toName, identifier.pos), identifier);

		var packName:String = file.getPackage();
		var mainModuleName:String = file.getMainModulName();
		var typeName:String = identifier.defineType.name.name;
		var fullModuleTypeName:String = identifier.defineType.getFullModulName();
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

		allUses = context.nameMap.getIdentifiers('$fullModuleTypeName.${identifier.name}');
		for (use in allUses) {
			RenameHelper.replaceTextWithPrefix(use, fullModuleTypeName, context.what.toName, changelist);
		}

		allUses = context.nameMap.matchIdentifierPart(identifier.name, true);

		var changes:Array<Promise<Void>> = [];
		for (use in allUses) {
			switch (use.type) {
				case CaseLabel(switchIdentifier):
					changes.push(RenameHelper.matchesType(context, {
						name: switchIdentifier.name,
						pos: switchIdentifier.pos.start,
						defineType: switchIdentifier.defineType
					}, KnownType(identifier.defineType, [])).then(function(matched:Bool) {
						if (matched) {
							RenameHelper.replaceTextWithPrefix(use, "", context.what.toName, changelist);
						}
					}));
					continue;
				case Access | Call(false):
					switch (use.parent.type) {
						case Call(_):
						default:
							continue;
					}
					switch (use.file.importsModule(packName, mainModuleName, typeName)) {
						case None:
							continue;
						case ImportedWithAlias(alias):
							if (alias != typeName) {
								continue;
							}
						case Global | SamePackage | Imported:
					}
				default:
					continue;
			}
			RenameHelper.replaceTextWithPrefix(use, "", context.what.toName, changelist);
		}
		return Promise.all(changes).then(function(_):RefactorResult {
			return changelist.execute();
		});
	}
}
