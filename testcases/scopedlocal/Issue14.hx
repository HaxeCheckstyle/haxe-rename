package scopedlocal;

class Issue14 {
	function stringWithToken(animation:Dynamic) {
		final anim = animation;

		anim.add("anim", [for (i in 0...10) i]);
		anim.play("anim");
	}

	function interpolationWithToken() {
		final foo = 5;
		trace(foo);
		trace('$foo');
	}
}
