package refactor;

import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.edits.IEditableDocument;
import refactor.rename.RenameImportAlias;
import refactor.rename.RenameInterfaceField;
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
			case ImportModul:
				Unsupported;
			case ImportAlias:
				RenameImportAlias.refactorImportAlias(context, file, identifier);
			case UsingModul:
				Unsupported;
			case Abstract | Class | Enum | Interface | Typedef:
				RenameTypeName.refactorTypeName(context, file, identifier);
			case ModuleLevelStaticVar | ModuleLevelStaticMethod:
				RenameModuleLevelStatic.refactorModuleLevelStatic(context, file, identifier);
			case Extends | Implements:
				Unsupported;
			case AbstractOver | AbstractFrom | AbstractTo:
				Unsupported;
			case Property | FieldVar | Method:
				RenameInterfaceField.refactorInterfaceField(context, file, identifier);
			case TypedParameter:
				Unsupported;
			case TypedefField:
				Unsupported;
			case StructureField:
				Unsupported;
			case InterfaceProperty | InterfaceVar | InterfaceMethod:
				RenameInterfaceField.refactorInterfaceField(context, file, identifier);
			case TypeHint:
				Unsupported;
			case EnumField:
				Unsupported;
			case CallOrAccess:
				findActualWhat(context, file, identifier);
			case ScopedLocal(scopeEnd):
				RenameScopedLocal.refactorScopedLocal(context, file, identifier, scopeEnd);
			case StringConst:
				Unsupported;
		}
	}

	static function findActualWhat(context:RefactorContext, file:File, identifier:Identifier):RefactorResult {
		var parts:Array<String> = identifier.name.split(".");
		if (parts.length <= 1) {
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
				case ModuleLevelStaticVar:
				case ModuleLevelStaticMethod:
				case Property | FieldVar | Method:
					if (identifier.defineType.name != use.defineType.name) {
						continue;
					}
					if (candidate == null) {
						candidate = use;
					}
				// case TypedefField:
				// case StructureField:
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
