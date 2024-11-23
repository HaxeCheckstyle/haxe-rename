package refactor.refactor.refactormethod;

interface ICodeGen {
	function makeCallSite():String;
	function makeReturnTypeHint():Promise<String>;
	function makeBody():String;
}
