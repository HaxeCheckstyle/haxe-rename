package refactor.refactor;

import haxe.io.Path;
import sys.FileSystem;
import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.discover.Type;
import refactor.edits.Changelist;
import refactor.refactor.RefactorHelper.TokensAtPos;

class ExtractInterface {
	public static function canRefactor(context:CanRefactorContext):CanRefactorResult {
		final extractData = makeExtractInterfaceData(context);
		if (extractData == null) {
			return Unsupported;
		}
		return Supported('Extract Interface from "${extractData.srcType.name.name}" to ${Path.withoutDirectory(extractData.newFileName)}');
	}

	public static function doRefactor(context:RefactorContext):Promise<RefactorResult> {
		final extractData = makeExtractInterfaceData(context);
		if (extractData == null) {
			return Promise.reject("failed to collect extract interface data");
		}

		final changelist:Changelist = new Changelist(context);

		// create new file
		changelist.addChange(extractData.newFileName, CreateFile(extractData.newFileName), null);

		// collect all public fields
		var fields:Array<FieldData> = findPublicFields(extractData, context);

		// copy header + imports
		final fileHeader:String = makeHeader(extractData, context, findImportCandidates(extractData, context, fields));
		// create interface + fields
		final fieldDefinition:String = makeFields(extractData, context, fields);
		final interfaceText:String = 'interface ${extractData.newTypeName} {\n' + fieldDefinition + "}";

		changelist.addChange(extractData.newFileName, InsertText(fileHeader + interfaceText, {fileName: extractData.newFileName, start: 0, end: 0}, true),
			null);

		final implementsText:String = ' implements ${extractData.newTypeName}';
		final pos:Position = findImplementsPos(extractData);
		changelist.addChange(extractData.srcFile.name, InsertText(implementsText, {fileName: extractData.srcFile.name, start: pos.max, end: pos.max}, false),
			null);

		return Promise.resolve(changelist.execute());
	}

	static function makeExtractInterfaceData(context:CanRefactorContext):Null<ExtractInterfaceData> {
		final fileContent = context.fileReader(context.what.fileName);
		var content:String;
		var root:TokenTree;
		switch (fileContent) {
			case Text(_):
				return null;
			case Token(tokens, text):
				content = text;
				root = tokens;
		}
		if (root == null) {
			return null;
		}
		if (content == null) {
			return null;
		}

		final tokens:TokensAtPos = RefactorHelper.findTokensAtPos(root, context.what.posStart);
		if (tokens.before == null || tokens.after == null || tokens.before.index != tokens.after.index) {
			return null;
		}
		final firstImport:Null<TokenTree> = RefactorHelper.findFirstImport(root);

		final classToken:Null<TokenTree> = tokens.before.access().parent().matches(Kwd(KwdClass)).token;
		if (classToken == null) {
			return null;
		}

		final path = new Path(context.what.fileName);

		final nameToken:Null<TokenTree> = classToken.getFirstChild();
		if (nameToken == null) {
			return null;
		}
		final srcName:String = nameToken.toString();
		final newName:String = "I" + srcName;

		final file:Null<File> = context.fileList.getFile(context.what.fileName);
		if (file == null) {
			return null;
		}
		final type:Null<Type> = file.getType(srcName);
		if (type == null) {
			return null;
		}

		final newFileName:String = Path.join([path.dir, newName + ".hx"]);
		if (FileSystem.exists(newFileName)) {
			return null;
		}

		return {
			content: content,
			root: root,
			firstImport: firstImport,
			classToken: classToken,
			newTypeName: newName,
			newFileName: newFileName,
			srcFile: file,
			srcType: type,
		};
	}

	static function findImplementsPos(extractData:ExtractInterfaceData):Position {
		final className:Null<TokenTree> = extractData.classToken.access().firstChild().token;
		final pos:Position = {file: className.pos.file, min: className.pos.max, max: className.pos.max};
		if (!className.hasChildren()) {
			return pos;
		}
		for (child in className.children) {
			switch (child.tok) {
				case BrOpen:
					break;
				default:
					expandPos(pos, child.getPos());
			}
		}
		pos.min = pos.max;
		return pos;
	}

	static function findPublicFields(extractData:ExtractInterfaceData, context:RefactorContext):Array<FieldData> {
		final brOpen:Null<TokenTree> = extractData.classToken.access().firstChild().firstOf(BrOpen).token;
		final fields:Array<FieldData> = [];

		findAllFields(brOpen, fields);
		return fields;
	}

	static function expandPos(pos:Position, newPos:Position) {
		if (newPos.min < pos.min) {
			pos.min = newPos.min;
		}
		if (newPos.max > pos.max) {
			pos.max = newPos.max;
		}
	}

