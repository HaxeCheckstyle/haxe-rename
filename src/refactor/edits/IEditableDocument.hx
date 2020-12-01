package refactor.edits;

interface IEditableDocument {
	function addEdit(edit:FileEdit):Void;

	function endEdits():Void;
}
