package typehints;

class Main {
	var intIdent:Int;
	var boolIdent:Bool;
	var myTypeIdent:MyType;
	var newTypeIdent:NewType<MyType, Int>;
	var nullNewTypeIdent:Null<NewType<MyType, Int>>;
	var fullNullNewTypeIdent:Null<typehints.Main.NewType<typehints.Main.MyType, Bool>>;
	var intStringBoolIdentOld:Int->String->Bool;
	var intStringBoolIdentNew:(Int, String) -> Bool;
	var loopVoidIdent:(loop:Int) -> Void;
	var loop2VoidIdent:(loop:Int, loop2:Int) -> Void;
	var intStringVoidNullIdent:(Int, String) -> Void = null;

	static function getIntCallBack(intCallback:(value:Int) -> Void):Void {}

	static function getIntStringCallBack(intStringCallback:(value1:Int, value2:String) -> Void):Void {}
}

class MyType {}
class NewType<T:MyType, I> {}
