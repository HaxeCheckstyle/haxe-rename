package typedefs;

import haxe.io.Path;
import typedefs.Types.ExtendedIdentifierPos;
import typedefs.Types.IdentifierPos;

class Main {
	static function main() {
		var fileName = Path.join(["..", ".."]);
		var start = 0;
		var end = 0;
		var line = 0;
		var char = 0;
		var msg = "";

		var pos = {
			fileName: fileName,
			start: start,
			end: end
		};

		var posEx:ExtendedIdentifierPos = {
			fileName: fileName,
			start: start,
			end: end,
			line: line,
			char: char
		};
		posEx = {
			fileName: fileName,
			start: start,
			end: end,
			line: line,
			char: char,
			msg: msg
		};

		printIdentifierPos(pos);
		printIdentifierPos(posEx);
		printIdentifierPos({fileName: "file", start: 10, end: 20});
		printIdentifierPos({fileName: fileName, start: 10, end: 20});
	}

	static function printIdentifierPos(pos:IdentifierPos) {
		trace (pos.fileName.length);
	}
	static function printExtendedIdentifierPos(pos:ExtendedIdentifierPos) {
		trace(pos.fileName.length);
	}
}
