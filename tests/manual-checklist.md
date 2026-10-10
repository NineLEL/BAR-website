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
| `app-pure.js`, `tests/pure.test.js` | The production pure module is imported directly: Base64, Lua minify/prettify, decode command parsing, slot/packing boundaries, reset commands, fixtures, and perf W1/W2/W4. |
| `app-library.js`, `tests/library-client.test.js` | Fetch/toggle API behavior with a restored, stubbed `fetch`; no live network. |
| `tests/server.test.js` | Temporary tweak root + ephemeral port: API, toggle validation/persistence, path safety, static files, corrupt temporary state, update notifications, and perf W3. It snapshots live `state.json` bytes solely to guard against writes, never reads its values. |
| `tests/default-enabled.test.js`, `tests/fixtures/default-enabled-tweaks.json` | Validates the test-owned expected default-enable profile. This avoids making feature/source tests depend on user toggle preferences in live `state.json`. |
| `tests/tweak-srcs.test.js`, `tests/scavx-release.test.js`, `tests/scavx-hardening.test.js`, `tests/raptor-minibosses.test.js` | Lua source contracts, clone/unit references, packability, release comparisons, and optional executable Lua checks. |

The server tests create configured instances with `createServer({ root,
tweaksDir })`; they bind only to an ephemeral loopback port. Pure logic is
tested through the same `app-pure.js` module used by the browser. The test suite
does not alter live tweak files or user state.

## Manual DOM checklist (cannot be automated without jsdom — forbidden dep)

Do these against `node server.js` + `http://localhost:8080` before release:

- [ ] Page loads with no console errors; both tabs (tweakdefs/tweakunits) render 10 slots.
- [ ] **Server library**: drop a `.lua` in `tweaks/defs/`, hit Reload — appears with char count; untick disables (persists in `tweaks/state.json`, file kept); Preview toggles source view.
- [ ] **Packer inputs**: Add/Remove/Clear snippet; typing re-renders slots live; `locked` server snippets are read-only.
- [ ] **Limits**: default 16384; over-limit slot shows red OVER LIMIT; custom `#charLimit` < 1000 falls back to 16384.
- [ ] **Auto-pack**: several snippets pack into fewer slots; Copy buttons write the full `!bset …` command (check length + paste into BAR).
- [ ] **Copy-all / decode**: Copy-all joins slot commands with `\n`; Decode tab roundtrips a copied command back to the same Lua.
- [ ] **Reset all**: the global button copies 20 commands covering tweakunits slots 0–9 and tweakdefs slots 0–9.
- [ ] **Offline**: stop `server.js` → library shows the "Server library offline" hint; manual snippets keep working.
- [ ] **Unicode**: paste CJK/emoji Lua → slot OK, decode roundtrips byte-identical.
- [ ] Cross-browser spot-check (Chrome + Firefox): copy-to-clipboard works or falls back with a toast.
