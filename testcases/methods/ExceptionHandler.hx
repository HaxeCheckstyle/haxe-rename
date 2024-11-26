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
