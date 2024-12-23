package typedefs;

typedef ExperimentalCapabilities = {
	/**
		List of supported commands on client, like `"codeAction.insertSnippet"`,
		to generate snippets in code actions, instead of simple text edits
	**/
	var ?supportedCommands:Array<String>;

	/** Forces resolve support for code actions `command` property **/
	var ?forceCommandResolveSupport:Bool;
}

function canRun(capabilities:ExperimentalCapabilities):Bool {
	if (capabilities.forceCommandResolveSupport != null && capabilities.forceCommandResolveSupport) {
		return true;
	}
	return false;
}
