package methods;

import refactor.edits.FormatType;

class TestEditDoc {
	var edits:Array<{range:TestRange, newText:String}>;

	public function addChange() {
		final range = posToRange(100);
		final f:FormatType = Format(10);
		var text = "text";
		final filePath = "import.hx";
		switch (f) {
			case NoFormat:
			case Format(indentOffset):
				text = formatSnippet(filePath, text);
				if (range.start.character != 0) {
					range.start.character = 0;
					text = text.ltrim();
				}
		}
		edits.push({range: range, newText: text});
	}

	public function posToRange(pos:Int):TestRange {
		var posNull:TextPosition = {line: 0, character: 0};
		return {start: posNull, end: posNull};
	}

	function formatSnippet(filePath:String, text:String):String {
		return text;
	}
}

typedef TestRange = {
	var start:TextPosition;
	var end:TextPosition;
}

typedef TextPosition = {
	var line:Int;
	var character:Int;
}
