package typedefs;

import formatter.config.Config;
import typedefs.codedata.TestFormatterInputData;

class TestFormatter {
	public static function format(input:TestFormatterInput, ?config:Config, ?indentOffset:Int):Bool {
		if (config == null) {
			config = new Config();
		}
		var inputData:TestFormatterInputData;
		switch (input) {
			#if sys
			case Code(code, origin):
				inputData = {
					fileName: origin,
					content: code,
					lineSeparator: null,
					entryPoint: null,
					range: null,
					indentOffset: indentOffset
				};
				return true;
			#end
			default:
				return false;
		}
	}
}

enum TestFormatterInput {
	Code(code:String, origin:String);
}
