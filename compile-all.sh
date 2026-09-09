#!/usr/bin/env bash
set -euo pipefail

src="./fennel/src"
out="./lua/generated"
mkdir -p "$out"

for f in "$src"/*.fnl; do
    [ -e "$f" ] || continue
    name="$(basename "$f" .fnl)"
    echo "compiling $f -> $out/$name.lua"
    fennel --compile "$f" > "$out/$name.lua"
done
