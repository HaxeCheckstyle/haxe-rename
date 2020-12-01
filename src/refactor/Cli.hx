package refactor;

import haxe.Timer;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import byte.ByteData;
import refactor.actions.Refactor;
import refactor.actions.RefactorWhat;
import refactor.discover.NameMap;
import refactor.discover.UsageCollector;
import refactor.discover.UsageContext;
import refactor.edits.EditableDocument;

class Cli {
	var verbose:Bool = false;
	var forReal:Bool = false;
	var exitCode:Int = 0;

	static function main() {
		new Cli();
	}

	function new() {
		var args = Sys.args();

		#if neko
		// use the faster JS version if possible
		try {
			var process = new sys.io.Process("node", ["-v"]);
			var nodeExists = process.exitCode() == 0;
			process.close();
			if (nodeExists && FileSystem.exists("bin/refactor.js")) {
				var exitCode = Sys.command("node", ["bin/refactor.js"].concat(args));
				Sys.exit(exitCode);
			}
		} catch (e:Any) {}
		#end

		if (Sys.getEnv("HAXELIB_RUN") == "1") {
			if (args.length > 0) {
				Sys.setCwd(args.pop());
			}
		}

		var paths:Array<String> = [];
		var loc:String = "";
		var toName:String = "";
		var help = false;
		var argHandler = hxargs.Args.generate([
			@doc("file or directory with .hx files (multiple allowed)")
			["-s", "--source"] => function(path:String) paths.push(path),

			@doc("location (path + filename and offset from beginning of file) of identifier to refactor - <src/pack/Filename.hx@123>")
			["-l"] => function(location:String) loc = location,

			@doc("new name for all occurences of identifier")
			["-n"] => function(newName:String) toName = newName,

			// @doc("Print additional information")
			// ["-v"] => function() verbose = true,
			@doc("you have a backup and you really, really want to refactor")
			["--i-have-backups"] => function() forReal = true,

			@doc("display list of options")
			["--help"] => function() help = true
		]);

		function printHelp() {
			var version:String = RefactorVersion.getRefactorVersion();
			Sys.println('Haxe Refactor ${version}');
			Sys.println(argHandler.getDoc());
		}

		try {
			argHandler.parse(args);
		} catch (e:Any) {
			Sys.stderr().writeString(e + "\n");
			printHelp();
			Sys.exit(1);
		}
		if (args.length == 0 || help) {
			printHelp();
			Sys.exit(0);
		}
		var what:Null<RefactorWhat> = makeWhat(loc, toName);
		if (what == null) {
			printHelp();
			Sys.exit(1);
		}

		var usageContext:UsageContext = {
			fileName: "",
			usageCollector: new UsageCollector(),
			nameMap: new NameMap()
		};

		// var startTime = Timer.stamp();
		traverseSources(paths, usageContext);

		Refactor.refactor({
			usageCollector: usageContext.usageCollector,
			nameMap: usageContext.nameMap,
			what: what,
			forRealExecute: forReal,
			docFactory: EditableDocument.new
		});

		// printStats(Timer.stamp() - startTime);
		Sys.exit(exitCode);
	}

	function makeWhat(location:String, toName:String):Null<RefactorWhat> {
		var parts:Array<String> = location.split("@");
		if (parts.length != 2) {
			return null;
		}
		if (parts[0].length <= 0) {
			return null;
		}
		var pos:Null<Int> = Std.parseInt(parts[1]);
		if (pos == null) {
			return null;
		}
		return {
			fileName: parts[0],
			toName: toName,
			pos: pos
		}
	}

	function traverseSources(paths:Array<String>, usageContext:UsageContext) {
		for (path in paths) {
			var path:String = StringTools.trim(path);
			if (!FileSystem.exists(path)) {
				Sys.println('Skipping \'$path\' (path does not exist)');
				continue;
			}
			if (FileSystem.isDirectory(path)) {
				traverseSources([for (file in FileSystem.readDirectory(path)) Path.join([path, file])], usageContext);
			} else {
				usageContext.fileName = path;
				collectIdentifierData(usageContext);
			}
		}
	}

	function collectIdentifierData(usageContext:UsageContext) {
		var content:String = File.getContent(usageContext.fileName);
		usageContext.usageCollector.parseFile(ByteData.ofString(content), usageContext);
	}
}
