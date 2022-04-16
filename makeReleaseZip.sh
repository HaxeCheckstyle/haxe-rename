#!/bin/bash -e

npm install
npx lix download
npx lix use haxe nightly

haxe test.hxml

rm -f rename.zip
zip -9 -r -q rename.zip src haxelib.json hxformat.json checkstyle.json package.json README.md CHANGELOG.md LICENSE.md
