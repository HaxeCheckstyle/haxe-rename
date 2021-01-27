package refactor.discover;

import haxe.Exception;
import haxe.io.Path;
import byte.ByteData;
import haxeparser.HaxeLexer;
import hxparse.ParserError;
import tokentree.TokenTree;
import tokentree.TokenTreeBuilder;
import refactor.discover.File.Import;
import refactor.discover.IdentifierType.TypedefFieldType;

class UsageCollector {
	public function new() {}

	public function parseFile(content:ByteData, context:UsageContext) {
		if (context.cache != null) {
			var file:Null<File> = context.cache.getFile(context.fileName, context.nameMap);
			if (file != null) {
				context.fileList.addFile(file);
				return;
			}
		}
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
			var file:File = new File(context.fileName);
			context.file = file;
			context.type = null;
			var packageName:Null<Identifier> = readPackageName(root, context);
			var imports:Array<Import> = readImports(root, context);
			file.init(packageName, imports, readTypes(root, context), findImportInsertPos(root));
			context.fileList.addFile(file);
			if (context.cache != null) {
				context.cache.storeFile(file);
			}
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
		return makeIdentifier(context, token, PackageName, null);
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
					alias = makeIdentifier(context, token.getFirstChild(), ImportAlias, null);
					break;
				case Kwd(_) | Const(CIdent(_)):
					pack.push(token.toString());
					pos.end = token.pos.max;
				case Dot:
				case Binop(OpMult):
					starImport = true;
				case Semicolon:
					break;
				default:
					return null;
			}
			token = token.getFirstChild();
		}

		var importIdentifier:Identifier = new Identifier(type, pack.join("."), pos, context.nameMap, context.file, null);
		if (alias != null) {
			importIdentifier.addUse(alias.parent);
		}
		return {
			moduleName: importIdentifier,
			alias: alias,
			starImport: starImport
		}
	}

	function readTypes(root:TokenTree, context:UsageContext):Array<Type> {
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
		var types:Array<Type> = [];
		for (typeToken in typeTokens) {
			types.push(readType(typeToken, context));
		}
		return types;
	}

	function readType(token:TokenTree, context:UsageContext):Type {
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
		var newType:Type = new Type(context.file);
		context.type = newType;
		var identifier:Identifier = makeIdentifier(context, nameToken, type, null);
		newType.name = identifier;
		context.typeList.addType(newType);

		switch (type) {
			case Abstract:
				addAbstractFields(context, identifier, nameToken);
			case Class:
				addFields(context, identifier, nameToken);
			case Enum:
				readEnum(context, identifier, nameToken.getFirstChild());
			case Interface:
				addFields(context, identifier, nameToken);
				if (identifier.uses != null) {
					for (use in identifier.uses) {
						switch (use.type) {
							case Property:
								use.type = InterfaceProperty;
							case FieldVar(_):
								use.type = InterfaceVar;
							case Method(_):
								use.type = InterfaceMethod;
							default:
						}
					}
				}
			case Typedef:
				readTypedef(context, identifier, nameToken);
			case ModuleLevelStaticVar:
				readVarInit(context, identifier, nameToken);
			case ModuleLevelStaticMethod:
				readMethod(context, identifier, nameToken);
			default:
		}
		readStrings(context, identifier, nameToken);

		return newType;
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
						identifier.addUse(new Identifier(StringConst, s, pos, context.nameMap, context.file, context.type));
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
		start = 0;
		var nameRegEx:EReg = ~/^[a-z][a-zA-Z0-9]*/;
		while ((index = text.indexOf("$", start)) >= 0) {
			if (index + 1 >= text.length) {
				break;
			}
			start = index + 1;
			if (nameRegEx.match(text.substr(start))) {
				var matchedText:String = nameRegEx.matched(0);
				var pos:IdentifierPos = {
					fileName: token.pos.file,
					start: token.pos.min + start + 1,
					end: token.pos.min + start + matchedText.length + 1
				};
				identifier.addUse(new Identifier(Access, matchedText, pos, context.nameMap, context.file, context.type));
			}
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
					var enumField:Identifier = makeIdentifier(context, child, EnumField([]), identifier);
					if (enumField == null) {
						continue;
					}
					if (!child.hasChildren()) {
						continue;
					}
					var pOpen:TokenTree = child.getFirstChild();
					if (!pOpen.matches(POpen)) {
						continue;
					}
					var params:Array<Identifier> = readParameter(context, enumField, pOpen, pOpen.pos.max);
					enumField.type = EnumField(params);
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

	function readTypedef(context:UsageContext, identifier:Identifier, token:TokenTree) {
		if (!token.hasChildren()) {
			return;
		}
		var assignToken:Null<TokenTree> = token.getFirstChild();
		if (assignToken == null || !assignToken.tok.match(Binop(OpAssign)) || !assignToken.hasChildren()) {
			return;
		}
		for (child in assignToken.children) {
			switch (child.tok) {
				case BrOpen:
					readAnonStructure(context, identifier, child);
				case Const(CIdent(_)):
					makeIdentifier(context, child, TypedefBase, identifier);
				default:
			}
		}
	}

	function addFields(context:UsageContext, identifier:Identifier, token:Null<TokenTree>) {
		if (token == null || !token.hasChildren()) {
			return;
		}
		for (child in token.children) {
			switch (child.tok) {
				case Kwd(KwdExtends):
					makeIdentifier(context, child.getFirstChild(), Extends, identifier);
				case Kwd(KwdImplements):
					makeIdentifier(context, child.getFirstChild(), Implements, identifier);
				case BrOpen:
					addFields(context, identifier, child);
				case Kwd(KwdFunction):
					var nameToken:TokenTree = child.getFirstChild();
					var method:Identifier = makeIdentifier(context, nameToken, Method(nameToken.access().firstOf(Kwd(KwdStatic)).exists()), identifier);
					readMethod(context, method, nameToken);
				case Kwd(KwdVar) | Kwd(KwdFinal):
					var nameToken:TokenTree = child.getFirstChild();
					var variable:Identifier = makeIdentifier(context, nameToken, FieldVar(nameToken.access().firstOf(Kwd(KwdStatic)).exists()), identifier);
					if (nameToken.access().firstChild().matches(POpen).exists()) {
						variable.type = Property;
					}
					readVarInit(context, variable, child.getFirstChild());
				default:
			}
		};
	}

	function addAbstractFields(context:UsageContext, identifier:Identifier, token:Null<TokenTree>) {
		if (token == null || !token.hasChildren()) {
			return;
		}
		var staticVars:Bool = false;
		var block:Null<TokenTree> = null;
		for (child in token.children) {
			switch (child.tok) {
				case Kwd(KwdEnum):
					staticVars = true;
				case Const(CIdent("from")):
					makeIdentifier(context, child.getFirstChild(), AbstractFrom, identifier);
				case Const(CIdent("to")):
					makeIdentifier(context, child.getFirstChild(), AbstractTo, identifier);
				case POpen:
					readTypeHint(context, identifier, child, AbstractOver);
				case BrOpen:
					block = child;
					break;
				default:
			}
		}
		if (block == null) {
			return;
		}
		for (child in block.children) {
			switch (child.tok) {
				case Kwd(KwdFunction):
					var nameToken:TokenTree = child.getFirstChild();
					var method:Identifier = makeIdentifier(context, nameToken, Method(nameToken.access().firstOf(Kwd(KwdStatic)).exists()), identifier);
					readMethod(context, method, nameToken);
				case Kwd(KwdVar) | Kwd(KwdFinal):
					var nameToken:TokenTree = child.getFirstChild();
					var variable:Identifier = makeIdentifier(context, nameToken, FieldVar(staticVars), identifier);
					if (nameToken.access().firstChild().matches(POpen).exists()) {
						variable.type = Property;
					}
					readVarInit(context, variable, child.getFirstChild());
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
					makeIdentifier(context, child.getFirstChild(), TypeHint, identifier);
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

	function readObjectLiteral(context:UsageContext, identifier:Identifier, token:TokenTree) {
		if (!token.hasChildren()) {
			return;
		}
		var names:Array<String> = [];
		for (child in token.children) {
			switch (child.tok) {
				case Const(CIdent(s)):
					names.push(s);
					var field:Identifier = makeIdentifier(context, child, StructureField(names), identifier);
					readExpression(context, field, child.getFirstChild());
				case BrClose:
					break;
				default:
					break;
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
					var variable:Identifier = makeIdentifier(context, child.getFirstChild(), ScopedLocal(scopeEnd, Var), identifier);
					readVarInit(context, variable, child.getFirstChild());
				case Kwd(KwdFinal):
					var variable:Identifier = makeIdentifier(context, child.getFirstChild(), ScopedLocal(scopeEnd, Var), identifier);
					readVarInit(context, variable, child.getFirstChild());
				case Kwd(KwdFunction):
					var method:Identifier = makeIdentifier(context, child.getFirstChild(), ScopedLocal(scopeEnd, Var), identifier);
					readMethod(context, method, child.getFirstChild());
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

	function readExpression(context:UsageContext, identifier:Identifier, token:Null<TokenTree>) {
		if (token == null) {
			return;
		}

		token.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			return switch (token.tok) {
				case Const(CIdent(_)):
					var parent:TokenTree = token.parent;
					if (parent.tok.match(Dot)) {
						var prev:Null<TokenTree> = parent.previousSibling;
						if (prev == null) {
							return GoDeeper;
						}
						switch (prev.tok) {
							case BkOpen | POpen:
								// method chaining
								var newIdent:Identifier = makeIdentifier(context, token, Access, identifier);
								readBlock(context, newIdent, token);
								return SkipSubtree;
							default:
								return GoDeeper;
						}
					}
					var newIdent:Identifier = makeIdentifier(context, token, Access, identifier);
					readBlock(context, newIdent, token);
					SkipSubtree;
				case Kwd(KwdVar):
					var fullPos:Position = token.parent.getPos();
					var scopeEnd:Int = fullPos.max;
					var variable:Identifier = makeIdentifier(context, token.getFirstChild(), ScopedLocal(scopeEnd, Var), identifier);
					readVarInit(context, variable, token.getFirstChild());
					SkipSubtree;
				case Kwd(KwdFunction):
					var fullPos:Position = token.parent.getPos();
					var scopeEnd:Int = fullPos.max;
					var method:Null<Identifier> = makeIdentifier(context, token.getFirstChild(), ScopedLocal(scopeEnd, Var), identifier);
					if (method == null) {
						readMethod(context, identifier, token);
					} else {
						readMethod(context, method, token.getFirstChild());
					}
					SkipSubtree;
				case Kwd(KwdThis):
					makeIdentifier(context, token, Access, identifier);
					GoDeeper;
				case BrOpen:
					switch (TokenTreeCheckUtils.getBrOpenType(token)) {
						case Block:
							readBlock(context, identifier, token);
						case TypedefDecl:
							readBlock(context, identifier, token);
						case ObjectDecl:
							readObjectLiteral(context, identifier, token);
						case AnonType:
							readBlock(context, identifier, token);
						case Unknown:
							readBlock(context, identifier, token);
					}
					SkipSubtree;
				case Kwd(KwdSwitch):
					readSwitch(context, identifier, token);
					SkipSubtree;
				case Kwd(KwdFor):
					readFor(context, identifier, token);
					SkipSubtree;
				default:
					GoDeeper;
			}
		});
	}

	function readSwitch(context:UsageContext, identifier:Identifier, token:TokenTree) {
		if (!token.hasChildren()) {
			return;
		}
		var index:Int = 0;
		if (identifier != null && identifier.uses != null) {
			index = identifier.uses.length;
		}
		readExpression(context, identifier, token.getFirstChild());
		var switchIdent:Null<Identifier> = identifier;
		if (identifier != null && identifier.uses != null && (identifier.uses.length > index)) {
			switchIdent = identifier.uses[index];
		}
		var brOpen:Null<TokenTree> = token.access().firstOf(BrOpen).token;
		if ((brOpen == null) || (!brOpen.hasChildren())) {
			return;
		}
		for (child in brOpen.children) {
			switch (child.tok) {
				case Kwd(KwdCase):
					readCase(context, switchIdent, child);
				case Kwd(KwdDefault):
					if (child.hasChildren()) {
						readBlock(context, switchIdent, child.getFirstChild());
					}
				default:
					break;
			}
		}
	}

	function readFor(context:UsageContext, identifier:Identifier, token:TokenTree) {
		if (!token.hasChildren()) {
			return;
		}
		var skip:Bool = true;
		for (child in token.children) {
			switch (child.tok) {
				case POpen:
					var fullPos:Position = token.getPos();
					var scopeEnd:Int = fullPos.max;
					readForIteration(context, identifier, child.getFirstChild(), scopeEnd);
					skip = false;
				default:
					if (skip) {
						continue;
					}
					readExpression(context, identifier, child);
			}
		}
	}

	function readForIteration(context:UsageContext, identifier:Identifier, token:TokenTree, scopeEnd:Int) {
		var loopIdentifiers:Array<Identifier> = [];

		var ident:Identifier = makeIdentifier(context, token, ScopedLocal(scopeEnd, ForLoop(loopIdentifiers)), identifier);
		loopIdentifiers.push(ident);
		if (!token.hasChildren()) {
			return;
		}
		for (child in token.children) {
			switch (child.tok) {
				case Binop(OpArrow):
					ident = makeIdentifier(context, child.getFirstChild(), ScopedLocal(scopeEnd, ForLoop(loopIdentifiers)), identifier);
					loopIdentifiers.push(ident);
				default:
					readExpression(context, ident, child);
					if (ident.uses != null) {
						for (use in ident.uses) {
							loopIdentifiers.push(use);
						}
					}
			}
		}
	}

	function readCase(context:UsageContext, identifier:Identifier, token:TokenTree) {
		if (!token.hasChildren()) {
			return;
		}
		var fullPos:Position = token.getPos();
		var scopeEnd:Int = fullPos.max;

		for (child in token.children) {
			switch (child.tok) {
				case Const(CIdent(_)):
					readCaseConst(context, identifier, child, scopeEnd);
				case Kwd(KwdVar):
					makeIdentifier(context, child.getFirstChild(), ScopedLocal(scopeEnd, CaseCapture), identifier);
				case BkOpen:
					readCaseArray(context, identifier, child, scopeEnd);
				case BrOpen:
					readCaseStructure(context, identifier, child, scopeEnd);
				case DblDot:
					readBlock(context, identifier, child);
					break;
				default:
			}
		}
	}

	function readCaseConst(context:UsageContext, identifier:Identifier, token:TokenTree, scopeEnd:Int) {
		if (!token.hasChildren()) {
			return;
		}
		var caseIdent:Identifier = makeIdentifier(context, token, CaseLabel(identifier), identifier);
		var pOpen:Array<TokenTree> = token.filterCallback(function(token:TokenTree, index:Int):FilterResult {
			return switch (token.tok) {
				case POpen:
					FoundSkipSubtree;
				default:
					GoDeeper;
			}
		});
		for (child in pOpen) {
			readParameter(context, caseIdent, child, scopeEnd);
		}
	}

	function readCaseArray(context:UsageContext, identifier:Identifier, token:TokenTree, scopeEnd:Int) {
		if (!token.hasChildren()) {
			return;
		}
		for (child in token.children) {
			makeIdentifier(context, child, ScopedLocal(scopeEnd, CaseCapture), identifier);
		}
	}

	function readCaseStructure(context:UsageContext, identifier:Identifier, token:TokenTree, scopeEnd:Int) {
		if (!token.hasChildren()) {
			return;
		}
		for (child in token.children) {
			switch (child.tok) {
				case Const(_):
					var field:Null<Identifier> = makeIdentifier(context, child, StructureField([]), identifier);
					if (field == null) {
						continue;
					}
					if (!child.hasChildren()) {
						continue;
					}
					var valueChild:TokenTree = child.getFirstChild();
					switch (valueChild.tok) {
						case Kwd(_) | Const(_) | Dollar(_) | Unop(_) | Binop(_):
							readExpression(context, field, valueChild);
						case BkOpen | BrOpen:
							readCaseStructure(context, field, valueChild, scopeEnd);
							continue;
						default:
					}
					if (field.uses != null) {
						for (use in field.uses) {
							use.type = ScopedLocal(scopeEnd, CaseCapture);
						}
					}
				default:
					break;
			}
		}
	}

	function readParameter(context:UsageContext, identifier:Identifier, token:TokenTree, scopeEnd:Int):Array<Identifier> {
		var params:Array<Identifier> = [];
		for (child in token.children) {
			switch (child.tok) {
				case Const(CIdent(s)):
					var paramIdent:Identifier = makeIdentifier(context, child, ScopedLocal(scopeEnd, Parameter(params)), identifier);
					params.push(paramIdent);
				default:
			}
		}
		return params;
	}

	function makePosition(fileName:String, token:TokenTree):IdentifierPos {
		return {
			fileName: fileName,
			start: token.pos.min,
			end: token.pos.max
		}
	}

	function makeIdentifier(context:UsageContext, nameToken:TokenTree, type:IdentifierType, parentIdentifier:Null<Identifier>):Null<Identifier> {
		if (nameToken == null) {
			return null;
		}
		var pos:IdentifierPos = makePosition(context.fileName, nameToken);
		var pack:Array<String> = [];
		var typeParamLt:Null<TokenTree> = null;
		var typeHintColon:Null<TokenTree> = null;
		while (nameToken != null) {
			switch (nameToken.tok) {
				case Kwd(KwdThis) | Kwd(KwdNull) | Const(CIdent(_)):
					pack.push(nameToken.toString());
					pos.end = nameToken.pos.max;
				default:
					break;
			}
			if (!nameToken.hasChildren()) {
				break;
			}
			for (child in nameToken.children) {
				switch (child.tok) {
					case Kwd(KwdThis) | Kwd(KwdNull) | Const(_) | Dot | Binop(OpLt) | DblDot | POpen:
						nameToken = child;
						break;
					default:
				}
			}
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
				case POpen:
					if (type.match(Access)) {
						type = Call;
					}
					break;
				case DblDot:
					switch (TokenTreeCheckUtils.getColonType(nameToken)) {
						case SwitchCase:
						case TypeHint:
							typeHintColon = nameToken;
						case TypeCheck:
							typeHintColon = nameToken;
						case Ternary:
						case ObjectLiteral:
						case At:
						case Unknown:
					}
					break;
				default:
					break;
			}
			nameToken = nameToken.getFirstChild();
		}
		if (pack.length <= 0) {
			return null;
		}
		var identifier:Identifier = new Identifier(type, pack.join("."), pos, context.nameMap, context.file, context.type);

		if (parentIdentifier != null) {
			parentIdentifier.addUse(identifier);
		}
		if (typeParamLt != null) {
			addTypeParameter(context, identifier, typeParamLt);
		}
		if (typeHintColon != null) {
			readTypeHint(context, identifier, typeHintColon, TypeHint);
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
					makeIdentifier(context, child, TypedParameter, identifier);
				case POpen:
					readParameter(context, identifier, child, token.getPos().max);
				case Binop(OpGt):
					break;
				default:
			}
		}
	}

	function readTypeHint(context:UsageContext, identifier:Identifier, token:TokenTree, type:IdentifierType) {
		if (!token.hasChildren()) {
			return;
		}
		for (child in token.children) {
			switch (child.tok) {
				case Const(CIdent(_)):
					makeIdentifier(context, child, type, identifier);
				case BrOpen:
					readAnonStructure(context, identifier, child);
					break;
				default:
			}
		}
	}

	function readAnonStructure(context:UsageContext, identifier:Identifier, token:TokenTree) {
		if (!token.hasChildren()) {
			return;
		}
		var fields:Array<TypedefFieldType> = [];
		for (child in token.children) {
			switch (child.tok) {
				case Const(CIdent(_)):
					var identifier:Identifier = makeIdentifier(context, child, TypedefField(fields), identifier);
					if (child.access()
						.firstOf(At)
						.firstOf(DblDot)
						.firstOf(Const(CIdent("optional")))
						.exists()) {
						fields.push(Optional(identifier));
					} else {
						fields.push(Required(identifier));
					}
				case Kwd(KwdVar) | Kwd(KwdFinal):
					var nameToken:TokenTree = child.getFirstChild();
					var identifier:Identifier = makeIdentifier(context, nameToken, TypedefField(fields), identifier);
					if (nameToken.access()
						.firstOf(At)
						.firstOf(DblDot)
						.firstOf(Const(CIdent("optional")))
						.exists()) {
						fields.push(Optional(identifier));
					} else {
						fields.push(Required(identifier));
					}
				case Question:
					var identifier:Identifier = makeIdentifier(context, child.getFirstChild(), TypedefField(fields), identifier);
					fields.push(Optional(identifier));
				default:
			}
		}
	}
}
