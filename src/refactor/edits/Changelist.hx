package refactor.edits;

import sys.io.File;
import refactor.actions.RefactorContext;
import refactor.actions.RefactorResult;
import refactor.discover.IdentifierPos;

class Changelist {
	var changes:Map<String, Array<FileEdit>>;
	var context:RefactorContext;

	public function new(context:RefactorContext) {
		changes = new Map<String, Array<FileEdit>>();
		this.context = context;
	}

	public function addChange(fileName:String, change:FileEdit) {
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
						Sys.println('* insert text to "$text" @${pos.start}-${pos.end}');
						Sys.println('+++ $text');
					case ReplaceText(text, pos):
						Sys.println('* replace text to "$text" @${pos.start}-${pos.end}');
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
		var content:String = File.getContent(pos.fileName);

		var lineStart:Int = pos.start;
		var lineEnd:Int = pos.end;
		while (lineStart > 0) {
			var char:String = content.charAt(lineStart);
			if (char == "\r" || char == "\n") {
				lineStart++;
				break;
			}
			lineStart--;
		}
		while (lineEnd < content.length) {
			var char:String = content.charAt(lineEnd);
			if (char == "\r" || char == "\n") {
				break;
			}
			lineEnd++;
		}
		var origLine:String = content.substring(lineStart, lineEnd);
		Sys.println('--- $origLine');
		if (toName != null) {
			var newContent:String = content.substring(0, pos.start) + toName + content.substring(pos.end, content.length);
			var newLine:String = newContent.substring(lineStart, lineEnd + (toName.length - (pos.end - pos.start)));
			Sys.println('+++ $newLine');
		}
	}
}
