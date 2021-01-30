import refactor.ClassTest;
import refactor.EnumTest;
import refactor.ImportAliasTest;
import refactor.InterfaceTest;
import refactor.ModuleLevelStaticTest;
import refactor.ScopedLocalTest;
import refactor.TypedefTest;
import utest.Runner;
import utest.ui.text.DiagnosticsReport;

class TestMain {
	static function main() {
		var tests:Array<ITest> = [
			new ClassTest(),
			new EnumTest(),
			new ImportAliasTest(),
			new InterfaceTest(),
			new ModuleLevelStaticTest(),
			new ScopedLocalTest(),
			new TypedefTest()
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
