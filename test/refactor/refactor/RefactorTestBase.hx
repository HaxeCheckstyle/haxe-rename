package refactor.refactor;

import haxe.Exception;
import haxe.PosInfos;
import js.lib.Promise;
import byte.ByteData;
import haxeparser.HaxeLexer;
import hxparse.ParserError;
import tokentree.TokenTree;
import tokentree.TokenTreeBuilder;
import utest.Async;
import refactor.RefactorResult;
import refactor.TestEditableDocument;
import refactor.discover.FileContentType;

class RefactorTestBase extends TestBase {
	function checkRefactor(refactorType:RefactorType, what:RefactorWhat, edits:Array<TestEdit>, async:Async, ?pos:PosInfos) {
		try {
			doCanRefactor(refactorType, what, edits, pos).catchError(function(failure) {
				Assert.fail('$failure', pos);
			}).finally(function() {
				async.done();
			});
		} catch (e:Exception) {
			Assert.fail(e.toString(), pos);
		}
	}

	function failCanRefactor(refactorType:RefactorType, what:RefactorWhat, expected:String, async:Async, ?pos:PosInfos) {
		try {
			doCanRefactor(refactorType, what, [], pos).then(function(success:RefactorResult) {
				Assert.equals(expected, PrintHelper.printRefactorResult(success), pos);
			}).catchError(function(failure) {
				Assert.equals(expected, '$failure', pos);
			}).finally(function() {
				async.done();
			});
		} catch (e:Exception) {
			Assert.fail(e.toString(), pos);
		}
	}

	function failRename(refactorType:RefactorType, what:RefactorWhat, expected:String, async:Async, ?pos:PosInfos) {
		try {
			doRefactor(refactorType, what, [], pos).then(function(success:RefactorResult) {
				Assert.equals(expected, PrintHelper.printRefactorResult(success), pos);
			}).catchError(function(failure) {
				Assert.equals(expected, '$failure', pos);
			}).finally(function() {
				async.done();
			});
		} catch (e:Exception) {
			Assert.fail(e.toString(), pos);
		}
	}

	function doCanRefactor(refactorType:RefactorType, what:RefactorWhat, edits:Array<TestEdit>, pos:PosInfos):Promise<RefactorResult> {
		var editList:TestEditList = new TestEditList();
		var result = Refactoring.canRefactor(refactorType, {
			nameMap: usageContext.nameMap,
			fileList: usageContext.fileList,
			typeList: usageContext.typeList,
			what: what,
			verboseLog: function(text:String, ?pos:PosInfos) {
				Sys.println('${pos.fileName}:${pos.lineNumber}: $text');
			},
			typer: null,
			converter: (string, byteOffset) -> byteOffset,
			fileReader: testFileReader,
		});
		return switch (result) {
			case Unsupported:
				Promise.reject("unsupported");
			case Supported(title):
				doRefactor(refactorType, what, edits, pos);
		}
	}

	function doRefactor(refactorType:RefactorType, what:RefactorWhat, edits:Array<TestEdit>, pos:PosInfos):Promise<RefactorResult> {
		var editList:TestEditList = new TestEditList();
		return Refactoring.doRefactor(refactorType, {
			nameMap: usageContext.nameMap,
			fileList: usageContext.fileList,
			typeList: usageContext.typeList,
			what: what,
			forRealExecute: true,
			docFactory: (fileName) -> editList.newDoc(fileName),
			verboseLog: function(text:String, ?pos:PosInfos) {
				Sys.println('${pos.fileName}:${pos.lineNumber}: $text');
			},
			typer: typer,
			converter: (string, byteOffset) -> byteOffset,
			fileReader: testFileReader,
		}).then(function(success:RefactorResult) {
			return assertEdits(success, editList, edits, pos);
		});
	}
}

function testFileReader(path:String):FileContentType {
	final text = sys.io.File.getContent(path);
	var root:Null<TokenTree> = null;
	try {
		final content = ByteData.ofString(text);
		final lexer = new HaxeLexer(content, path);
		var t:haxeparser.Data.Token = lexer.token(haxeparser.HaxeLexer.tok);

		final tokens:Array<haxeparser.Data.Token> = [];
		while (t.tok != Eof) {
			tokens.push(t);
			t = lexer.token(haxeparser.HaxeLexer.tok);
		}
		root = TokenTreeBuilder.buildTokenTree(tokens, content, TypeLevel);
		return Token(root, text);
	} catch (e:ParserError) {
		throw 'failed to parse ${path} - ParserError: $e (${e.pos})';
	} catch (e:LexerError) {
		throw 'failed to parse ${path} - LexerError: ${e.msg} (${e.pos})';
	} catch (e:Exception) {
		throw 'failed to parse ${path} - ${e.details()}';
	}
}
