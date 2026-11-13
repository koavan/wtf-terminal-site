#!/usr/bin/env bash
# Copy the wtf-terminal manual into docs/manual/ and write the current version.
# Usage: scripts/sync-manual.sh [path-to-wtf-terminal-checkout]
# Default is the sibling checkout ../wtf-terminal.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
src="${1:-$root/../wtf-terminal}"

if [ ! -d "$src/manual" ]; then
  echo "no manual/ in $src (pass the wtf-terminal checkout as the first argument)" >&2
  exit 1
fi

rm -rf "$root/docs/manual"
mkdir -p "$root/docs/manual"
cp "$src"/manual/*.md "$root/docs/manual/"

# The in-app manual links to other topics as (#topic). On the website each
# topic is its own page, so rewrite those to (topic.md) when that page exists.
for f in "$root"/docs/manual/*.md; do
  for t in $(grep -o '](#[a-z0-9-]*)' "$f" | sed 's/^](#//; s/)$//' | sort -u); do
    if [ -f "$root/docs/manual/$t.md" ]; then
      sed -i.bak "s/](#$t)/]($t.md)/g" "$f"
    fi
  done
  rm -f "$f.bak"
done

# Expand {{cmd:…}}, {{key:…}} and {{mac:…|other:…}} using the app's own registries.
python3 "$root/scripts/expand_manual.py" "$src" "$root/docs/manual"

tr -d '[:space:]' < "$src/VERSION" > "$root/docs/.version"
echo "synced $(ls "$root/docs/manual" | wc -l | tr -d ' ') pages, version $(cat "$root/docs/.version")"
