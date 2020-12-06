import refactor.InterfacesTest;
import refactor.ModuleLevelStaticsTest;
import refactor.ScopedLocalTest;
import utest.Runner;
import utest.ui.Report;

class TestMain {
	static function main() {
		var tests:Array<ITest> = [new InterfacesTest(), new ModuleLevelStaticsTest(), new ScopedLocalTest()];
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
