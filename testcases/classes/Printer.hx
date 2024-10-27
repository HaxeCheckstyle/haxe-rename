package testcases.classes;

import js.Browser;
import tink.core.Future;
import tink.core.Promise;

@:expose class PrinterMain {
	public static function main():Void {
		// Setup stuff
		final futureTrigger = Future.trigger();
		futureTrigger.trigger("Future");

		final promise:Promise<String> = Promise.resolve("Promise");

		// Example 1 - "Normal" usage of `Printer` (WORKS)
		new Printer("Normal");

		// Example 2 - `Printer` used within promise handling (WORKS)
		promise.handle(result -> {
			switch (result) {
				case Success(text): new Printer(text);
				default:
			}
		});

		// Example 3 - `Printer` used within future handling (FAILS)
		futureTrigger.asFuture().handle(text -> {
			new Printer(text);
		});

		// Example 4 - `Printer` used within promise handling but promise is created in `TextLoader` (FAILS)
		new TextLoader().load("TextLoader").handle(result -> {
			switch (result) {
				case Success(text): new Printer(text);
				default:
			}
		});

		new TextLoader().load["TextLoader"].handle(result -> {
			switch (result) {
				case Success(text): new Printer(text);
				default:
			}
		});
	}
}

// Rename this class and observe that examples 1 and 2 are updated, but the others are not.
class Printer {
	public function new(text:String) {
		Browser.console.log(text);
	}
}

class TextLoader {
	public function new() {}

	public function load(text:String):Promise<String> {
		return Promise.resolve(text);
	}
}
