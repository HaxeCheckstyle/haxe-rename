package classes;

class JsonClass {
	var id:Int;
	var type:String;
	var width:Int;
	var maxWidth:Int;

	function new(id:Int, type:String, width:Int) {
		this.id = id;
		this.type = type;
		this.width = width;
		this.maxWidth = 2000;
	}

	public static function fromJson(group:JsonClass):JsonClass {
		var newgroup:Null<JsonClass> = new JsonClass(group.id, group.type, group.width);
		newgroup.id = group.id;
		newgroup.type = group.type;
		newgroup.width = group.width;
		newgroup.maxWidth = group.maxWidth;

		return newgroup;
	}

	public function jsonObject():JsonData {
		return {
			id: id,
			type: type,
			width: width,
			maxWidth: maxWidth
		};
	}

	public var prop(default, null):Int;
}

typedef JsonData = Any;
