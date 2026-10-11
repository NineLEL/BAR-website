# BAR Tweak Packer

A small web app for browsing and packaging Beyond All Reason (BAR) tweaks.

## Run locally

Requires Node.js 22 or newer. Install no dependencies; start the local server with:

```sh
npm start
```

The server binds to `127.0.0.1` and is intended for local use only. Do not expose it to an untrusted network: its library toggle API writes local state and is not an authenticated service.

For static hosting such as GitHub Pages, build the publishable site with:

```sh
npm run build:pages
```

The generated `dist/` directory contains the site assets and published tweak library, not the Node server or repository files.

## Verify

Run tests relevant to your changes against the remote base branch:

```sh
npm run test:changed -- --base origin/main
# or
TEST_BASE_REF=origin/main npm run test:changed
```

The script selects relevant tests automatically. Broad or unknown changed paths fall back to the full suite. If the diff is empty or the base is invalid, it stops; pass `--all` to run the full suite instead. To explicitly run the full test suite and all verification checks, use:

```sh
npm test
npm run verify
```

## Credits

- [ScavX](https://pixelalien0.github.io/ScavX/) — scavenger tweak content and inspiration.
- [NuttyB](https://github.com/nuttyb-community/nuttyb) — community tweak content.
