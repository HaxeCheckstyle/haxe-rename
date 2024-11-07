package refactor.refactor;

import refactor.discover.File;
import refactor.refactor.CanRefactorContext.ByteToCharConverterFunc;

class RefactorHelper {
	public static function findTokenAtPos(token:TokenTree, searchPos:Int):Null<TokenTree> {
		if (!token.hasChildren()) {
			return null;
		}
		if (token.pos.min <= searchPos && token.pos.max > searchPos) {
			return token;
		}
		for (child in token.children) {
			var range = child.getPos();
			if (range.min <= searchPos && range.max > searchPos) {
				return findTokenAtPos(child, searchPos);
			}
		}
		return null;
	}

	public static function extractText(converter:ByteToCharConverterFunc, text:String, start:Int, end:Int):String {
		return text.substring(converter(text, start), converter(text, end));
	}

	public static function findFirstImport(tree:TokenTree):Null<TokenTree> {
		if (!tree.hasChildren()) {
			return null;
		}
		for (child in tree.children) {
			switch (child.tok) {
				case Kwd(KwdImport) | Kwd(KwdUsing):
					return child;
				case Kwd(KwdAbstract) | Kwd(KwdClass) | Kwd(KwdEnum) | Kwd(KwdInterface) | Kwd(KwdTypedef) | Kwd(KwdVar) | Kwd(KwdFinal) | Kwd(KwdFunction):
					return child;
				case Sharp(_):
					return null;
				default:
			}
		}
		return null;
	}

	public static function makeNewFileImports(context:CanRefactorContext, file:File, potentialNames:Array<String>) {
		final needImports:Array<Import> = [];
		final importedTypes:Array<String> = [];
		final imports:Array<Import> = [];
		for (imp in file.importList) {
			if (imp.moduleName.type == UsingModul) {
				needImports.push(imp);
			}
			if (imp.starImport) {
				needImports.push(imp);
				continue;
			}
			if (imp.alias != null) {
				importedTypes.push(imp.alias.name);
				imports.push(imp);
				continue;
			}
			final parts = imp.moduleName.name.split(".");
			importedTypes.push(parts.pop());
			imports.push(imp);
		}

		for (name in potentialNames) {
			final index = importedTypes.indexOf(name);
			if (index >= 0) {
				final imp = imports[index];
				if (needImports.contains(imp)) {
					continue;
				}
				needImports.push(imp);
			}
		}
		final buf:StringBuf = new StringBuf();
		for (imp in needImports) {
			switch (imp.moduleName.type) {
				case ImportModul:
					buf.add("import ");
					buf.add(imp.moduleName.name);
					if (imp.starImport) {
						buf.add(".*");
					}
					buf.add(";\n");
				case ImportAlias:
					buf.add("import ");
					buf.add(imp.moduleName.name);
					buf.add(" as ");
					buf.add(imp.alias.name);
					buf.add(";\n");
				case UsingModul:
					buf.add("using ");
					buf.add(imp.moduleName.name);
					buf.add(";\n");
				default:
			}
		}

		final imports = buf.toString();
		if (imports.length <= 0) {
			return "";
		}

		return imports + "\n";
	}

	public static function getLastHeaderToken(tree:TokenTree):Null<TokenTree> {
		final headers:Array<TokenTree> = tree.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			switch token.tok {
				case Kwd(KwdAbstract) | Kwd(KwdClass) | Kwd(KwdEnum) | Kwd(KwdInterface) | Kwd(KwdTypedef) | Kwd(KwdVar) | Kwd(KwdFinal) | Kwd(KwdFunction):
					return FoundSkipSubtree;
				case Kwd(KwdPackage), Kwd(KwdImport), Kwd(KwdUsing):
					return SkipSubtree;
				case Comment(_) | CommentLine(_):
					return SkipSubtree;
				default:
			}
			return GoDeeper;
		});
		return headers.shift();
	}
}
