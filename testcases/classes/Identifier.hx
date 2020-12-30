package classes;

import refactor.discover.File;
import refactor.discover.IdentifierPos;
import refactor.discover.IdentifierType;
import refactor.discover.Type;

class MyIdentifier {
	public var type:IdentifierType;
	public var name:String;
	public var pos:IdentifierPos;
	public var uses:Null<Array<MyIdentifier>>;
	public var file:File;
	public var parent:Null<MyIdentifier>;
	public var defineType:Null<Type>;
	public var edited:Bool;
}
