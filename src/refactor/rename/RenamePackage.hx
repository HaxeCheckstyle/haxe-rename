package refactor.rename;

import haxe.io.Path;
import refactor.RefactorContext;
import refactor.RefactorResult;
import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.discover.IdentifierPos;
import refactor.edits.Changelist;

class RenamePackage {
	public static function refactorPackageName(context:RefactorContext, file:File, identifier:Identifier):RefactorResult {
		var changelist:Changelist = new Changelist(context);
		var mainTypeName:String = file.getMainModulName();

		var packageNamePrefix:String = "";
		var packageName:String = file.getPackage();
		if (packageName.length > 0) {
			packageNamePrefix = file.packageIdentifier.name + ".";
			changelist.addChange(file.name, ReplaceText(context.what.toName, file.packageIdentifier.pos), identifier);
		} else {
			changelist.addChange(file.name, InsertText('package ${context.what.toName};\n', {fileName: file.name, start: 0, end: 0}), identifier);
		}

		for (type in file.typeList) {
			var typeName:String = if (mainTypeName == type.name.name) {
				type.name.name;
			} else {
				mainTypeName + "." + type.name;
			}
			var fullModulName:String = packageNamePrefix + typeName;
			var newFullModulName:String = context.what.toName + "." + typeName;
			var allUses:Array<Identifier> = context.nameMap.getIdentifiers(fullModulName);
			if (allUses != null) {
				for (use in allUses) {
					changelist.addChange(use.pos.fileName, ReplaceText(newFullModulName, use.pos), use);
				}
			}

			allUses = context.nameMap.getIdentifiers(type.name.name);
			allUses = allUses.concat(context.nameMap.getStartsWith(type.name.name + "."));
			var uniqueFiles:Array<String> = [];
			if (allUses != null) {
				for (use in allUses) {
					if (use.pos.fileName == identifier.pos.fileName) {
						// ignore self
						continue;
					}
					if (uniqueFiles.contains(use.pos.fileName)) {
						// only add once per file
						continue;
					}
					var useFile:Null<File> = context.fileList.getFile(use.pos.fileName);
					if (useFile == null) {
						continue;
					}
					switch (useFile.importsModule(type.file.getPackage(), type.file.getMainModulName(), type.name.name)) {
						case None | SamePackage:
						case Global | Imported | ImportedWithAlias(_):
							// imported old location -> skip (we renamed import in previous loop)
							continue;
					}
					switch (useFile.importsModule(context.what.toName, type.file.getMainModulName(), type.name.name)) {
						case None:
						case Global | SamePackage | Imported | ImportedWithAlias(_):
							// already imports new location -> skip
							continue;
					}
					var importPos:IdentifierPos = {fileName: use.pos.fileName, start: useFile.importInsertPos, end: useFile.importInsertPos}
					changelist.addChange(use.pos.fileName, InsertText('import $newFullModulName;\n', importPos), use);
					uniqueFiles.push(use.pos.fileName);
				}
			}
		}

		// TODO remove redundant imports

		moveFileToPackage(context, file, changelist, packageName);
		return changelist.execute();
	}

	static function moveFileToPackage(context:RefactorContext, file:File, changelist:Changelist, packageName:String) {
		var path:Path = new Path(file.name);
		var mainTypeName:String = file.getMainModulName();

		var dotPath:String = path.dir.replace("/", ".").replace("\\", ".");

		var index:Int = dotPath.indexOf(packageName);
		var pathParts:Array<String> = context.what.toName.split(".");

		var rootPath:String = Path.join(dotPath.substr(0, index).split("."));
		pathParts.unshift(Path.removeTrailingSlashes(rootPath));
		pathParts.push('${mainTypeName}.hx');
		changelist.addChange(file.name, Move(Path.join(pathParts)), null);
	}
}
