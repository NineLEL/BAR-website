# Automated tests

Zero-dependency `node:test` suite (Node.js 22+). All tests use temporary directories or stubbed `fetch` and never touch live `tweaks/state.json`.

## Commands

```sh
npm test             # full suite (node --test)
npm run check        # syntax-check JS files
npm run verify       # check + full suite

npm run test:pure    # app-pure.js codec, minifier, packer, slot rules
npm run test:client  # app-library.js HTTP/static client
npm run test:server  # isolated HTTP/API/static server tests
npm run test:tweaks  # tweak pack size, BAR unit sources, squad metadata, Lua runtime
```

## Suite map

| File | Coverage |
|---|---|
| `tests/pure.test.js` | Base64, Lua minifier/prettifier, 30-slot commands & resets, tweakunits merge/split, duplicate detection, chunk planning, `autoPack`. |
| `tests/library-client.test.js` | `app-library.js` fetch, toggle, error handling, and static `library.json` fallback. |
| `tests/server.test.js` | Isolated HTTP API, toggle persistence, corrupt-state recovery, path traversal and static hardening. |
| `tests/pages-build.test.js` | Static Pages build output and deterministic `library.json` generation. |
| `tests/tweaks.test.js` | All `tweaks/defs` and `tweaks/units` packability (≤16,384 chars), BAR unit source names, RaptorX/ScavX squad metadata, and optional Lua runtime checks (`tests/raptor-minibosses.lua`, `tests/player-mega-land-pack.lua`). |

See [`manual-checklist.md`](./manual-checklist.md) for manual browser/in-game checks.
