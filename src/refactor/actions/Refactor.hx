package refactor.actions;

import refactor.discover.File;
import refactor.discover.Identifier;

class Refactor {
	public static function refactor(context:RefactorContext) {
		var file:Null<File> = context.fileList.getFile(context.what.fileName);
		if (file == null) {
			return;
		}

		var identifier:Identifier = file.getIdentifier(context.what.pos);
		if (identifier == null) {
			return;
		}
		switch (identifier.type) {
			case PackageName:
				RefactorPackageName.refactorPackageName(context, file, identifier);
			case ImportModul:
			case ImportAlias:
				RefactorImportAlias.refactorImportAlias(context, file, identifier);
			case UsingModul:
			case Abstract | Class | Enum | Interface | Typedef:
				RefactorTypeName.refactorTypeName(context, file, identifier);
			case ModuleLevelStaticVar | ModuleLevelStaticMethod:
				RefactorModuleLevelStatic.refactorModuleLevelStatic(context, file, identifier);
			case Extends | Implements:
				return;
			case AbstractOver | AbstractFrom | AbstractTo:
				return;
			case Property:
			case FieldVar:
			case Method:
			case TypedParameter:
			case TypedefField:
			case StructureField:
			case InterfaceProperty | InterfaceVar | InterfaceMethod:
				RefactorInterfaceField.refactorInterfaceField(context, file, identifier);
			case TypeHint:
			case EnumField:
			case CallOrAccess:
			case ScopedLocal(scopeEnd):
				RefactorScopedLocal.refactorScopedLocal(context, file, identifier, scopeEnd);
			case StringConst:
				return;
		}
	}
}
