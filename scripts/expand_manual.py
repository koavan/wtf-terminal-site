#!/usr/bin/env python3
"""Expand the in-app manual's tokens into plain Markdown for the website.

The app expands these at run time from its command registries; this reads the
same registries so the website shows the same names and shortcuts:

    {{cmd:id}}                        -> command name and its shortcuts
    {{key:id}}                        -> just the shortcuts
    {{mac:A|other:B}}                 -> A, with the Linux wording noted

Usage: expand_manual.py <wtf-terminal checkout> <dir of .md pages to rewrite>
"""
import re
import sys
from pathlib import Path

src = Path(sys.argv[1])
pages = Path(sys.argv[2])

# Linux: cmd("id", "Title", "Ctrl+Shift+T")
linux = {}
for m in re.finditer(r'cmd\("([\w.]+)",\s*"([^"]*)",\s*"([^"]*)"\)',
                     (src / "internal/uicore/keymap.go").read_text()):
    linux[m.group(1)] = (m.group(2), m.group(3))

# macOS: cmd("Title", "id", "r", [.command, .shift])
MODS = {"control": "⌃", "option": "⌥", "shift": "⇧", "command": "⌘"}
KEYS = {"\\t": "Tab", "\\r": "Return", " ": "Space", "\\u{1B}": "Esc",
        "[": "[", "]": "]", ",": ",", ".": ".", "/": "/", "=": "=", "-": "-"}
mac = {}
for m in re.finditer(r'cmd\("([^"]*)",\s*"([\w.]+)"(?:,\s*"([^"]*)")?(?:,\s*\[([^\]]*)\])?',
                     (src / "macos/Sources/Wtf/main.swift").read_text()):
    title, cid, key, mods = m.groups()
    if not key:
        mac[cid] = (title, "")
        continue
    mset = {x.strip().lstrip(".") for x in (mods or ".command").split(",") if x.strip()}
    glyphs = "".join(MODS[k] for k in ("control", "option", "shift", "command") if k in mset)
    mac[cid] = (title, glyphs + KEYS.get(key, key.upper()))

missing = set()


def kbd(s):
    return f"<kbd>{s}</kbd>"


def shortcuts(cid):
    out = []
    if mac.get(cid, ("", ""))[1]:
        out.append(kbd(mac[cid][1]))
    if linux.get(cid, ("", ""))[1]:
        keys = linux[cid][1].replace("Comma", ",")
        out.append(kbd(keys))
    return out


def cmd_sub(m):
    kind, cid = m.group(1), m.group(2)
    if cid not in mac and cid not in linux:
        missing.add(cid)
        return m.group(0)
    keys = shortcuts(cid)
    both = len(keys) == 2
    keytxt = " / ".join(keys) if both else (keys[0] if keys else "")
    if kind == "key":
        return keytxt or "(no shortcut)"
    title = (mac.get(cid) or linux.get(cid))[0].rstrip("…")
    return f"**{title}**" + (f" ({keytxt})" if keytxt else "")


def plat_sub(m):
    a, b = m.group(1).strip(), m.group(2).strip()
    return a if a == b else f"{a} (Linux: {b})"


for f in sorted(pages.glob("*.md")):
    text = f.read_text()
    # Leave fenced code blocks alone; expand everywhere else.
    parts = re.split(r"(```.*?```)", text, flags=re.S)
    for i in range(0, len(parts), 2):
        s = re.sub(r"\{\{(cmd|key):([\w.]+)\}\}", cmd_sub, parts[i])
        s = re.sub(r"\{\{mac:([^|}]*)\|other:([^}]*)\}\}", plat_sub, s)
        parts[i] = s
    f.write_text("".join(parts))

if missing:
    print("unresolved command ids: " + ", ".join(sorted(missing)), file=sys.stderr)
    sys.exit(1)
