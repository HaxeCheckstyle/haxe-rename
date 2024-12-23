package testcases.methods;

class PersonHandler {
	function handle(person:{name:String, age:Int}) {
		var info = "Name: " + person.name + ", Age: " + person.age;
		trace(info);
	}
}
