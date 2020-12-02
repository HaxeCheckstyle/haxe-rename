package refactor.discover;

import haxe.Exception;
import haxe.io.Path;
import byte.ByteData;
import haxeparser.HaxeLexer;
import hxparse.ParserError;
import tokentree.TokenTree;
import tokentree.TokenTreeBuilder;
import refactor.discover.File.Import;

class UsageCollector {
	public function new() {}

	public function parseFile(content:ByteData, context:UsageContext) {
		var root:Null<TokenTree> = null;
		try {
			var lexer = new HaxeLexer(content, context.fileName);
			var t:Token = lexer.token(haxeparser.HaxeLexer.tok);

			var tokens:Array<Token> = [];
			while (t.tok != Eof) {
				tokens.push(t);
				t = lexer.token(haxeparser.HaxeLexer.tok);
			}
			root = TokenTreeBuilder.buildTokenTree(tokens, content, TypeLevel);
			context.fileList.addFile(new File(context.fileName, readPackageName(root, context), readImports(root, context), readTypes(root, context),
				findImportInsertPos(root)));
		} catch (e:ParserError) {
			throw 'failed to parse ${context.fileName} - ParserError: $e (${e.pos})';
		} catch (e:LexerError) {
			throw 'failed to parse ${context.fileName} - LexerError: ${e.msg} (${e.pos})';
		} catch (e:Exception) {
			throw 'failed to parse ${context.fileName} - ${e.details()}';
		}
	}

	public function updateImportHx(context:UsageContext) {
		for (importHxFile in context.fileList.files) {
			var importHxPath:Path = new Path(importHxFile.name);
			if (importHxPath.file != "import") {
				continue;
			}
			var importHxFolder:String = importHxPath.dir;
			for (file in context.fileList.files) {
				if (file.name == importHxFile.name) {
					continue;
				}
				var path:Path = new Path(file.name);
				if (!path.dir.startsWith(importHxFolder)) {
					continue;
				}
				file.importHxFile = importHxFile;
			}
		}
	}

	function findImportInsertPos(root:TokenTree):Int {
		if (!root.hasChildren()) {
			return 0;
		}
		var pos:Int = 0;
		for (child in root.children) {
			switch (child.tok) {
				case Kwd(KwdPackage):
					pos = child.getPos().max + 1;
				case Kwd(KwdImport) | Kwd(KwdUsing):
					return child.pos.min;
				default:
					return child.pos.min;
			}
		}
		return pos;
	}

