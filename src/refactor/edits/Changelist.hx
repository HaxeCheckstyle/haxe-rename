package refactor.edits;

import haxe.io.Bytes;
import sys.io.File;
import refactor.RefactorContext;
import refactor.RefactorResult;
import refactor.discover.Identifier;
import refactor.discover.IdentifierPos;

class Changelist {
	var changes:Map<String, Array<FileEdit>>;
	var context:RefactorContext;

	public function new(context:RefactorContext) {
		changes = new Map<String, Array<FileEdit>>();
		this.context = context;
	}

	public function addChange(fileName:String, change:FileEdit, identifier:Null<Identifier>) {
		if (identifier != null) {
			if (identifier.edited) {
				return;
			}
			identifier.edited = true;
		}
		var fileChanges:Null<Array<FileEdit>> = changes.get(fileName);
		if (fileChanges == null) {
			changes.set(fileName, [change]);
		} else {
			fileChanges.push(change);
		}
	}

	public function execute():RefactorResult {
		if (!context.forRealExecute) {
			return dryRun();
		}
		var hasChanges:Bool = false;
		for (file => edits in changes) {
			edits.sort(sortFileEdits);
			hasChanges = true;
			var doc:IEditableDocument = context.docFactory(file);
			for (edit in edits) {
				doc.addChange(edit);
			}
			doc.endEdits();
		}
		return (hasChanges ? Done : NoChange);
	}

	function dryRun():RefactorResult {
		var hasChanges:Bool = false;

		for (file => edits in changes) {
			edits.sort(sortFileEdits);
			hasChanges = true;
			Sys.println('$file');
			for (edit in edits) {
				switch (edit) {
					case Move(newFileName):
						Sys.println('* rename to "$newFileName"');
					case InsertText(text, pos):
						Sys.println('* insert text "$text" @${pos.start}-${pos.end}');
						Sys.println('+++ $text');
					case ReplaceText(text, pos):
						Sys.println('* replace text with "$text" @${pos.start}-${pos.end}');
						printDiffLines(pos, text);
					case RemoveText(pos):
						Sys.println('* remove text @${pos.start}-${pos.end}');
						printDiffLines(pos, null);
				}
			}
		}
		return (hasChanges ? DryRun : NoChange);
	}

	function sortFileEdits(a:FileEdit, b:FileEdit):Int {
		var offsetA:Int = switch (a) {
			case Move(_): 0;
			case InsertText(_, pos): pos.start;
			case ReplaceText(_, pos): pos.start;
			case RemoveText(pos): pos.start;
		};
		var offsetB:Int = switch (b) {
			case Move(_): 0;
			case InsertText(_, pos): pos.start;
			case ReplaceText(_, pos): pos.start;
			case RemoveText(pos): pos.start;
		};
		if (offsetA < offsetB) {
			return -1;
		}
		if (offsetA > offsetB) {
			return 1;
		}
		return 0;
	}

	function printDiffLines(pos:IdentifierPos, toName:Null<String>) {
		var content:Bytes = File.getBytes(pos.fileName);

		var lineStart:Int = pos.start;
		var lineEnd:Int = pos.end;
		while (lineStart > 0) {
			var char:Int = content.get(lineStart);
			if (char == 0x0A || char == 0x0D) {
				lineStart++;
				break;
			}
			lineStart--;
		}
		while (lineEnd < content.length) {
			var char:Int = content.get(lineEnd);
			if (char == 0x0A || char == 0x0D) {
				break;
			}
			lineEnd++;
		}
		var origLine:String = content.getString(lineStart, lineEnd - lineStart);
		Sys.println('--- $origLine');
		if (toName != null) {
			var newContent:String = content.getString(0, pos.start) + toName + content.getString(pos.end, content.length - pos.end);
			var newLine:String = Bytes.ofString(newContent).getString(lineStart, lineEnd + (toName.length - (pos.end - pos.start) - lineStart));
			Sys.println('+++ $newLine');
		}
	}
}
