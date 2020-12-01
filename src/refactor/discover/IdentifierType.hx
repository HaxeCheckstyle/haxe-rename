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
	AbstractFrom;
	AbstractTo;
	Prop;
	FieldVar;
	Method;
	TypedParameter;
	TypedefField;
	StructureField;
	InterfaceField;
	TypeHint;
	EnumField;
	CallOrAccess;
	ScopedLocal(scopeEnd:Int);
	StringConst;
}
