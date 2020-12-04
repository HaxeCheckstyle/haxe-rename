package refactor.actions;

import refactor.discover.File;
import refactor.discover.Identifier;

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
				RefactorPackageName.refactorPackageName(context, file, identifier);
			case ImportModul:
				Unsupported;
			case ImportAlias:
				RefactorImportAlias.refactorImportAlias(context, file, identifier);
			case UsingModul:
				Unsupported;
			case Abstract | Class | Enum | Interface | Typedef:
				RefactorTypeName.refactorTypeName(context, file, identifier);
			case ModuleLevelStaticVar | ModuleLevelStaticMethod:
				RefactorModuleLevelStatic.refactorModuleLevelStatic(context, file, identifier);
			case Extends | Implements:
				Unsupported;
			case AbstractOver | AbstractFrom | AbstractTo:
				Unsupported;
			case Property:
				Unsupported;
			case FieldVar:
				Unsupported;
			case Method:
				Unsupported;
			case TypedParameter:
				Unsupported;
			case TypedefField:
				Unsupported;
			case StructureField:
				Unsupported;
			case InterfaceProperty | InterfaceVar | InterfaceMethod:
				RefactorInterfaceField.refactorInterfaceField(context, file, identifier);
			case TypeHint:
				Unsupported;
			case EnumField:
				Unsupported;
			case CallOrAccess:
				Unsupported;
			case ScopedLocal(scopeEnd):
				RefactorScopedLocal.refactorScopedLocal(context, file, identifier, scopeEnd);
			case StringConst:
				Unsupported;
		}
	}
}
