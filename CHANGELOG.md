# Version history

## dev branch / next version (2.x.x)

## 2.4.0 (2024-11-)

- added invalidateFile / removeFile to allow rescan in case of file changes or deletion
- added support for create and delete file operations as edits
- changed Refactor class to Rename
- changed getFullModulName call to fullModuleName property
- fixed type name renaming not changing in use locations

## 2.3.1 (2024-11-01)

- fixed classification of parameters in arrow functions
- fixed discovery of vars in pattern extraction, fixes [#11](https://github.com/HaxeCheckstyle/haxe-rename/issues/11)

## 2.3.0 (2024-10-28)

- added file reader interface
- fixed discovery of identifiers in callback functions, fixes [#10](https://github.com/HaxeCheckstyle/haxe-rename/issues/10)

## 2.2.3 (2024-09-22)

- fixed package rename when identifier has multiple matches in folder structure, fixes [#3](https://github.com/HaxeCheckstyle/haxe-rename/issues/3)
- fixed failing to rename local symbol, fixes [#4](https://github.com/HaxeCheckstyle/haxe-rename/issues/4)
- fixed failing to rename simple public symbols, fixes [#5](https://github.com/HaxeCheckstyle/haxe-rename/issues/5)
- fixed crash on string interpolation, fixes [#6](https://github.com/HaxeCheckstyle/haxe-rename/issues/6)
- fixed crash when parsing a return macro @:pos, fixes [#8](https://github.com/HaxeCheckstyle/haxe-rename/issues/8)
- fixed crash with array comprehension, fixes [#9](https://github.com/HaxeCheckstyle/haxe-rename/issues/9)

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
