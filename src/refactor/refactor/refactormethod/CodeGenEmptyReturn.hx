package refactor.refactor.refactormethod;

import refactor.discover.Identifier;
import refactor.refactor.ExtractMethod.ExtractMethodData;

class CodeGenEmptyReturn extends CodeGenBase {
	final assignments:Array<Identifier>;
	final vars:Array<Identifier>;

	public function new(extractData:ExtractMethodData, context:RefactorContext, neededIdentifiers:Array<Identifier>, assignments:Array<Identifier>,
			vars:Array<Identifier>) {
		super(extractData, context, neededIdentifiers);

		this.assignments = assignments;
		this.vars = vars;
	}

	public function makeCallSite():String {
		final callParams:String = neededIdentifiers.map(i -> i.name).join(", ");
		return switch [assignments.length, vars.length] {
			case [0, 0]:
				'if (!${extractData.newMethodName}($callParams)) {\nreturn;\n}\n';
			case [1, 0]:
				'switch (${extractData.newMethodName}($callParams)) {\n'
				+ 'case None:\n'
				+ 'return;\n'
				+ 'case Some(data):\n'
				+ '${assignments[0].name} = data;\n}\n';
			case [_, 0]:
				final assignData = assignments.map(a -> '${a.name} = data.${a.name};').join("\n");
				'{\nfinal data =${extractData.newMethodName}($callParams);\n' + assignData + "}\n";
				'switch (${extractData.newMethodName}($callParams)) {\n'
				+ 'case None:\n'
				+ 'return;\n'
				+ 'case Some(data):\n'
				+ '${assignData}}\n';
			case [_, _]:
				"TODO please implement!! :)";
		}
	}

	public function makeReturnTypeHint():Promise<String> {
		return switch (assignments.length) {
			case 0:
				return Promise.resolve(":Bool");
			case 1:
				return findTypeOfIdentifier(assignments[0]).then(function(typeHint):Promise<String> {
					if (typeHint == null) {
						return Promise.resolve("");
					}
					return Promise.resolve(":haxe.ds.Option<" + typeHint.printTypeHint() + ">");
				});
			default:
				var promises:Array<Promise<String>> = [];
				for (assign in assignments) {
					promises.push(findTypeOfIdentifier(assign).then(function(typeHint):Promise<String> {
						if (typeHint == null) {
							return Promise.resolve(assign.name + ":Any");
						}
						return Promise.resolve(":" + typeHint.printTypeHint());
					}));
				}
				return Promise.all(promises).then(function(fields) {
					return Promise.resolve(":haxe.ds.Option<{" + fields.join(", ") + "}>");
				});
		}
	}

	public function makeBody():String {
		final selectedSnippet = RefactorHelper.extractText(context.converter, extractData.content, extractData.startToken.pos.min,
			extractData.endToken.pos.max);
		return switch (assignments.length) {
			case 0:
				final reg:EReg = ~/^([ \t]*)return[ \t]*;/gm;
				final replacedSnippet = reg.map(selectedSnippet, f -> f.matched(1) + "return false;");
				" {\n" + replacedSnippet + "\nreturn true;\n}\n";
			case 1:
				final reg:EReg = ~/^([ \t]*)return[ \t]*;/gm;
				final replacedSnippet = reg.map(selectedSnippet, f -> f.matched(1) + "return None;");
				final returnAssigmentVar = '\nreturn Some(${assignments[0].name});';
				" {\n" + replacedSnippet + returnAssigmentVar + "\n}\n";
			default:
				final reg:EReg = ~/^([ \t]*)return[ \t]*;/gm;
				final replacedSnippet = reg.map(selectedSnippet, f -> f.matched(1) + "return None;");
				final returnAssigments = "\nreturn Some({\n" + assignments.map(a -> '${a.name}: ${a.name},\n') + "});";
				" {\n" + replacedSnippet + returnAssigments + "\n}\n";
		}
	}
}
