package refactor;

import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.rename.RenameAnonStructField;
import refactor.rename.RenameEnumField;
import refactor.rename.RenameField;
import refactor.rename.RenameImportAlias;
import refactor.rename.RenameModuleLevelStatic;
import refactor.rename.RenamePackage;
import refactor.rename.RenameScopedLocal;
import refactor.rename.RenameTypeName;

class Refactor {
	public static function rename(context:RefactorContext):Promise<RefactorResult> {
		var file:Null<File> = context.fileList.getFile(context.what.fileName);
		if (file == null) {
			return Promise.reject(RefactorResult.NotFound.printRefactorResult());
		}
		var identifier:Identifier = file.getIdentifier(context.what.pos);
		if (identifier == null) {
			return Promise.reject(RefactorResult.NotFound.printRefactorResult());
		}
		if (identifier.name == context.what.toName) {
			return Promise.reject(RefactorResult.NotFound.printRefactorResult());
		}
		return switch (identifier.type) {
			case PackageName:
				context.verboseLog('rename package name "${identifier.name}" to "${context.what.toName}"');
				RenamePackage.refactorPackageName(context, file, identifier);
			case ImportModul | UsingModul:
				Promise.reject(RefactorResult.Unsupported(identifier.toString()).printRefactorResult());
			case ImportAlias:
				context.verboseLog('rename import alias "${identifier.name}" to "${context.what.toName}"');
				RenameImportAlias.refactorImportAlias(context, file, identifier);
			case Abstract | Class | Enum | Interface | Typedef:
				context.verboseLog('rename type name "${identifier.name}" to "${context.what.toName}"');
				RenameTypeName.refactorTypeName(context, file, identifier);
			case ModuleLevelStaticVar | ModuleLevelStaticMethod:
				context.verboseLog('rename module level static "${identifier.name}" to "${context.what.toName}"');
				RenameModuleLevelStatic.refactorModuleLevelStatic(context, file, identifier);
			case Extends | Implements | AbstractOver | AbstractFrom | AbstractTo | TypeHint | StringConst:
				Promise.reject(RefactorResult.Unsupported(identifier.toString()).printRefactorResult());
			case Property:
				context.verboseLog('rename property "${identifier.name}" to "${context.what.toName}"');
				RenameField.refactorField(context, file, identifier, false);
			case FieldVar(isStatic):
				context.verboseLog('rename field "${identifier.name}" to "${context.what.toName}"');
				RenameField.refactorField(context, file, identifier, isStatic);
			case Method(isStatic):
				context.verboseLog('rename class method "${identifier.name}" to "${context.what.toName}"');
				RenameField.refactorField(context, file, identifier, isStatic);
			case TypedParameter:
				Promise.reject(RefactorResult.Unsupported(identifier.toString()).printRefactorResult());
			case TypedefBase:
				Promise.reject(RefactorResult.Unsupported(identifier.toString()).printRefactorResult());
			case TypedefField(fields):
				RenameAnonStructField.refactorAnonStructField(context, file, identifier, fields);
			case StructureField(fields):
				RenameAnonStructField.refactorStructureField(context, file, identifier, fields);
			case InterfaceProperty | InterfaceVar | InterfaceMethod:
				context.verboseLog('rename interface field "${identifier.name}" to "${context.what.toName}"');
				RenameField.refactorField(context, file, identifier, false);
			case EnumField(_):
				context.verboseLog('rename enum field "${identifier.name}" to "${context.what.toName}"');
				RenameEnumField.refactorEnumField(context, file, identifier);
			case Call(true):
				Promise.reject(RefactorResult.Unsupported(identifier.toString()).printRefactorResult());
			case Call(false) | Access | ArrayAccess(_) | ForIterator:
				context.verboseLog('rename "${identifier.name}" at call/access location - trying to find definition');
				findActualWhat(context, file, identifier);
			case CaseLabel(_):
				Promise.reject(RefactorResult.Unsupported(identifier.toString()).printRefactorResult());
			case ScopedLocal(scopeEnd, type):
				context.verboseLog('rename scoped local "${identifier.name}" (${type.scopeTypeToString()}) to "${context.what.toName}"');
				RenameScopedLocal.refactorScopedLocal(context, file, identifier, scopeEnd);
		}
	}

	static function findActualWhat(context:RefactorContext, file:File, identifier:Identifier):Promise<RefactorResult> {
		var parts:Array<String> = identifier.name.split(".");
		if (parts.length <= 0) {
			return Promise.reject(RefactorResult.Unsupported(identifier.toString()).printRefactorResult());
		}
		var firstPart:String = parts.shift();
		var onlyFields:Bool = false;
		var offset:Int = 0;
		if (firstPart == "this") {
			firstPart = parts.shift();
			onlyFields = true;
			offset = 5;
		}
		if (context.what.pos > identifier.pos.start + firstPart.length + offset) {
			// rename position is not in first part of dotted identifiier
			return Promise.reject(RefactorResult.Unsupported(identifier.toString()).printRefactorResult());
		}
		var allUses:Array<Identifier> = file.findAllIdentifiers((i) -> i.name == firstPart);
		var candidate:Null<Identifier> = null;
		for (use in allUses) {
			switch (use.type) {
				case Property | FieldVar(_) | Method(_):
					if (identifier.defineType.name != use.defineType.name) {
						continue;
					}
					if (candidate == null) {
						candidate = use;
					}
				case ScopedLocal(scopeEnd, ForLoop(scopeStart, _)) if (!onlyFields):
					if ((scopeStart < identifier.pos.start) && (identifier.pos.start < scopeEnd)) {
						candidate = use;
					}
				case ScopedLocal(scopeEnd, _) if (!onlyFields):
					if ((use.pos.start < identifier.pos.start) && (identifier.pos.start < scopeEnd)) {
						candidate = use;
					}
				default:
			}
		}
		if (candidate != null) {
			context.what.pos = candidate.pos.start;
			return rename(context);
		}
		return Promise.reject(RefactorResult.Unsupported(identifier.toString()).printRefactorResult());
	}
}
