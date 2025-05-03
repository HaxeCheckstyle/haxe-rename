package scopedlocal;

class Issue13 {
	function renameLocalVar(accs:Array<String>) {
		var data:{value:Int} = {
			value: null
		};
		var keys;
		var uid = data?.value ?? null;
		if (uid == null) {
			return;
		}

		if (accs != null) {
			trace('Changed account to $uid');
			keys = accs[uid];
		}
	}

	function doSomething(foo:Int) {
		for (i in 0...foo)
			trace(i);
	}

	function doSomething2() {
		final foo = 1;
		for (i in 0...foo)
			trace(i);
	}
}
