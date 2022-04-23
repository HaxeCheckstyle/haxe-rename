package typedefs;

import haxe.extern.EitherType;

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

typedef UserConfig = {
	var enableCodeLens:Bool;
	var enableDiagnostics:Bool;
	var enableServerView:Bool;
	var enableSignatureHelpDocumentation:Bool;
	var diagnosticsPathFilter:String;
	var displayPort:EitherType<Int, String>;
	var buildCompletionCache:Bool;
	var enableCompletionCacheWarning:Bool;
	var useLegacyCompletion:Bool;
	var codeGeneration:CodeGenerationConfig;
	var exclude:Array<String>;
	var postfixCompletion:PostfixCompletionConfig;
	var importsSortOrder:ImportsSortOrderConfig;
	var maxCompletionItems:Int;
	var renameSourceFolders:Array<String>;
}
