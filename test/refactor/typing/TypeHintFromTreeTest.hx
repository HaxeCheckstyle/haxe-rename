package refactor.typing;

import haxe.PosInfos;
import js.lib.Promise;

class TypeHintFromTreeTest extends TestBase {
	final intType:TypeHintType = LibType("Int", "Int", []);
	final boolType:TypeHintType = LibType("Bool", "Bool", []);
	final stringType:TypeHintType = LibType("String", "String", []);
	final voidType:TypeHintType = LibType("Void", "Void", []);

	function testTypeHints() {
		setupTestSources(["testcases/typehints"]);

		final myTypeType:TypeHintType = makeCp("typehints.Main.MyType", []);
		final newTypeMyTypeTypeInt:TypeHintType = makeCp("typehints.Main.NewType", [myTypeType, intType]);
		final newTypeMyTypeTypeBool:TypeHintType = makeCp("typehints.Main.NewType", [myTypeType, boolType]);

		findAndCompareTypeHint("intIdent", intType);
		findAndCompareTypeHint("boolIdent", boolType);
		findAndCompareTypeHint("myTypeIdent", myTypeType);
		findAndCompareTypeHint("newTypeIdent", newTypeMyTypeTypeInt);
		findAndCompareTypeHint("nullNewTypeIdent", LibType("Null", "Null", [newTypeMyTypeTypeInt]));
		findAndCompareTypeHint("fullNullNewTypeIdent", LibType("Null", "Null", [newTypeMyTypeTypeBool]));
		findAndCompareTypeHint("intStringBoolIdentOld", FunctionType([intType, stringType], boolType));
		findAndCompareTypeHint("intStringBoolIdentNew", FunctionType([intType, stringType], boolType));
		findAndCompareTypeHint("loopVoidIdent", FunctionType([NamedType("loop", intType)], voidType));
		findAndCompareTypeHint("loop2VoidIdent", FunctionType([NamedType("loop", intType), NamedType("loop2", intType)], voidType));
		findAndCompareTypeHint("intStringVoidNullIdent", FunctionType([intType, stringType], voidType));
	}

	@:access(refactor.typing.TypingHelper)
	function findAndCompareTypeHint(fullTypeName:String, expectedTypeHint:TypeHintType, ?pos:PosInfos) {
		final idents = usageContext.nameMap.getIdentifiers(fullTypeName);
		Assert.equals(1, idents.length, pos);
		if (idents.length == 1) {
			final actualTypeHint = idents[0].getTypeHintNew(usageContext.typeList);
			Assert.notNull(actualTypeHint, pos);
			Assert.equals(expectedTypeHint.typeHintToString(), actualTypeHint.typeHintToString(), pos);
			Assert.isTrue(TypingHelper.typeHintsEqual(actualTypeHint, expectedTypeHint), pos);
		}
	}

	function makeCp(fullTypeName:String, params:Array<TypeHintType>):TypeHintType {
		final type = usageContext.typeList.getType(fullTypeName);
		if (type == null) {
			return LibType(fullTypeName, fullTypeName, params);
		}
		return ClasspathType(type, params);
	}
}
