import refactor.refactor.RefactorClassTest;
import refactor.refactor.RefactorExtractMethodTest;
import refactor.refactor.RefactorTypedefTest;
import refactor.rename.RenameClassTest;
import refactor.rename.RenameEnumTest;
import refactor.rename.RenameImportAliasTest;
import refactor.rename.RenameInterfaceTest;
import refactor.rename.RenameModuleLevelStaticTest;
import refactor.rename.RenamePackageTest;
import refactor.rename.RenameScopedLocalTest;
import refactor.rename.RenameTypedefTest;
import utest.Runner;
import utest.ui.text.DiagnosticsReport;

class TestMain {
	static function main() {
		var tests:Array<ITest> = [
			new RenameClassTest(),
			new RenameEnumTest(),
			new RenameImportAliasTest(),
			new RenameInterfaceTest(),
			new RenameModuleLevelStaticTest(),
			new RenamePackageTest(),
			new RenameScopedLocalTest(),
			new RenameTypedefTest(),
			new RefactorClassTest(),
			new RefactorTypedefTest(),
			new RefactorExtractMethodTest(),
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
