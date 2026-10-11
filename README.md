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

```sh
npm run verify
```

## Credits

- [ScavX](https://pixelalien0.github.io/ScavX/) — scavenger tweak content and inspiration.
- [NuttyB](https://github.com/nuttyb-community/nuttyb) — community tweak content.
