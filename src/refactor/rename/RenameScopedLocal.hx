package refactor.rename;

import refactor.RefactorResult;
import refactor.RefactorContext;
import refactor.discover.File;
import refactor.discover.Identifier;
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
				case ScopedLocal(scopeEnd):
					if (use.pos.start != identifier.pos.start) {
						// new parameter with identical name, so we skip its scope
						scopeStart = scopeEnd;
						continue;
					}
				default:
			}
			if (use.name == identifier.name) {
				changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, use.pos));
			} else {
				var newName:String = context.what.toName + use.name.substr(identifier.name.length);
				changelist.addChange(use.pos.fileName, ReplaceText(newName, use.pos));
			}
		}
		return changelist.execute();
	}
}
