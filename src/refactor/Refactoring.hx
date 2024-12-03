package refactor;

import refactor.refactor.CanRefactorContext;
import refactor.refactor.CanRefactorResult;
import refactor.refactor.ExtractConstructorParams;
import refactor.refactor.ExtractInterface;
import refactor.refactor.ExtractMethod;
import refactor.refactor.ExtractType;
import refactor.refactor.RefactorContext;
import refactor.refactor.RefactorType;
import refactor.refactor.RewriteVarsToFinals;

class Refactoring {
	public static function canRefactor(refactorType:RefactorType, context:CanRefactorContext):CanRefactorResult {
		switch (refactorType) {
			case RefactorExtractInterface:
				return ExtractInterface.canRefactor(context);
			case RefactorExtractMethod:
				return ExtractMethod.canRefactor(context);
			case RefactorExtractType:
				return ExtractType.canRefactor(context);
			case RefactorExtractConstructorParams(asFinal):
				return ExtractConstructorParams.canRefactor(context, asFinal);
			case RefactorRewriteVarsToFinals(toFinals):
				return RewriteVarsToFinals.canRefactor(context, toFinals);
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
			case RefactorExtractConstructorParams(asFinal):
				return ExtractConstructorParams.doRefactor(context, asFinal);
			case RefactorRewriteVarsToFinals(toFinals):
				return RewriteVarsToFinals.doRefactor(context, toFinals);
		}
		return Promise.reject("no refactor type selected");
	}
}
