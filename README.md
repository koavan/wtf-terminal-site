# wtf-terminal-site

Website for [wtf-terminal](https://github.com/koavan/wtf-terminal).

- `landing/`: the hand-written landing page (plain HTML/CSS, no build step), served at `/`.
- `docs/` + `mkdocs.yml`: the manual, built with MkDocs Material and served at `/docs/`.

The manual pages are not stored here. They are copied from `manual/` in the
wtf-terminal repo at build time, so that repo stays the single source of truth.

## Preview locally

```sh
python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
MKDOCS=.venv/bin/mkdocs scripts/build.sh   # uses ../wtf-terminal; writes site/
python3 -m http.server -d site 8000        # landing at /, manual at /docs/
# live-edit the manual only:  scripts/sync-manual.sh && .venv/bin/mkdocs serve
```

## Deploy

The site is served from https://wtf-terminal.in (S3 behind CloudFront, managed
with OpenTofu in `infra/`). Pushing does not deploy; run:

```sh
MKDOCS=.venv/bin/mkdocs scripts/deploy.sh --build   # build, sync to S3, invalidate CloudFront
```

The manual is pulled from wtf-terminal's `manual/` at build time, so redeploy
after changing it there. See `infra/` for the AWS setup.

## License

[MIT](LICENSE)
