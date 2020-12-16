package enums;

enum IdentifierTypeCopy {
	PackageName;
	Call;
	Access;
	ScopedLocal(scopeEnd:Int);
	ScopedGlobal(scopeEnd:Int);
	StringConst;
}
