package testcases.classes;

class DemoClassA {
	public var someValue:String;
}

class SomeOtherClass {
	public function isEventFeatureFlag(aString:String):Bool {
		return false;
	}

	public function new() {}
}

class WontRename {
	var TESTRENAME:Bool = false;

	var _view:{
		isAssetsLoaded:Bool
	};
	var _someOtherClass:SomeOtherClass = new SomeOtherClass();

	function _onFeatureEnds(event:DemoClassA) {
		// misses a rename in the next line
		if (_view.isAssetsLoaded && _someOtherClass.isEventFeatureFlag(event.someValue) && TESTRENAME) {
			TESTRENAME = false;
		}
	}
}
