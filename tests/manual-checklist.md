# BAR Tweak Packer — how to run + manual DOM checklist

Automated coverage is `node:test` only (zero dependencies, Node ≥ 22).

## Commands (no global installs)

```sh
node --version        # need v22+
npm test              # node --test — full suite
npm run check         # syntax-check all production and test JavaScript files
npm run verify        # check + test (the gate before any change ships)
npm run test:pure     # direct app-pure.js logic tests
npm run test:client   # app-library.js with a stubbed fetch boundary
npm run test:server   # isolated API/static integration tests
npm run test:tweaks   # data/source contract tests
# Set PERF_STRICT=1 before a command to fail on performance-budget overruns.
# PowerShell example: $env:PERF_STRICT="1"; npm test
```

## What the robots cover

| File | Covers |
|---|---|
| `app-pure.js`, `tests/pure.test.js` | Base64, Lua minify/prettify, 30-slot commands/resets, merge/split, chunk planning, and `autoPack`. |
| `app-library.js`, `tests/library-client.test.js` | Fetch/toggle API behavior and static `library.json` fallback with stubbed `fetch`. |
| `tests/server.test.js` | Temporary tweak root + ephemeral port: API, toggle persistence, path traversal, and static hardening. |
| `tests/pages-build.test.js` | Static Pages build output and `library.json` generation. |
| `tests/tweaks.test.js` | Tweak pack size limits, BAR clone sources, RaptorX/ScavX squad metadata, and optional Lua runtime checks. |

The server tests create configured instances with `createServer({ root,
tweaksDir })`; they bind only to an ephemeral loopback port. Pure logic is
tested through the same `app-pure.js` module used by the browser. The test suite
does not alter live tweak files or user state.

## Manual DOM checklist (cannot be automated without jsdom — forbidden dep)

Do these against `node server.js` + `http://localhost:8080` before release:

- [ ] Page loads with no console errors; both tabs (tweakdefs/tweakunits) render 30 slots.
- [ ] **Server library**: drop a `.lua` in `tweaks/defs/`, hit Reload — appears with char count; untick disables (persists in `tweaks/state.json`, file kept); Preview toggles source view.
- [ ] **Packer inputs**: Add/Remove/Clear snippet; typing re-renders slots live; `locked` server snippets are read-only.
- [ ] **Limits**: default 16384; over-limit slot shows red OVER LIMIT; custom `#charLimit` < 1000 falls back to 16384.
- [ ] **Auto-pack**: several snippets pack into fewer slots; Copy buttons write the full `!bset …` command (check length + paste into BAR).
- [ ] **Copy-all / decode**: Copy-all joins slot commands with `\n`; Decode tab roundtrips a copied command back to the same Lua.
- [ ] **Reset all**: the global button copies 60 commands covering tweakunits slots 0–29 and tweakdefs slots 0–29.
- [ ] **Offline**: stop `server.js` → library shows the "Server library offline" hint; manual snippets keep working.
- [ ] **Unicode**: paste CJK/emoji Lua → slot OK, decode roundtrips byte-identical.
- [ ] Cross-browser spot-check (Chrome + Firefox): copy-to-clipboard works or falls back with a toast.
