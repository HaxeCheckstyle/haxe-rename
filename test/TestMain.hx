import refactor.refactor.RefactorExtractConstructorParams;
import refactor.refactor.RefactorExtractInterfaceTest;
import refactor.refactor.RefactorExtractMethodTest;
import refactor.refactor.RefactorExtractTypeTest;
import refactor.refactor.RewriteFinalsToVarsTest;
import refactor.refactor.RewriteVarsToFinalsTest;
import refactor.refactor.RewriteWrapWithTryCatchTest;
import refactor.rename.RenameClassTest;
import refactor.rename.RenameEnumTest;
import refactor.rename.RenameImportAliasTest;
import refactor.rename.RenameInterfaceTest;
import refactor.rename.RenameModuleLevelStaticTest;
import refactor.rename.RenamePackageTest;
import refactor.rename.RenameScopedLocalTest;
import refactor.rename.RenameTypedefTest;
import refactor.typing.TypeHintFromTreeTest;
import refactor.typing.TypingTest;
import utest.Runner;
import utest.ui.text.DiagnosticsReport;

class TestMain {
	static function main() {
		var tests:Array<ITest> = [
			new RenameClassTest(),
			new RenameEnumTest(),
			new TypingTest(),
			new TypeHintFromTreeTest(),
			new RenameImportAliasTest(),
			new RenameInterfaceTest(),
			new RenameModuleLevelStaticTest(),
			new RenamePackageTest(),
			new RenameScopedLocalTest(),
			new RenameTypedefTest(),
			new RefactorExtractTypeTest(),
			new RefactorExtractInterfaceTest(),
			new RewriteFinalsToVarsTest(),
			new RewriteVarsToFinalsTest(),
			new RewriteWrapWithTryCatchTest(),

			new RefactorExtractMethodTest(),
			new RefactorExtractConstructorParams(),
		];
		var runner:Runner = new Runner();

		#if instrument
		runner.onComplete.add(_ -> {
			instrument.coverage.Coverage.endCoverage();
		});
		#end

		new DiagnosticsReport(runner);
		for (test in tests) {
			runner.addCase(test);
		}
		runner.run();
	}
}
