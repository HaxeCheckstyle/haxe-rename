package testcases.methods;

import haxe.macro.Context;
import haxe.macro.Expr;

class MacroTools {
	macro public static function build():Array<Field> {
		var fields = Context.getBuildFields();
		for (field in fields) {
			switch field.kind {
				case FFun(f):
					var expr = f.expr;
				// Complex manipulation...
				default:
			}
		}
		return fields;
	}
}
