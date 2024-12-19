package methods;

import js.lib.Promise;
import refactor.discover.Identifier;
import refactor.discover.IdentifierPos;
import refactor.discover.Type;
import refactor.edits.Changelist;
import refactor.rename.RenameContext;
import refactor.typing.TypeHintType;
import refactor.typing.TypingHelper;

class SomeHelper {
	public static function arrayAccess(context:RenameContext, changelist:Changelist, use:Identifier, fromName:String, types:Array<Type>,
			posClosing:Int):Promise<Void> {
		var search:SearchTypeOf = {
			name: "search",
			pos: posClosing,
			defineType: null
		};
		return TypingHelper.findTypeOfIdentifier(context, search).then(function(typeHint:TypeHintType) {
			switch (typeHint) {
				case null:
				case TypeHintType.ClasspathType(type, _):
				case LibType("Null", _, [ClasspathType(type, _)]):
					for (t in types) {
						if (t != type) {
							continue;
						}
						var pos:IdentifierPos = {
							fileName: use.pos.fileName,
							start: use.pos.start,
							end: use.pos.end
						};
						pos.end = pos.start + fromName.length;
						changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, pos, NoFormat), use);
					}
				case LibType(_, _):
				case FunctionType(_, retVal):
				case StructType(_):
				case NamedType(_):
				case UnknownType(_):
			}
		});
	}
}
