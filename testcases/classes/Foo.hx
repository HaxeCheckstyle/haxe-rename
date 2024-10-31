package testcases.classes;

enum Foo {
	Value(data:String);
	Option(value:String, callback:Foo->Void);
}

var other = 43; // works here

var e = Foo.Option('something', (resp) -> {
	resp.extract(Value(data) => {
		var x = 4; // fails here
	})
});
