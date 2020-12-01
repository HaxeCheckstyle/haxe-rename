package refactor.actions;

import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.edits.Changelist;

class RefactorScopedLocal {
	public static function refactorScopedLocal(context:RefactorContext, file:File, identifier:Identifier, scopeEnd:Int) {
		var changelist:Changelist = new Changelist(context);
		var allUses:Array<Identifier> = context.nameMap.getIdentifiers(identifier.name);
		var scopeStart:Int = identifier.pos.start;
		for (use in allUses) {
			if (use.pos.fileName != file.name) {
				continue;
			}
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
			changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, use.pos));
		}
		changelist.execute();
	}
}
