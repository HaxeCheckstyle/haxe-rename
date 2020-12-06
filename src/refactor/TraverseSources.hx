package refactor;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import byte.ByteData;
import refactor.discover.UsageContext;

class TraverseSources {
	public static function traverseSources(paths:Array<String>, usageContext:UsageContext) {
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

	static function collectIdentifierData(usageContext:UsageContext) {
		var content:String = File.getContent(usageContext.fileName);
		usageContext.usageCollector.parseFile(ByteData.ofString(content), usageContext);
	}
}
