package scopedlocal;

import refactor.TestEditableDocument.TestEdit;

function makeReplaceTestEdit(fileName:String, text:String, start:Int, end:Int):TestEdit {
	return {
		fileName: fileName,
		edit: ReplaceText(text, {fileName: fileName, start: start, end: end})
	}
}
