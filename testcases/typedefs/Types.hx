package typedefs;

typedef IdentifierPos = {
	var fileName:String;
	final start:Int;
	var end:Int;
}

typedef ExtendedIdentifierPos = IdentifierPos & {
	var line:Int;
	final char:Int;
	@:optional var msg:String;
}
