package typedefs.codedata;

import haxeparser.Data.Token;
import hxparse.Position;
import tokentree.TokenTree;
import tokentree.TokenTreeBuilder.TokenTreeEntryPoint;

typedef TestFormatterInputData = {
	var fileName:String;
	var content:String;
	@:optional var tokenList:Array<Token>;
	@:optional var tokenTree:TokenTree;
	@:optional var entryPoint:TokenTreeEntryPoint;
	@:optional var lineSeparator:String;
	@:optional var range:Position;
	@:optional var indentOffset:Int;
}
