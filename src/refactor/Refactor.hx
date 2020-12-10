package refactor;

import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.rename.RenameImportAlias;
import refactor.rename.RenameInterfaceField;
import refactor.rename.RenameModuleLevelStatic;
import refactor.rename.RenamePackage;
import refactor.rename.RenameScopedLocal;
import refactor.rename.RenameTypeName;

class Refactor {
	public static function refactor(context:RefactorContext):RefactorResult {
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
			case Property:
				RenameInterfaceField.refactorInterfaceField(context, file, identifier);
			case FieldVar:
				RenameInterfaceField.refactorInterfaceField(context, file, identifier);
			case Method:
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
				Unsupported;
			case ScopedLocal(scopeEnd):
				RenameScopedLocal.refactorScopedLocal(context, file, identifier, scopeEnd);
			case StringConst:
				Unsupported;
		}
	}
}
