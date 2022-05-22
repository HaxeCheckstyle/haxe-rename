# Version history

## dev branch / next version (2.x.x)

## 2.2.2 (2022-05-23)

- fixed bug in readBlock passing incorrect child token

## 2.2.1 (2022-05-20)

- fixed local var scope

## 2.2.0 (2022-05-03)

- added canRename API call

## 2.1.4 (2022-05-02)

- fixed handling of star imports

## 2.1.3 (2022-05-01)

- fixed package renaming

## 2.1.2 (2022-04-25)

- fixed handling of loop iterator shadowing, fixes [vshaxe/vshaxe#136](https://github.com/vshaxe/vshaxe/issues/136)

## 2.1.1 (2022-04-23)

- fixed identifier collection

## 2.1.0 (2022-04-19)

- added support for handling shadowed identifiers during local var/param rename
- fixed detecting local var shadows when renaming a field

## 2.0.0 (2022-04-16)

- added external typer interface to utilise type information from Haxe compiler ([#2](https://github.com/HaxeCheckstyle/haxe-rename/issues/2))
- refactored codebase to use asynchronous promises ([#2](https://github.com/HaxeCheckstyle/haxe-rename/issues/2))
- dropped non JS support in favour of using js.lib.Promise ([#2](https://github.com/HaxeCheckstyle/haxe-rename/issues/2))

## 1.0.0 (2020-12-07)

- initial version with built-in "type-guessing"
