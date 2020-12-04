# Haxe refactoring

a work-in-progress refactoring tool for Haxe code.

CAUTION: Make sure you have backups before performing any refactor operation!

Note: refactoring uses static code analysis to figure out what places to change in a refactoring operation. if you make heavy use of type inference you might end up with compile errors.

## features

* move a file to a different package
* rename an import alias
* rename a type
* rename a function parameter
* rename a local var
* rename a local function
* remame a case capture
* rename module level statics
* rename interface fields

## usage

```bash
Haxe Refactor 1.0.0
[-s | --source] <path> : file or directory with .hx files (multiple allowed)
[-l] <location>        : location (path + filename and offset from beginning of file) of identifier to refactor - <src/pack/Filename.hx@123>
[-n] <newName>         : new name for all occurences of identifier
[-x]                   : perform refactoring operations
[--i-have-backups]     : you have a backup and you really, really want to refactor
[-h | --help]          : display list of options
```

### dry run

`node bin/refactor.js -s src -l path/pack/FileName.hx@600 -n newName`

### danger zone

`node bin/refactor.js -s src -l path/pack/FileName.hx@600 -n newName -x --i-have-backups`

## compile

```bash
npm install
lix download
haxe build.hxml
```
