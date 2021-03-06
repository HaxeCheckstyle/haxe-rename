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
				context.verboseLog('rename package name "${identifier.name}"');
				RenamePackage.refactorPackageName(context, file, identifier);
			case ImportModul | UsingModul:
				Unsupported(identifier.toString());
			case ImportAlias:
				context.verboseLog('rename import alias "${identifier.name}"');
				RenameImportAlias.refactorImportAlias(context, file, identifier);
			case Abstract | Class | Enum | Interface | Typedef:
				context.verboseLog('rename type name "${identifier.name}"');
				RenameTypeName.refactorTypeName(context, file, identifier);
			case ModuleLevelStaticVar | ModuleLevelStaticMethod:
				context.verboseLog('rename module level static "${identifier.name}"');
				RenameModuleLevelStatic.refactorModuleLevelStatic(context, file, identifier);
			case Extends | Implements | AbstractOver | AbstractFrom | AbstractTo | TypeHint | StringConst:
				Unsupported(identifier.toString());
			case Property:
				context.verboseLog('rename property "${identifier.name}"');
				RenameField.refactorField(context, file, identifier, false);
			case FieldVar(isStatic):
				context.verboseLog('rename field "${identifier.name}"');
				RenameField.refactorField(context, file, identifier, isStatic);
			case Method(isStatic):
				context.verboseLog('rename class method "${identifier.name}"');
				RenameField.refactorField(context, file, identifier, isStatic);
			case TypedParameter:
				Unsupported(identifier.toString());
			case TypedefBase:
				Unsupported(identifier.name);
			case TypedefField(fields):
				RenameAnonStructField.refactorAnonStructField(context, file, identifier, fields);
			case StructureField(fields):
				RenameAnonStructField.refactorStructureField(context, file, identifier, fields);
			case InterfaceProperty | InterfaceVar | InterfaceMethod:
				context.verboseLog('rename interface field "${identifier.name}"');
				RenameField.refactorField(context, file, identifier, false);
			case EnumField(_):
				context.verboseLog('rename enum field "${identifier.name}"');
				RenameEnumField.refactorEnumField(context, file, identifier);
			case Call(true):
				Unsupported(identifier.toString());
			case Call(false) | Access:
				context.verboseLog('rename "${identifier.name}" at call/access location - trying to find definition');
				findActualWhat(context, file, identifier);
			case CaseLabel(_):
				Unsupported(identifier.toString());
			case ScopedLocal(scopeEnd, type):
				context.verboseLog('rename scoped local "${identifier.name}" (${type.scopeTypeToString()})');
				RenameScopedLocal.refactorScopedLocal(context, file, identifier, scopeEnd);
		}
	}

	static function findActualWhat(context:RefactorContext, file:File, identifier:Identifier):RefactorResult {
		var parts:Array<String> = identifier.name.split(".");
		if (parts.length <= 0) {
			return Unsupported(identifier.toString());
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
			return Unsupported(identifier.toString());
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
		return Unsupported(identifier.toString());
	}
}
