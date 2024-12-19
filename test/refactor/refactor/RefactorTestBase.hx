package refactor.refactor;

import haxe.Exception;
import haxe.PosInfos;
import js.lib.Promise;
import utest.Async;
import refactor.RefactorResult;
import refactor.TestEditableDocument;

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

	function failCanRefactor(refactorType:RefactorType, what:RefactorWhat, expected:String, ?async:Async, ?pos:PosInfos) {
		try {
			doCanRefactor(refactorType, what, [], pos).then(function(success:RefactorResult) {
				Assert.equals(expected, PrintHelper.printRefactorResult(success), pos);
			}).catchError(function(failure) {
				Assert.equals(expected, '$failure', pos);
			}).finally(function() {
				if (async != null) {
					async.done();
				}
			});
		} catch (e:Exception) {
			Assert.fail(e.toString(), pos);
		}
	}

	function failRefactor(refactorType:RefactorType, what:RefactorWhat, expected:String, async:Async, ?pos:PosInfos) {
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
		final context:CanRefactorContext = {
			nameMap: usageContext.nameMap,
			fileList: usageContext.fileList,
			typeList: usageContext.typeList,
			what: what,
			verboseLog: function(text:String, ?pos:PosInfos) {
				Sys.println('${pos.fileName}:${pos.lineNumber}: $text');
			},
			typer: typer,
			converter: (string, byteOffset) -> byteOffset,
			fileReader: fileReader,
		};
		final isRangeSameScope:Bool = RefactorHelper.rangeInSameScope(context);
		var result = Refactoring.canRefactor(refactorType, context, isRangeSameScope);
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
			fileReader: fileReader,
		}).then(function(success:RefactorResult) {
			return assertEdits(success, editList, edits, pos);
		});
	}
}
