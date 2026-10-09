# BAR Tweak Packer — how to run + manual DOM checklist

Automated coverage is `node:test` only (zero dependencies, Node ≥ 22).

## Commands (no global installs)

```sh
node --version        # need v22+
npm test              # node --test tests/      — full suite, must be < 5s
npm run check         # node --check on app.js, server.js, all test files
npm run verify        # check + test (the gate before any change ships)
node --test tests/pure.test.js    # fast logic slice only
node --test tests/server.test.js  # isolated API/static slice only
PERF_STRICT=1 npm test            # also FAIL on perf-budget overruns
                                  # (default: budgets only warn)
```

## What the robots cover

| File | Covers |
|---|---|
| `tests/helpers/loadPure.js` | Extracts the 7 pure fns + `MAX_SLOTS` from `app.js` via `fs`+`vm` (balanced-brace slice — the whole file is NEVER eval'd because the DOM section runs on load) |
| `tests/pure.test.js` | b64 roundtrip (UTF-8/emoji/CJK, URL-safe, whitespace, padding, throws); `luaMinify` comments-vs-strings; slot addressing; `buildCommand`; `mergeTweakUnits`; autopack 16384 boundary (exact-fit / one-over); collect/decode parser; `getLimit` 16384 fallback; minifier-vs-`tests/fixtures/*.lua` (copies of live tweaks — never the live files); perf W1/W2/W4 |
| `tests/server.test.js` | Temp-`BAR_ROOT` + ephemeral port, never the live `./tweaks`/`state.json`: `GET /api/tweaks` (shape, query ignored), toggle 200/400-matrix/405, `safeName`/traversal matrix, static 403/404, corrupt-`state.json` → all-enabled, 1 MB abort resilience, XSS/envelope guards, GAP-1/2/3 pins, perf W3 list-200 |

`server.js` carries one minimal testability refactor (env overrides
`BAR_ROOT`/`BAR_TWEAKS_DIR`, binds only under `require.main === module`,
exports its handlers). Behaviour without the env vars is unchanged.
`app.js`, `index.html`, `styles.css`, live `tweaks/` are untouched.

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
