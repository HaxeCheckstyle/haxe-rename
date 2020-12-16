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
	FieldVar;
	Method;
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
	ScopedLocal(scopeEnd:Int);
	StringConst;
}
