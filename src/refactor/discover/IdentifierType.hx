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
	EnumField(params:Array<Identifier>);
	CaseLabel(switchIdentifier:Identifier);
	Call(isNew:Bool);
	ArrayAccess(posClosing:Int);
	Access;
	ForIterator;
	ScopedLocal(scopeStart:Int, scopeEnd:Int, scopeType:ScopedLocalType);
	StringConst;
}

enum ScopedLocalType {
	Parameter(params:Array<Identifier>);
	Var;
	CaseCapture;
	ForLoop(loopIdentifiers:Array<Identifier>);
}

enum TypedefFieldType {
	Required(identifier:Identifier);
	Optional(identifier:Identifier);
}
