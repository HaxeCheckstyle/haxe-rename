package refactor;

import refactor.discover.IdentifierType;
import refactor.rename.RenameHelper.TypeHintType;

class PrintHelper {
	public static function typeToString(identType:IdentifierType):String {
		return switch (identType) {
			case FieldVar(isStatic):
				'FieldVar(${isStatic})';
			case Method(isStatic):
				'Method(${isStatic})';
			case TypedefField(fields):
				'TypedefField(${fields})';
			case StructureField(fieldNames):
				'StructureField(${fieldNames})';
			case EnumField(params):
				'EnumField(${params.map((p) -> '"${p.name}"')})';
			case CaseLabel(switchIdentifier):
				'CaseLabel(${switchIdentifier.name})';
			case ScopedLocal(scopeStart, scopeEnd, scopeType):
				'ScopedLocal($scopeStart - $scopeEnd, ${scopeType.scopeTypeToString()})';
			default:
				'$identType';
		}
	}

	public static function scopeTypeToString(scopeType:ScopedLocalType):String {
		return switch (scopeType) {
			case Parameter(params):
				'Parameter(${params.map((i) -> '"${i.name}"')})';
			case ForLoop(loopIdentifiers):
				'ForLoop(${loopIdentifiers.map((i) -> '"${i.name}"')})';
			default:
				'$scopeType';
		}
	}

	public static function printTypeHint(hintType:TypeHintType):String {
		return switch (hintType) {
			case KnownType(type, params):
				'KnownType(${type.name.name}, ${params.map((i) -> i.name)})';
			case UnknownType(name, params):
				'UnknownType($name, ${params.map((i) -> i.name)})';
		}
	}

	public static function printRefactorResult(result:RefactorResult):String {
		return switch (result) {
			case NoChange:
				"nothing to do";
			case NotFound:
				"could not find identifier to rename";
			case Unsupported(name):
				"renaming not supported for " + name;
			case DryRun:
				"dry run - no changes were made";
			case Done:
				"rename successful";
		}
	}
}
