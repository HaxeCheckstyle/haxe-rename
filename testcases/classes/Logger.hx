package classes;

import haxe.Exception;
import haxe.PosInfos;

class Log {
	@inject private static var logger:ILogger;

	public static inline function fatal(text:String, ?e:Exception, ?pos:PosInfos):Void {
		logger?.fatal(text, e, pos);
	}

	public static inline function error(text:String, ?e:Exception, ?pos:PosInfos):Void {
		logger?.error(text, e, pos);
	}

	public static inline function warn(text:String, ?e:Exception, ?pos:PosInfos):Void {
		logger?.warn(text, e, pos);
	}

	public static inline function info(text:String, ?e:Exception, ?pos:PosInfos):Void {
		logger?.info(text, e, pos);
	}

	public static inline function debug(text:String, ?e:Exception, ?pos:PosInfos):Void {
		logger?.debug(text, e, pos);
	}

	public static inline function logVersion():Void {
		debug("Version: 1.0");
	}
}

interface ILogger {
	function fatal(text:String, ?e:Exception, ?pos:PosInfos):Void;

	function error(text:String, ?e:Exception, ?pos:PosInfos):Void;

	function warn(text:String, ?e:Exception, ?pos:PosInfos):Void;

	function info(text:String, ?e:Exception, ?pos:PosInfos):Void;

	function debug(text:String, ?e:Exception, ?pos:PosInfos):Void;
}
