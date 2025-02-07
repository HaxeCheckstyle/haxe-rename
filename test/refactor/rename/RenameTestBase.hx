package refactor.rename;

import haxe.Exception;
import haxe.PosInfos;
import js.lib.Promise;
import utest.Async;
import refactor.RefactorResult;
import refactor.Rename;
import refactor.TestEditableDocument;

class RenameTestBase extends TestBase {
	function checkRename(what:RenameWhat, edits:Array<TestEdit>, async:Async, ?pos:PosInfos) {
		try {
			doCanRename(what, edits, pos).catchError(function(failure) {
				Assert.fail('$failure', pos);
			}).finally(function() {
				async.done();
			});
		} catch (e:Exception) {
			Assert.fail(e.toString(), pos);
		}
	}

	function failCanRename(what:RenameWhat, expected:String, ?async:Async, ?pos:PosInfos) {
		try {
			doCanRename(what, [], pos).then(function(success:RefactorResult) {
				Assert.equals(expected, PrintHelper.printRenameResult(success), pos);
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

	function failRename(what:RenameWhat, expected:String, async:Async, ?pos:PosInfos) {
		try {
			doRename(what, [], pos).then(function(success:RefactorResult) {
				Assert.equals(expected, PrintHelper.printRenameResult(success), pos);
			}).catchError(function(failure) {
				Assert.equals(expected, '$failure', pos);
			}).finally(function() {
				async.done();
			});
		} catch (e:Exception) {
			Assert.fail(e.toString(), pos);
		}
	}

	function doCanRename(what:RenameWhat, edits:Array<TestEdit>, pos:PosInfos):Promise<RefactorResult> {
		var editList:TestEditList = new TestEditList();
		return Rename.canRename({
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
		}).then(function(success:CanRenameResult) {
			return doRename(what, edits, pos);
		});
	}

	function doRename(what:RenameWhat, edits:Array<TestEdit>, pos:PosInfos):Promise<RefactorResult> {
		var editList:TestEditList = new TestEditList();
		return Rename.rename({
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
