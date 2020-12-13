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
	StructureField;
	InterfaceProperty;
	InterfaceVar;
	InterfaceMethod;
	TypeHint;
	EnumField;
	Call;
	Access;
	ScopedLocal(scopeEnd:Int);
	StringConst;
}
