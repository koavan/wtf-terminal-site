# wtf-terminal-site

Website for [wtf-terminal](https://github.com/koavan/wtf-terminal), built with MkDocs Material.

The manual pages are not stored here. They are copied from `manual/` in the
wtf-terminal repo at build time, so that repo stays the single source of truth.

## Preview locally

```sh
python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
scripts/sync-manual.sh            # uses ../wtf-terminal
.venv/bin/mkdocs serve
```

## Deploy

Pushes to `main` build and publish to GitHub Pages. wtf-terminal also triggers
a rebuild (`repository_dispatch`, type `manual-updated`) when `manual/` changes.
