package refactor;

import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.rename.RenameEnumField;
import refactor.rename.RenameField;
import refactor.rename.RenameImportAlias;
import refactor.rename.RenameModuleLevelStatic;
import refactor.rename.RenamePackage;
import refactor.rename.RenameScopedLocal;
import refactor.rename.RenameTypeName;

class Refactor {
	public static function rename(context:RefactorContext):RefactorResult {
		var file:Null<File> = context.fileList.getFile(context.what.fileName);
		if (file == null) {
			return NotFound;
		}
		var identifier:Identifier = file.getIdentifier(context.what.pos);
		if (identifier == null) {
			return NotFound;
		}
		if (identifier.name == context.what.toName) {
			return NoChange;
		}
		return switch (identifier.type) {
			case PackageName:
				RenamePackage.refactorPackageName(context, file, identifier);
			case ImportModul | UsingModul:
				Unsupported;
			case ImportAlias:
				RenameImportAlias.refactorImportAlias(context, file, identifier);
			case Abstract | Class | Enum | Interface | Typedef:
				RenameTypeName.refactorTypeName(context, file, identifier);
			case ModuleLevelStaticVar | ModuleLevelStaticMethod:
				RenameModuleLevelStatic.refactorModuleLevelStatic(context, file, identifier);
			case Extends | Implements | AbstractOver | AbstractFrom | AbstractTo | TypeHint | StringConst:
				Unsupported;
			case Property | FieldVar | Method:
				RenameField.refactorField(context, file, identifier);
			case TypedParameter:
				Unsupported;
			case TypedefField:
				Unsupported;
			case StructureField(_):
				Unsupported;
			case InterfaceProperty | InterfaceVar | InterfaceMethod:
				RenameField.refactorField(context, file, identifier);
			case EnumField:
				RenameEnumField.refactorEnumField(context, file, identifier);
			case Call | Access:
				findActualWhat(context, file, identifier);
			case CaseLabel(_):
				Unsupported;
			case ScopedLocal(scopeEnd):
				RenameScopedLocal.refactorScopedLocal(context, file, identifier, scopeEnd);
		}
	}

	static function findActualWhat(context:RefactorContext, file:File, identifier:Identifier):RefactorResult {
		var parts:Array<String> = identifier.name.split(".");
		if (parts.length <= 0) {
			return Unsupported;
		}
		var firstPart:String = parts[0];
		if (context.what.pos > identifier.pos.start + firstPart.length) {
			// rename position is not in first part of dotted identifiier
			return Unsupported;
		}
		var allUses:Array<Identifier> = file.findAllIdentifiers((i) -> i.name == firstPart);
		var candidate:Null<Identifier> = null;
		for (use in allUses) {
			switch (use.type) {
				case Property | FieldVar | Method:
					if (identifier.defineType.name != use.defineType.name) {
						continue;
					}
					if (candidate == null) {
						candidate = use;
					}
				case ScopedLocal(scopeEnd):
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
		return Unsupported;
	}
}
