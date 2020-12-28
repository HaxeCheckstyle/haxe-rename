package typedefs;

import haxe.io.Path;
import typedefs.Types.ExtendedIdentifierPos;

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
	}
}
