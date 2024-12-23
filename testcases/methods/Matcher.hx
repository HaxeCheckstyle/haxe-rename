package testcases.methods;

class Matcher {
	function process(value:Any) {
		return switch value {
			case Int(i) if (i > 0): 'Positive: $i';
			case String(s) if (s.length > 0): 'NonEmpty: $s';
			case Array(a) if (a.length > 0): 'HasElements: ${a.length}';
			case _: 'Unknown';
		}
	}
}
