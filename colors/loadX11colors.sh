#!/usr/bin/env bash
set -euo pipefail


tmpdir=$(mktemp -d)

wget -O "$tmpdir/oscolor.c" "https://gitlab.freedesktop.org/xorg/xserver/-/raw/master/os/oscolor.c"

# sed -n '/^static const BuiltinColor/,${p;/^\}\;/q}' "$tmpdir/oscolor.c"
# sed -n '/^static const BuiltinColor/,/^\}\;/{/^s/d; /^}/d; /\{\([0-9]+\)\, \([0-9]+\)\, \([0-9]+\)\}.+\/\* ([a-zA-Z0-9 ]+) \*\//p\1 \2 \3\,\4;}' "$tmpdir/oscolor.c"
sed -n '/^static const BuiltinColor/,/^\}\;/{/^s/d; /^}/d; s/^ *{\([0-9]*\), \([0-9]*\), \([0-9]*\).*}, *\/\* \(.*\) \*\//\4,\1 \2 \3/p;}' "$tmpdir/oscolor.c" > "$(dirname $0)/X11.csv"

rm -r "$tmpdir"
