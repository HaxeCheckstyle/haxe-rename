package testcases.methods;

class MetadataProcessor {
	@:meta(test)
	function process() {
		var cls = Type.getClass(this);
		var meta = haxe.rtti.Meta.getFields(cls);
		var results = new Map<String, Array<String>>();

		for (field in Reflect.fields(meta)) {
			var fieldMeta = Reflect.field(meta, field);
			if (Reflect.hasField(fieldMeta, "meta")) {
				var metaValues = Reflect.field(fieldMeta, "meta");
				if (Std.isOfType(metaValues, Array)) {
					var values = cast(metaValues, Array<Dynamic>);
					results.set(field, [for (v in values) Std.string(v)]);
				}
			}
		}

		for (field => values in results) {
			trace('Field: $field, Meta: ${values.join(", ")}');
		}
	}
}
