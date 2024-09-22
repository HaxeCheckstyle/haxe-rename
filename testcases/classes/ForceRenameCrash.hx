package testcases.classes;

import haxe.macro.Context;
import haxe.macro.Expr;

abstract TestCrash(String) to String {
	public static inline function fail(data:Dynamic):TestCrash {
		return cast '${data.a}_${data.b}_${data.c}_${false}';
	}
}

class TestCrashMacro {
	static function combine(structure:Expr):Expr {
		if (structure.expr.match(EDisplay(_, DKMarked))) {
			return macro @:pos(Context.currentPos()) ($structure : {});
		}
		return Expr();
	}
}
