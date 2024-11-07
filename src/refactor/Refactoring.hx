package refactor;

import refactor.refactor.CanRefactorContext;
import refactor.refactor.CanRefactorResult;
import refactor.refactor.ExtractInterface;
import refactor.refactor.ExtractType;
import refactor.refactor.RefactorContext;
import refactor.refactor.RefactorType;

class Refactoring {
	public static function canRefactor(refactorType:RefactorType, context:CanRefactorContext):CanRefactorResult {
		switch (refactorType) {
			case RefactorExtractType:
				return ExtractType.canRefactor(context);
			case RefactorExtractInterface:
				return ExtractInterface.canRefactor(context);
		}
		return null;
	}

	public static function doRefactor(refactorType:RefactorType, context:RefactorContext):Promise<RefactorResult> {
		switch (refactorType) {
			case RefactorExtractType:
				return ExtractType.doRefactor(context);
			case RefactorExtractInterface:
				return ExtractInterface.doRefactor(context);
		}
		return Promise.resolve(RefactorResult.Unsupported("no refactor type selected"));
	}
}
