package refactor.refactor.extractmethod;

import refactor.discover.Identifier;

class CodeGenOpenEnded extends CodeGenBase {
	final returnTokens:Array<TokenTree>;
	final assignments:Array<Identifier>;
	final vars:Array<Identifier>;

	public function new(extractData:ExtractMethodData, context:RefactorContext, neededIdentifiers:Array<Identifier>, returnTokens:Array<TokenTree>,
			assignments:Array<Identifier>, vars:Array<Identifier>) {
		super(extractData, context, neededIdentifiers);

		this.returnTokens = returnTokens;
		this.assignments = assignments;
		this.vars = vars;
	}

	public function makeCallSite():String {
		final callParams:String = neededIdentifiers.map(i -> i.name).join(", ");
		final call = '${extractData.newMethodName}($callParams)';

		return switch [assignments.length, vars.length] {
			case [0, 0]:
				'switch ($call) {\n' + "case Some(data):\n" + "return data;\n" + "case None:\n" + "}\n";
			case [1, 0]:
				'{\nfinal result = $call;\n'
				+ "switch (result.ret) {\n"
				+ "case Some(data):\n"
				+ "return data;\n"
				+ "case None:\n"
				+ '${assignments[0].name} = result.data;\n'
				+ "}\n"
				+ "}\n";
			case [0, 1]:
				'var ${vars[0].name};\n'
				+ '{\nfinal result = $call;\n'
				+ "switch (result.ret) {\n"
				+ "case Some(data):\n"
				+ "return data;\n"
				+ "case None:\n"
				+ '${vars[0].name} = result.data;\n'
				+ "}\n"
				+ "}\n";
			case [_, _]:
				final dataVars = vars.map(v -> 'var ${v.name};').join("\n");
				final assignData = assignments.map(a -> '${a.name} = result.data.${a.name};').join("\n");
				final varsData = vars.map(v -> '${v.name} = result.data.${v.name};').join("\n");
				'$dataVars'
				+ '{\nfinal result = $call;\n'
				+ "switch (result.ret) {\n"
				+ "case Some(data):\n"
				+ "return data;\n"
				+ "case None:\n"
				+ '${assignData}${varsData}'
				+ "}\n"
				+ "}\n";
		}
	}

	public function makeReturnTypeHint():Promise<String> {
		return switch [assignments.length, vars.length] {
			case [0, 0]:
				return parentTypeHint().then(function(typeHint):Promise<String> {
					if (typeHint == null) {
						return Promise.resolve("");
					}
					return Promise.resolve(":haxe.ds.Option<" + typeHint.printTypeHint() + ">");
				});
			case [1, 0]:
				final promises:Array<Promise<String>> = [];
				promises.push(parentTypeHint().then(function(typeHint):Promise<String> {
					if (typeHint == null) {
						return Promise.resolve("");
					}
					return Promise.resolve("ret:haxe.ds.Option<" + typeHint.printTypeHint() + ">");
				}));
				promises.push(findTypeOfIdentifier(assignments[0]).then(function(typeHint):Promise<String> {
					if (typeHint == null) {
						return Promise.resolve("");
					}
					return Promise.resolve("?data:" + typeHint.printTypeHint());
				}));
				return Promise.all(promises).then(function(fields) {
					return Promise.resolve(":{" + fields.join(", ") + "}");
				});
			case [0, 1]:
				final promises:Array<Promise<String>> = [];
				promises.push(parentTypeHint().then(function(typeHint):Promise<String> {
					if (typeHint == null) {
						return Promise.resolve("");
					}
					return Promise.resolve("ret:haxe.ds.Option<" + typeHint.printTypeHint() + ">");
				}));
				promises.push(findTypeOfIdentifier(vars[0]).then(function(typeHint):Promise<String> {
					if (typeHint == null) {
						return Promise.resolve("");
					}
					return Promise.resolve("?data:" + typeHint.printTypeHint());
				}));
				return Promise.all(promises).then(function(fields) {
					return Promise.resolve(":{" + fields.join(", ") + "}");
				});
			case [_, _]:
				final returnPromise = parentTypeHint().then(function(typeHint):Promise<String> {
					if (typeHint == null) {
						return Promise.resolve("");
					}
					return Promise.resolve("ret:haxe.ds.Option<" + typeHint.printTypeHint() + ">");
				});
				final promises:Array<Promise<String>> = [];
				for (assign in assignments) {
					promises.push(findTypeOfIdentifier(assign).then(function(typeHint):Promise<String> {
						if (typeHint == null) {
							return Promise.resolve(assign.name + ":Any");
						}
						return Promise.resolve(assign.name + ":" + typeHint.printTypeHint());
					}));
				}
				for (v in vars) {
					promises.push(findTypeOfIdentifier(v).then(function(typeHint):Promise<String> {
						if (typeHint == null) {
							return Promise.resolve(v.name + ":Any");
						}
						return Promise.resolve(v.name + ":" + typeHint.printTypeHint());
					}));
				}
				final fieldsPromise = Promise.all(promises).then(function(fields) {
					return Promise.resolve("?data:{" + fields.join(", ") + "}");
				});
				return Promise.all([returnPromise, fieldsPromise]).then(function(fields) {
					return Promise.resolve(":{" + fields.join(", ") + "}");
				});
		}
	}

	function parentTypeHint():Promise<TypeHintType> {
		var func:Null<TokenTree> = findParentFunction();
		if (func == null) {
			return Promise.reject("failed to find return type of selected code");
		}
		return TypingHelper.findTypeWithTyper(context, context.what.fileName, func.pos.max - 1).then(function(typeHint) {
			return switch (typeHint) {
				case null | ClasspathType(_) | LibType(_) | StructType(_) | UnknownType(_):
					Promise.resolve(typeHint);
				case FunctionType(args, retVal):
					Promise.resolve(retVal);
			}
		});
	}

	function findParentFunction():Null<TokenTree> {
		var token = extractData.startToken.parent;
		while (true) {
			switch (token.tok) {
				case Kwd(KwdFunction):
					var child = token.getFirstChild();
					if (child == null) {
						return null;
					}
					switch (child.tok) {
						case Const(_):
							return child;
						default:
							return token;
					}
				case Arrow:
					return token;
				case Root:
					return null;
				default:
					token = token.parent;
			}
		}
	}

	public function makeBody():String {
		return switch [assignments.length, vars.length] {
			case [0, 0]:
				final snippet = replaceReturnValues(returnTokens, value -> 'Some($value)');
				return " {\n" + snippet + "\nreturn None;\n}\n";
			case [1, 0]:
				final snippet = replaceReturnValues(returnTokens, value -> '{ret: Some($value)}');
				final returnData = '{ret: None, data: ${assignments[0].name}}';
				return " {\n" + snippet + '\nreturn $returnData;\n}\n';
			case [0, 1]:
				final snippet = replaceReturnValues(returnTokens, value -> '{ret: Some($value)}');
				final returnData = '{ret: None, data: ${vars[0].name}}';
				return " {\n" + snippet + '\nreturn $returnData;\n}\n';
			case [_, _]:
				final snippet = replaceReturnValues(returnTokens, value -> '{ret: Some($value)}');
				final assignData = assignments.map(a -> '${a.name}: ${a.name},\n');
				final varsData = vars.map(v -> '${v.name}: ${v.name},\n');
				final returnData = '{ret: None, data: {$assignData$varsData}}';
				return " {\n" + snippet + '\nreturn $returnData;\n}\n';
		}
	}
}
