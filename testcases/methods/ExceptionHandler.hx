package testcases.methods;

class ExceptionHandler {
	function process() {
		try {
			var data = getData();
			validateData(data);
			processData(data);
		} catch (e:InvalidDataException) {
			logError(e);
			throw new ProcessingException(e.message);
		}
		try {
			var data = getData();
			if (data.value > 10) {
				return;
			}
			throw new InvalidDataException("value should not be smaller than 11");
		} catch (e:InvalidDataException) {
			logError(e);
			throw new ProcessingException(e.message);
		}
		try {
			var data = getData();
			if (data.value > 10) {
				throw new InvalidDataException("value should not be larger than 10");
			}
			validateData(data);
			processData(data);
		} catch (e:InvalidDataException) {
			logError(e);
			throw new ProcessingException(e.message);
		}
	}

	function getData():DataType {
		return {text: "test", value: 100};
	}

	function validateData(data:DataType):Void {}

	function processData(data:DataType):Void {}

	function logError(e:InvalidDataException):Void {}
}

typedef DataType = {
	var text:String;
	var value:Int;
};

typedef InvalidDataException = haxe.Exception;

class ProcessingException {
	public function new(message:String) {}
}
