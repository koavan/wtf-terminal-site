#!/usr/bin/env bash
# Build the whole site into site/: the landing page at / and the manual at /docs/.
# Usage: scripts/build.sh [path-to-wtf-terminal-checkout]
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

scripts/sync-manual.sh ${1:+"$1"}

rm -rf site
"${MKDOCS:-mkdocs}" build --strict --quiet -d site/docs
cp -R landing/. site/

version="$(cat docs/.version)"
sed -i.bak "s/@VERSION@/$version/g" site/index.html
rm -f site/index.html.bak
if grep -q '@VERSION@' site/index.html; then echo "unreplaced @VERSION@ in site/index.html" >&2; exit 1; fi
echo "built site/ for wtf $version"
