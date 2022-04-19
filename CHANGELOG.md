# Version history

## dev branch / next version (2.x.x)

## 2.1.0 (2022-04-19)

- added support for handling shadowed identifiers during local var/param rename
- fixed detecting local var shadows when renaming a field

## 2.0.0 (2022-04-16)

- added external typer interface to utilise type information from Haxe compiler ([#2](https://github.com/HaxeCheckstyle/haxe-rename/issues/2))
- refactored codebase to use asynchronous promises ([#2](https://github.com/HaxeCheckstyle/haxe-rename/issues/2))
- dropped non JS support in favour of using js.lib.Promise ([#2](https://github.com/HaxeCheckstyle/haxe-rename/issues/2))

## 1.0.0 (2020-12-07)

- initial version with built-in "type-guessing"
