package enums;

enum IdentifierType {
	PackageName;
	Call;
	Access;
	ScopedLocal(scopeEnd:Int);
	ScopedGlobal(scopeEnd:Int);
	StringConst;
}
