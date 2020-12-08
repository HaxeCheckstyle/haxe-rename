package refactor.rename;

import refactor.discover.IdentifierPos;
import refactor.edits.Changelist;
import refactor.discover.Identifier;

class RenameHelper {
	public static function replaceTextWithPrefix(use:Identifier, prefix:String, to:String, changelist:Changelist) {
		if (prefix.length <= 0) {
			changelist.addChange(use.pos.fileName, ReplaceText(to, use.pos));
		} else {
			var pos:IdentifierPos = {
				fileName: use.pos.fileName,
				start: use.pos.start + prefix.length,
				end: use.pos.end
			};
			changelist.addChange(use.pos.fileName, ReplaceText(to, pos));
		}
	}
}
