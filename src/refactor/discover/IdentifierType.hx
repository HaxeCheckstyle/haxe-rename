package refactor.discover;

import refactor.discover.Identifier;

enum IdentifierType {
	PackageName;
	ImportModul;
	ImportAlias;
	UsingModul;
	Abstract;
	Class;
	Enum;
	Interface;
	Typedef;
	ModuleLevelStaticVar;
	ModuleLevelStaticMethod;
	Extends;
	Implements;
	AbstractOver;
	AbstractFrom;
	AbstractTo;
	Property;
	FieldVar(isStatic:Bool);
	Method(isStatic:Bool);
	TypedParameter;
	TypedefBase;
	TypedefField(fields:Array<TypedefFieldType>);
	StructureField(fieldNames:Array<String>);
	InterfaceProperty;
	InterfaceVar;
	InterfaceMethod;
	TypeHint;
	EnumField;
	CaseLabel(switchIdentifier:Identifier);
	Call;
	Access;
	ScopedLocal(scopeEnd:Int, scopeType:ScopedLocalType);
	StringConst;
}

enum ScopedLocalType {
	Parameter;
	Var;
	CaseCapture;
	ForLoop;
}

enum TypedefFieldType {
	Required(identifier:Identifier);
	Optional(identifier:Identifier);
}
