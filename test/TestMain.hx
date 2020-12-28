import refactor.TypedefTest;
import refactor.ClassTest;
import refactor.EnumTest;
import refactor.ImportAliasTest;
import refactor.InterfaceTest;
import refactor.ModuleLevelStaticTest;
import refactor.ScopedLocalTest;
import utest.Runner;
import utest.ui.Report;

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

		Report.create(runner);
		for (test in tests) {
			runner.addCase(test);
		}
		runner.run();
	}
}