	function readPackageName(root:TokenTree, context:UsageContext):Identifier {
		var packages:Array<TokenTree> = root.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdPackage):
					FoundSkipSubtree;
				default:
					SkipSubtree;
			}
		});
		if (packages.length != 1) {
			return null;
		}
		var token:TokenTree = packages[0].getFirstChild();
		return makeIdentifier(context, token, PackageName);
	}

	function readImports(root:TokenTree, context:UsageContext):Array<Import> {
		var imports:Array<Import> = [];

		var importTokens:Array<TokenTree> = root.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdImport) | Kwd(KwdUsing):
					FoundSkipSubtree;
				case Sharp(_):
					GoDeeper;
				default:
					SkipSubtree;
			}
		});
		for (importToken in importTokens) {
			imports.push(readImport(importToken, context));
		}
		return imports;
	}

	function readImport(token:TokenTree, context:UsageContext):Import {
		var pack:Array<String> = [];
		var alias:Null<Identifier> = null;
		var type:IdentifierType = switch (token.tok) {
			case Kwd(KwdImport):
				ImportModul;
			case Kwd(KwdUsing):
				UsingModul;
			default:
				null;
		}
		if (type == null) {
			return null;
		}
		var starImport:Bool = false;
		token = token.getFirstChild();
		var pos:IdentifierPos = makePosition(context.fileName, token);

		while (true) {
			switch (token.tok) {
				case Const(CIdent("as")) | Binop(OpIn):
					alias = makeIdentifier(context, token.getFirstChild(), ImportAlias);
					break;
				case Kwd(_) | Const(CIdent(_)):
					pack.push(token.toString());
					pos.end = token.pos.max;
				case Dot:
				case Binop(OpMult):
					starImport = true;
					pos.end = token.pos.max;
				case Semicolon:
					break;
				default:
					return null;
			}
			token = token.getFirstChild();
		}

		return {
			moduleName: new Identifier(type, pack.join("."), pos, context.nameMap),
			alias: alias,
			starImport: starImport
		}
	}

	function readTypes(root:TokenTree, context:UsageContext):Array<Identifier> {
		var typeTokens:Array<TokenTree> = root.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			return switch (token.tok) {
				case Kwd(KwdAbstract) | Kwd(KwdClass) | Kwd(KwdEnum) | Kwd(KwdInterface) | Kwd(KwdTypedef) | Kwd(KwdVar) | Kwd(KwdFinal) | Kwd(KwdFunction):
					FoundSkipSubtree;
				case Sharp(_):
					GoDeeper;
				default:
					SkipSubtree;
			}
		});
		var types:Array<Identifier> = [];
		for (typeToken in typeTokens) {
			types.push(readType(typeToken, context));
		}
		return types;
	}

	function readType(token:TokenTree, context:UsageContext):Identifier {
		var type:IdentifierType = switch (token.tok) {
			case Kwd(KwdAbstract):
				Abstract;
			case Kwd(KwdClass):
				Class;
			case Kwd(KwdEnum):
				Enum;
			case Kwd(KwdInterface):
				Interface;
			case Kwd(KwdTypedef):
				Typedef;
			case Kwd(KwdVar) | Kwd(KwdFinal):
				ModuleLevelStaticVar;
			case Kwd(KwdFunction):
				ModuleLevelStaticMethod;
			default:
				null;
		}
		if (type == null) {
			return null;
		}
		var nameToken:TokenTree = token.getFirstChild();
		var identifier:Identifier = makeIdentifier(context, nameToken, type);

		switch (type) {
			case Abstract:
				addFields(context, identifier, nameToken);
			case Class:
				addFields(context, identifier, nameToken);
			case Enum:
				readEnum(context, identifier, nameToken.getFirstChild());
			case Interface:
				addFields(context, identifier, nameToken);
				if (identifier.uses != null) {
					for (use in identifier.uses) {
						switch (use.type) {
							case Prop | FieldVar | Method:
								use.type = InterfaceField;
							default:
						}
					}
				}
			case Typedef:
				addTypedefFields(context, identifier, nameToken);
			case ModuleLevelStaticVar:
				readVarInit(context, identifier, nameToken);
			case ModuleLevelStaticMethod:
				readMethod(context, identifier, nameToken.getFirstChild());
			default:
		}
		readStrings(context, identifier, nameToken);

		return identifier;
	}

	function readStrings(context:UsageContext, identifier:Identifier, token:TokenTree) {
		token.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			return switch (token.tok) {
				case Const(CString(s, DoubleQuotes)):
					var regEx:EReg = ~/^[a-z][a-zA-Z0-9]+(\.[a-z][a-zA-Z0-9]+)*(|\.[A-Z][a-zA-Z0-9]+)$/;
					if (regEx.match(s)) {
						var pos:IdentifierPos = {
							fileName: context.fileName,
							start: token.pos.min + 1,
							end: token.pos.max - 1
						};
						identifier.addUse(new Identifier(StringConst, s, pos, context.nameMap));
					}
					SkipSubtree;
				case Const(CString(s, SingleQuotes)):
					readStringInterpolation(context, identifier, token, s);
					SkipSubtree;
				default:
					GoDeeper;
			}
		});
	}

	function readStringInterpolation(context:UsageContext, identifier:Identifier, token:TokenTree, text:String) {
		var start:Int = 0;
		var index:Int;
		while ((index = text.indexOf("${", start)) >= 0) {
			if (isDollarEscaped(text, index)) {
				start = index + 1;
				continue;
			}
			start = index + 1;
			var indexEnd:Int = text.indexOf("}", index + 2);
			var fragment:String = text.substring(index + 2, indexEnd);
			if (fragment.indexOf("{") >= 0) {
				continue;
			}

			readInterpolatedFragment(context, identifier, fragment, token.pos.min + 1 + start + 1);
			start = indexEnd;
		}
	}

	function isDollarEscaped(text:String, index:Int):Bool {
		var escaped:Bool = false;
		while (--index >= 0) {
			if (text.fastCodeAt(index) != "$".code) {
				return escaped;
			}
			escaped = !escaped;
		}
		return escaped;
	}

	function readInterpolatedFragment(context:UsageContext, identifier:Identifier, text:String, offset:Int) {
		var root:Null<TokenTree> = null;
		try {
			var content:ByteData = ByteData.ofString(text);
			var lexer = new HaxeLexer(content, context.fileName);
			var t:Token = lexer.token(haxeparser.HaxeLexer.tok);

			var tokens:Array<Token> = [];
			while (t.tok != Eof) {
				t.pos.min += offset;
				t.pos.max += offset;
				tokens.push(t);
				t = lexer.token(haxeparser.HaxeLexer.tok);
			}
			root = TokenTreeBuilder.buildTokenTree(tokens, content, ExpressionLevel);
			readExpression(context, identifier, root);
		} catch (e:ParserError) {
			throw 'failed to parse ${context.fileName} - ParserError: $e (${e.pos})';
		} catch (e:LexerError) {
			throw 'failed to parse ${context.fileName} - LexerError: ${e.msg} (${e.pos})';
		} catch (e:Exception) {
			throw 'failed to parse ${context.fileName} - ${e.details()}';
		}
	}

	function readEnum(context:UsageContext, identifier:Identifier, token:TokenTree) {
		if (!token.hasChildren()) {
			return;
		}
		for (child in token.children) {
			switch (child.tok) {
				case Const(CIdent(_)):
					var enumField:Identifier = makeIdentifier(context, child, EnumField);
					if (enumField == null) {
						trace(child.toString());
						continue;
					}
					identifier.addUse(enumField);
					if (!child.hasChildren()) {
						continue;
					}
					var pOpen:TokenTree = child.getFirstChild();
					if (!pOpen.matches(POpen)) {
						continue;
					}
					readParameter(context, enumField, pOpen, pOpen.pos.max);
				case Sharp("if") | Sharp("elseif"):
					readExpression(context, identifier, child.getFirstChild());
					for (index in 1...child.children.length - 1) {
						switch (child.children[index].tok) {
							case Sharp(_):
							default:
								readEnum(context, identifier, child.children[index]);
						}
					}
				case Sharp("else"):
					readEnum(context, identifier, child);
				default:
					continue;
			}
		}
	}

	function addTypedefFields(context:UsageContext, identifier:Identifier, token:TokenTree) {
		if (!token.hasChildren()) {
			return;
		}
		for (child in token.children) {
			switch (child.tok) {
				case Binop(OpAssign) | BrOpen:
					addTypedefFields(context, identifier, child);
				case Const(CIdent(_)):
					identifier.addUse(makeIdentifier(context, child, TypedefField));
				case Kwd(KwdVar):
					identifier.addUse(makeIdentifier(context, child.getFirstChild(), TypedefField));
				default:
			}
		}
	}

	function addFields(context:UsageContext, identifier:Identifier, token:TokenTree) {
		if (!token.hasChildren()) {
			return;
		}
		for (child in token.children) {
			switch (child.tok) {
				case Kwd(KwdExtends):
					identifier.addUse(makeIdentifier(context, child.getFirstChild(), Extends));
				case Kwd(KwdImplements):
					identifier.addUse(makeIdentifier(context, child.getFirstChild(), Implements));
				case Const(CIdent("from")):
					identifier.addUse(makeIdentifier(context, child.getFirstChild(), AbstractFrom));
				case Const(CIdent("to")):
					identifier.addUse(makeIdentifier(context, child.getFirstChild(), AbstractTo));
				case BrOpen:
					addFields(context, identifier, child);
				case Kwd(KwdFunction):
					var method:Identifier = makeIdentifier(context, child.getFirstChild(), Method);
					readMethod(context, method, child.getFirstChild());
					identifier.addUse(method);
				case Kwd(KwdVar):
					var variable:Identifier = makeIdentifier(context, child.getFirstChild(), FieldVar);
					// TODO check for Property
					readVarInit(context, variable, child.getFirstChild());
					identifier.addUse(variable);
				case Kwd(KwdFinal):
					var variable:Identifier = makeIdentifier(context, child.getFirstChild(), FieldVar);
					readVarInit(context, variable, child.getFirstChild());
					identifier.addUse(variable);
				default:
			}
		};
	}

	function readVarInit(context:UsageContext, identifier:Identifier, token:TokenTree) {
		if (!token.hasChildren()) {
			return;
		}
		for (child in token.children) {
			switch (child.tok) {
				case Binop(OpAssign):
					readExpression(context, identifier, child.getFirstChild());
				default:
			}
		}
	}

	function readMethod(context:UsageContext, identifier:Identifier, token:TokenTree) {
		var ignore:Bool = true;
		var fullPos:Position = token.getPos();
		for (child in token.children) {
			switch (child.tok) {
				case POpen:
					readParameter(context, identifier, child, fullPos.max);
					ignore = false;
				case DblDot:
					if (ignore) {
						continue;
					}
					identifier.addUse(makeIdentifier(context, child.getFirstChild(), TypeHint));
				case BrOpen:
					if (ignore) {
						continue;
					}
					readBlock(context, identifier, child);
				default:
					if (ignore) {
						continue;
					}
					readExpression(context, identifier, child);
			}
		}
	}

	function readBlock(context:UsageContext, identifier:Identifier, token:TokenTree) {
		if (!token.hasChildren()) {
			return;
		}
		var fullPos:Position = token.getPos();
		var scopeEnd:Int = fullPos.max;
		for (child in token.children) {
			switch (child.tok) {
				case Kwd(KwdVar):
					var variable:Identifier = makeIdentifier(context, child.getFirstChild(), ScopedLocal(scopeEnd));
					readVarInit(context, variable, child.getFirstChild());
					identifier.addUse(variable);
				case Kwd(KwdFinal):
					var variable:Identifier = makeIdentifier(context, child.getFirstChild(), ScopedLocal(scopeEnd));
					readVarInit(context, variable, child.getFirstChild());
					identifier.addUse(variable);
				case Kwd(KwdFunction):
					var method:Identifier = makeIdentifier(context, child.getFirstChild(), ScopedLocal(scopeEnd));
					readMethod(context, method, child.getFirstChild());
					identifier.addUse(method);
				// case Kwd(KwdIf):
				// case Kwd(KwdFor):
				// case Kwd(KwdDo):
				// case Kwd(KwdWhile):
				// case Kwd(KwdTry):
				default:
					readExpression(context, identifier, child);
			}
		}
	}

	function readExpression(context:UsageContext, identifier:Identifier, token:TokenTree) {
		token.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			return switch (token.tok) {
				case Const(CIdent(_)):
					if (token.parent.tok.match(Dot)) {
						GoDeeper;
					}
					identifier.addUse(makeIdentifier(context, token, CallOrAccess));
					GoDeeper;
				case Kwd(KwdVar):
					var fullPos:Position = token.parent.getPos();
					var scopeEnd:Int = fullPos.max;
					var variable:Identifier = makeIdentifier(context, token.getFirstChild(), ScopedLocal(scopeEnd));
					readVarInit(context, variable, token.getFirstChild());
					identifier.addUse(variable);
					SkipSubtree;
				case Kwd(KwdFunction):
					var fullPos:Position = token.parent.getPos();
					var scopeEnd:Int = fullPos.max;
					var method:Null<Identifier> = makeIdentifier(context, token.getFirstChild(), ScopedLocal(scopeEnd));
					if (method == null) {
						readMethod(context, identifier, token.getFirstChild());
					} else {
						readMethod(context, method, token.getFirstChild());
						identifier.addUse(method);
					}
					SkipSubtree;
				case Kwd(KwdCase):
					readCase(context, identifier, token);
					SkipSubtree;
				case BrOpen:
					readBlock(context, identifier, token);
					SkipSubtree;
				default:
					GoDeeper;
			}
		});
	}

	function readCase(context:UsageContext, identifier:Identifier, token:TokenTree) {
		if (!token.hasChildren()) {
			return;
		}
		var fullPos:Position = token.getPos();
		var scopeEnd:Int = fullPos.max;
		var caseToken:TokenTree = token.getFirstChild();
		switch (caseToken.tok) {
			case Const(CIdent(_)):
				readCaseConst(context, identifier, caseToken, scopeEnd);
			case Kwd(KwdVar):
				identifier.addUse(makeIdentifier(context, caseToken.getFirstChild(), ScopedLocal(scopeEnd)));
			case BkOpen:
				readCaseArray(context, identifier, caseToken, scopeEnd);
			case BrOpen:
				readCaseStructure(context, identifier, caseToken, scopeEnd);
			default:
		}
		var colon:Null<TokenTree> = caseToken.access().firstOf(DblDot).token;
		if (colon == null) {
			return;
		}
		readExpression(context, identifier, colon.getFirstChild());
	}

	function readCaseConst(context:UsageContext, identifier:Identifier, token:TokenTree, scopeEnd:Int) {
		if (!token.hasChildren()) {
			return;
		}
		identifier.addUse(makeIdentifier(context, token, CallOrAccess));
		var pOpen:Array<TokenTree> = token.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			return switch (token.tok) {
				case POpen:
					FoundSkipSubtree;
				default:
					GoDeeper;
			}
		});
		for (child in pOpen) {
			readParameter(context, identifier, child, scopeEnd);
		}
	}

	function readCaseArray(context:UsageContext, identifier:Identifier, token:TokenTree, scopeEnd:Int) {
		if (!token.hasChildren()) {
			return;
		}
		for (child in token.children) {
			identifier.addUse(makeIdentifier(context, child, ScopedLocal(scopeEnd)));
		}
	}

	function readCaseStructure(context:UsageContext, identifier:Identifier, token:TokenTree, scopeEnd:Int) {
		if (!token.hasChildren()) {
			return;
		}
		for (child in token.children) {
			var field:Identifier = makeIdentifier(context, child, StructureField);
			if (field.uses != null) {
				for (use in field.uses) {
					use.type = ScopedLocal(scopeEnd);
				}
			}
			identifier.addUse(field);
		}
	}

	function readParameter(context:UsageContext, identifier:Identifier, token:TokenTree, scopeEnd:Int) {
		for (child in token.children) {
			switch (child.tok) {
				case Const(CIdent(_)):
					identifier.addUse(makeIdentifier(context, child, ScopedLocal(scopeEnd)));
				default:
			}
		}
	}

	function makePosition(fileName:String, token:TokenTree):IdentifierPos {
		return {
			fileName: fileName,
			start: token.pos.min,
			end: token.pos.max
		}
	}

	function makeIdentifier(context:UsageContext, nameToken:TokenTree, type:IdentifierType):Null<Identifier> {
		if (nameToken == null) {
			return null;
		}
		var pos:IdentifierPos = makePosition(context.fileName, nameToken);
		var pack:Array<String> = [];
		var typeParamLt:Null<TokenTree> = null;
		while (nameToken != null) {
			switch (nameToken.tok) {
				case Kwd(_) | Const(CIdent(_)):
					pack.push(nameToken.toString());
					pos.end = nameToken.pos.max;
				default:
					break;
			}
			nameToken = nameToken.getFirstChild();
			if (nameToken == null) {
				break;
			}
			switch (nameToken.tok) {
				case Dot:
					pos.end = nameToken.pos.max;
				case Binop(OpLt):
					if (TokenTreeCheckUtils.isTypeParameter(nameToken)) {
						typeParamLt = nameToken;
					}
					break;
				case DblDot:
					typeParamLt = nameToken;
					break;
				default:
					break;
			}
			nameToken = nameToken.getFirstChild();
		}
		if (pack.length <= 0) {
			return null;
		}
		var identifier:Identifier = new Identifier(type, pack.join("."), pos, context.nameMap);

		if (typeParamLt != null) {
			addTypeParameter(context, identifier, typeParamLt);
		}
		return identifier;
	}

	function addTypeParameter(context:UsageContext, identifier:Identifier, token:TokenTree) {
		if (!token.hasChildren()) {
			return;
		}
		for (child in token.children) {
			switch (child.tok) {
				case Const(CIdent(_)):
					identifier.addUse(makeIdentifier(context, child, TypedParameter));
				case Binop(OpGt):
					break;
				default:
			}
		}
	}
}
