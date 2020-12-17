package refactor.rename;

import refactor.RefactorContext;
import refactor.RefactorResult;
import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.discover.IdentifierPos;
import refactor.edits.Changelist;

class RenameScopedLocal {
	public static function refactorScopedLocal(context:RefactorContext, file:File, identifier:Identifier, scopeEnd:Int):RefactorResult {
		var changelist:Changelist = new Changelist(context);
		var identifierDot:String = identifier.name + ".";
		var scopeStart:Int = identifier.pos.start;
		var allUses:Array<Identifier> = identifier.defineType.findAllIdentifiers(function(ident:Identifier) {
			if (ident.pos.start < scopeStart) {
				return false;
			}
			if (ident.name == identifier.name) {
				return true;
			}
			if (ident.name.startsWith(identifierDot)) {
				return true;
			}
			return false;
		});

		for (use in allUses) {
			if (use.pos.start < scopeStart) {
				continue;
			}
			if (use.pos.start > scopeEnd) {
				continue;
			}
			switch (use.type) {
				case ScopedLocal(scopeEnd, _):
					if (use.pos.start != identifier.pos.start) {
						// new parameter with identical name, so we skip its scope
						scopeStart = scopeEnd;
						continue;
					}
				default:
			}
			if (use.name == identifier.name) {
				// exact match
				changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, use.pos), use);
			} else {
				// starts with identifier + "." -> replace only identifier part
				var pos:IdentifierPos = {
					fileName: use.pos.fileName,
					start: use.pos.start,
					end: use.pos.start + identifier.pos.end - identifier.pos.start
				};
				changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, pos), use);
			}
		}
		return changelist.execute();
	}
}
