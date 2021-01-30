package refactor;

import refactor.rename.RenameHelper.TypeHintType;
import refactor.discover.IdentifierType;

function typeToString(identType:IdentifierType):String {
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
		case ScopedLocal(scopeEnd, scopeType):
			'ScopedLocal($scopeEnd, ${scopeType.scopeTypeToString()})';
		default:
			'$identType';
	}
}

function scopeTypeToString(scopeType:ScopedLocalType):String {
	return switch (scopeType) {
		case Parameter(params):
			'Parameter(${params.map((i) -> '"${i.name}"')})';
		case ForLoop(loopIdentifiers):
			'ForLoop(${loopIdentifiers.map((i) -> '"${i.name}"')})';
		default:
			'$scopeType';
	}
}

function printTypeHint(hintType:TypeHintType):String {
	return switch (hintType) {
		case KnownType(type, params):
			'KnownType(${type.name.name}, ${params.map((i) -> i.name)})';
		case UnknownType(name, params):
			'UnknownType($name, ${params.map((i) -> i.name)})';
	}
}
