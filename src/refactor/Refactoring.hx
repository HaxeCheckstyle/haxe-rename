package refactor;

import refactor.refactor.CanRefactorContext;
import refactor.refactor.CanRefactorResult;
import refactor.refactor.ExtractConstructorParams;
import refactor.refactor.ExtractInterface;
import refactor.refactor.ExtractMethod;
import refactor.refactor.ExtractType;
import refactor.refactor.RefactorContext;
import refactor.refactor.RefactorType;

class Refactoring {
	public static function canRefactor(refactorType:RefactorType, context:CanRefactorContext):CanRefactorResult {
		switch (refactorType) {
			case RefactorExtractInterface:
				return ExtractInterface.canRefactor(context);
			case RefactorExtractMethod:
				return ExtractMethod.canRefactor(context);
			case RefactorExtractType:
				return ExtractType.canRefactor(context);
			case RefactorExtractConstructorParams:
				return ExtractConstructorParams.canRefactor(context);
		}
		return null;
	}

	public static function doRefactor(refactorType:RefactorType, context:RefactorContext):Promise<RefactorResult> {
		switch (refactorType) {
			case RefactorExtractInterface:
				return ExtractInterface.doRefactor(context);
			case RefactorExtractMethod:
				return ExtractMethod.doRefactor(context);
			case RefactorExtractType:
				return ExtractType.doRefactor(context);
			case RefactorExtractConstructorParams:
				return ExtractConstructorParams.doRefactor(context);
		}
		return Promise.reject("no refactor type selected");
	}
}