	static function addField(parent:TokenTree, fields:Array<FieldData>) {
		if (!parent.hasChildren()) {
			return;
		}
		var nameToken:TokenTree = parent.getFirstChild();
		if (nameToken == null || !nameToken.hasChildren()) {
			return;
		}
		if (nameToken.matches(Kwd(KwdNew))) {
			return;
		}

		var pos:Position = {file: parent.pos.file, min: parent.pos.min, max: parent.pos.max};
		expandPos(pos, nameToken.pos);
		var isPublic:Bool = false;
		var hasHint:Bool = false;

		if (parent.previousSibling != null) {
			switch (parent.previousSibling.tok) {
				case Comment(s):
					if (s.startsWith("*")) {
						expandPos(pos, parent.previousSibling.pos);
					}
				default:
			}
		}

		for (child in nameToken.children) {
			switch (child.tok) {
				case Kwd(KwdPrivate) | Kwd(KwdStatic):
					return;
				case Kwd(KwdPublic):
					isPublic = true;
				case Kwd(KwdDynamic) | Kwd(KwdOverride) | Kwd(KwdExtern) | Kwd(KwdInline):
					expandPos(pos, child.pos);
				case POpen:
					expandPos(pos, child.getPos());
				case DblDot:
					hasHint = true;
					expandPos(pos, child.getPos());
				case BrOpen | Binop(OpAssign):
					break;
				default:
					return;
			}
		}
		if (!isPublic) {
			return;
		}
		var data:FieldData = {
			pos: pos,
			hasHint: hasHint,
			isSharp: false
		}
		fields.push(data);
	}

	static function findAllFields(parent:TokenTree, fields:Array<FieldData>) {
		if (parent == null) {
			return;
		}
		if (!parent.hasChildren()) {
			return;
		}
		for (child in parent.children) {
			switch (child.tok) {
				case Kwd(KwdVar) | Kwd(KwdFinal) | Kwd(KwdFunction):
					addField(child, fields);
				case Sharp("if") | Sharp("elseif"):
					if (!child.hasChildren()) {
						continue;
					}
					var pos:Position = {file: child.pos.file, min: child.pos.min, max: child.pos.max};
					expandPos(pos, child.getFirstChild().getPos());
					fields.push({
						pos: pos,
						hasHint: true,
						isSharp: true
					});
					findAllFields(child, fields);
				case Sharp("else"):
					var pos:Position = {file: child.pos.file, min: child.pos.min, max: child.pos.max};
					fields.push({
						pos: pos,
						hasHint: true,
						isSharp: true
					});
					findAllFields(child, fields);
				case Sharp("end"):
					var pos:Position = {file: child.pos.file, min: child.pos.min, max: child.pos.max};
					fields.push({
						pos: pos,
						hasHint: true,
						isSharp: true
					});
				default:
			}
		}
	}

	static function makeHeader(extractData:ExtractInterfaceData, context:RefactorContext, allUses:Array<String>):String {
		final imports = RefactorHelper.makeNewFileImports(context, extractData.srcFile, allUses);

		if (extractData.firstImport == null) {
			final lastHeader = RefactorHelper.getLastHeaderToken(extractData.root);
			if (extractData.firstImport == null) {
				return "";
			}
			final pos = lastHeader.getPos();
			return RefactorHelper.extractText(context.converter, extractData.content, 0, pos.min - 1) + "\n";
		}

		final pos = extractData.firstImport.getPos();
		return RefactorHelper.extractText(context.converter, extractData.content, 0, pos.min - 1) + "\n" + imports;
	}

	static function findImportCandidates(extractData:ExtractInterfaceData, context:RefactorContext, fields:Array<FieldData>):Array<String> {
		var names:Array<String> = [];
		for (field in fields) {
			function rangeMatcher(identifier:Identifier):Bool {
				if (identifier.pos.start > field.pos.max) {
					return false;
				}
				if (identifier.pos.end < field.pos.min) {
					return false;
				}
				return true;
			}
			var allUses:Array<Identifier> = extractData.srcType.findAllIdentifiers(rangeMatcher);
			names = names.concat(allUses.map(use -> {
				final parts = use.name.split(".");
				return parts.shift();
			}));
		}
		return names;
	}

	static function makeFields(extractData:ExtractInterfaceData, context:RefactorContext, fields:Array<FieldData>):String {
		final buf:StringBuf = new StringBuf();
		final defaultHint:String = ":Void";

		for (field in fields) {
			buf.add("\t");
			var text:String = RefactorHelper.extractText(context.converter, extractData.content, field.pos.min, field.pos.max);
			var index = text.lastIndexOf("function ");
			if (index < 0) {
				index = text.lastIndexOf("var ");
			}
			if (index < 0) {
				index = text.lastIndexOf("final ");
			}
			if (index > 0) {
				var commentIndex:Int = text.lastIndexOf("*/", index);
				var comment = "";
				if (commentIndex < 0) {
					commentIndex = 0;
				}
				if (commentIndex > 0) {
					comment = text.substr(0, commentIndex);
				}
				var modifier = text.substring(commentIndex, index);
				final funcSignature = text.substr(index);
				modifier = modifier.replace("public", "");
				modifier = modifier.replace("inline", "");
				modifier = modifier.replace("override", "");
				modifier = modifier.replace("abstract", "");
				text = comment + modifier + funcSignature;
				if (!funcSignature.endsWith(";")) {
					text += ";";
				}
			}
			buf.add(text);
			if (field.isSharp) {
				buf.add("\n");
				continue;
			}
			if (!field.hasHint) {
				buf.add(defaultHint);
			}
			if (!text.endsWith(";")) {
				buf.add(";");
			}
			buf.add("\n");
		}

		return buf.toString();
	}
}

typedef ExtractInterfaceData = {
	var content:String;
	var root:TokenTree;
	var firstImport:Null<TokenTree>;
	var classToken:TokenTree;
	var newTypeName:String;
	var newFileName:String;
	var srcFile:File;
	var srcType:Type;
}

typedef FieldData = {
	var pos:Position;
	var hasHint:Bool;
	var isSharp:Bool;
}
