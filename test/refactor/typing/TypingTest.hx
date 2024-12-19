package refactor.typing;

import haxe.PosInfos;
import js.lib.Promise;

class TypingTest extends TestBase {
	function testEnums(async:Async) {
		setupTestSources(["testcases/enums"]);

		findAndCompareTypeHint("enums.Main", "type", 87, makeCp("enums.IdentifierType", []));
		findAndCompareTypeHint("enums.Main", "type", 120, makeCp("enums.IdentifierType", []));
		findAndCompareTypeHint("enums.Main", "PackageName", 137, makeCp("enums.IdentifierType", []));
		findAndCompareTypeHint("enums.Main", "ScopedLocal", 237, makeCp("enums.IdentifierType", []));
		findAndCompareTypeHint("enums.Main", "scopeEnd", 250, LibType("Int", "Int", []));
		findAndCompareTypeHint("enums.Main", "ScopedLocal", 270, makeCp("enums.ScopedLocal", []));
		findAndCompareTypeHint("enums.Main", "scopeEnd", 283, LibType("Int", "Int", []));
		findAndCompareTypeHint("enums.Main", "StringConst", 409, makeCp("enums.IdentifierType", []));

		findAndCompareTypeHint("enums.Main", "PackageName", 709, makeCp("enums.IdentifierTypeCopy", []));
		findAndCompareTypeHint("enums.Main", "scopeEnd", 786, LibType("Int", "Int", []));

		findAndCompareTypeHint("enums.Main", "PackageName", 1084, makeCp("enums.IdentifierType", []));
		findAndCompareTypeHint("enums.Main", "scopeEnd", 1149, LibType("Int", "Int", []));

		findAndCompareTypeHint("enums.Main", "PackageName", 1377, makeCp("enums.IdentifierType", []));
		findAndCompareTypeHint("enums.Main", "scopeEnd", 1444, LibType("Int", "Int", []));

		findAndCompareTypeHint("enums.Main", "PackageName", 1686, makeCp("enums.IdentifierType", []));
		findAndCompareTypeHint("enums.Main", "scopeEnd", 1750, LibType("Int", "Int", []));

		failTypeHint("enums.Main", "ScopedLocal", 1875);

		findAndCompareTypeHint("enums.Main", "IdentifierType.PackageName", 2222, makeCp("enums.IdentifierType", []));

		findAndCompareTypeHint("enums.Main", "scopeEnd", 2331, LibType("Int", "Int", []));

		findAndCompareTypeHint("enums.Identifier", "children", 84, LibType("Array", "Array", [makeCp("enums.Identifier", [])]));

		findAndCompareTypeHint("enums.Main", "type", 87, makeCp("enums.IdentifierType", []), async);
	}

	@:access(refactor.typing.TypingHelper)
	function findAndCompareTypeHint(fullTypeName:String, searchName:String, searchPos:Int, expectedTypeHint:TypeHintType, ?async:Async, ?pos:PosInfos) {
		findTypeHint(fullTypeName, searchName, searchPos).then(function(actualTypeHint) {
			Assert.notNull(actualTypeHint, pos);
			Assert.equals(expectedTypeHint.typeHintToString(), actualTypeHint.typeHintToString(), pos);
			Assert.isTrue(TypingHelper.typeHintsEqual(actualTypeHint, expectedTypeHint), pos);
		}).catchError(function(error) {
			trace("error: " + error);
			Assert.fail(error, pos);
		}).finally(function() {
			if (async != null) {
				async.done();
			}
		});
	}

	@:access(refactor.typing.TypingHelper)
	function failTypeHint(fullTypeName:String, searchName:String, searchPos:Int, ?async:Async, ?pos:PosInfos) {
		findTypeHint(fullTypeName, searchName, searchPos).then(function(actualTypeHint) {
			Assert.fail("should fail to produce type hint", pos);
		}).catchError(function(error) {
			trace("error: " + error);
			Assert.notNull(error, pos);
		}).finally(function() {
			if (async != null) {
				async.done();
			}
		});
	}

	function makeCp(fullTypeName:String, params:Array<TypeHintType>):TypeHintType {
		final type = usageContext.typeList.getType(fullTypeName);
		if (type == null) {
			return LibType(fullTypeName, fullTypeName, params);
		}
		return ClasspathType(type, params);
	}

	@:access(refactor.typing.TypingHelper)
	function findTypeHint(fullTypeName:String, searchName:String, searchPos:Int):Promise<TypeHintType> {
		final containerType = usageContext.typeList.getType(fullTypeName);
		return TypingHelper.findTypeWithBuiltIn(containerType, searchName, searchPos, {
			nameMap: usageContext.nameMap,
			fileList: usageContext.fileList,
			typeList: usageContext.typeList,
			verboseLog: function(text:String, ?pos:PosInfos) {
				Sys.println('${pos.fileName}:${pos.lineNumber}: $text');
			},
			typer: typer,
			fileReader: fileReader,
			converter: (string, byteOffset) -> byteOffset,
		});
	}
}
