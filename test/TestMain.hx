import refactor.InterfacesTest;
import utest.Runner;
import utest.ui.Report;

using StringTools;

class TestMain {
	static function main() {
		var tests:Array<ITest> = [new InterfacesTest()];
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
