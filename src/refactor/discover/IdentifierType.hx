package refactor.discover;

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
	TypedefField;
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
