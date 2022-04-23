package typedefs;

import haxe.io.Path;
import typedefs.Types.ExtendedIdentifierPos;
import typedefs.Types.IdentifierPos;

class Main {
	static function main() {
		var fileName = Path.join(["..", ".."]);
		var start = 0;
		var end = 0;
		var line = 0;
		var char = 0;
		var msg = "";

		var pos = {
			fileName: fileName,
			start: start,
			end: end
		};

		var posEx:ExtendedIdentifierPos = {
			fileName: fileName,
			start: start,
			end: end,
			line: line,
			char: char
		};
		posEx = {
			fileName: fileName,
			start: start,
			end: end,
			line: line,
			char: char,
			msg: msg
		};

		printIdentifierPos(pos);
		printIdentifierPos(posEx);
		printIdentifierPos({fileName: "file", start: 10, end: 20});
		printIdentifierPos({fileName: fileName, start: 10, end: 20});
	}

	static function printIdentifierPos(pos:IdentifierPos) {
		trace(pos.fileName.length);
	}

	static function printExtendedIdentifierPos(pos:ExtendedIdentifierPos) {
		trace(pos.fileName.length);
		var srcFolders:Array<String> = ["src", "Source", "test", "tests"];
		final context:Context;
		if (context.config.user.renameSourceFolders != null) {
			srcFolders = context.config.user.renameSourceFolders;
		}
	}

	static final DefaultUserSettings:UserConfig = {
		enableCodeLens: false,
		enableDiagnostics: true,
		enableServerView: false,
		enableSignatureHelpDocumentation: true,
		diagnosticsPathFilter: "${workspaceRoot}",
		displayPort: null,
		buildCompletionCache: true,
		enableCompletionCacheWarning: true,
		useLegacyCompletion: false,
		codeGeneration: {
			functions: {
				anonymous: {
					argumentTypeHints: false,
					returnTypeHint: Never,
					useArrowSyntax: true,
					placeOpenBraceOnNewLine: false,
					explicitPublic: false,
					explicitPrivate: false,
					explicitNull: false
				},
				field: {
					argumentTypeHints: true,
					returnTypeHint: NonVoid,
					useArrowSyntax: false,
					placeOpenBraceOnNewLine: false,
					explicitPublic: false,
					explicitPrivate: false,
					explicitNull: false,
				}
			},
			imports: {
				style: Type,
				enableAutoImports: true
			},
			switch_: {
				parentheses: false
			}
		},
		exclude: ["zpp_nape"],
		postfixCompletion: {
			level: Full
		},
		importsSortOrder: AllAlphabetical,
		maxCompletionItems: 1000,
		renameSourceFolders: ["src", "Source", "test", "tests"]
	};
}

class Context {
	public final config:Configuration;
}

class Configuration {
	static final DefaultUserSettings:UserConfig = {
		enableCodeLens: false,
		enableDiagnostics: true,
		enableServerView: false,
		enableSignatureHelpDocumentation: true,
		diagnosticsPathFilter: "${workspaceRoot}",
		displayPort: null,
		buildCompletionCache: true,
		enableCompletionCacheWarning: true,
		useLegacyCompletion: false,
		codeGeneration: {
			functions: {
				anonymous: {
					argumentTypeHints: false,
					returnTypeHint: Never,
					useArrowSyntax: true,
					placeOpenBraceOnNewLine: false,
					explicitPublic: false,
					explicitPrivate: false,
					explicitNull: false
				},
				field: {
					argumentTypeHints: true,
					returnTypeHint: NonVoid,
					useArrowSyntax: false,
					placeOpenBraceOnNewLine: false,
					explicitPublic: false,
					explicitPrivate: false,
					explicitNull: false,
				}
			},
			imports: {
				style: Type,
				enableAutoImports: true
			},
			switch_: {
				parentheses: false
			}
		},
		exclude: ["zpp_nape"],
		postfixCompletion: {
			level: Full
		},
		importsSortOrder: AllAlphabetical,
		maxCompletionItems: 1000,
		renameSourceFolders: ["src", "Source", "test", "tests"]
	};

	@:nullSafety(Off) public var user(default, null):UserConfig;
}
