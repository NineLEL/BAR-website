# Automated tests

The BAR Tweak Packer uses Node's built-in `node:test` and
`node:assert/strict`. Node.js 22 or newer is required; there are no package
dependencies or install steps. The suite is deterministic and uses temporary
roots and stubbed network boundaries.

## Commands

```sh
node --version       # v22+
npm test             # complete suite (node --test)
npm run check        # syntax-check every production and test JavaScript file
npm run verify       # check + complete suite; CI/release gate

npm run test:pure    # app-pure.js logic, parsing, packing, and fixtures
npm run test:client  # app-library.js HTTP client with stubbed fetch
npm run test:server  # isolated HTTP/API/static-file integration tests
npm run test:tweaks  # source contracts, default-enable manifest, packability
```

Performance budgets in the pure and server tests warn by default. To make them
strict, set `PERF_STRICT=1` in the environment before running the desired
command (for example, PowerShell: `$env:PERF_STRICT="1"; npm test`).

## Suite map

| Files | Coverage |
|---|---|
| `tests/pure.test.js` | Direct imports from `app-pure.js`: UTF-8/Base64 edge cases, Lua minification/formatting, command parsing, slot boundaries, packing and duplicate detection, reset commands, fixture stability, and performance smoke budgets. |
| `tests/library-client.test.js` | `app-library.js` request contracts: cache behavior, JSON payloads, boolean toggles, bulk failures, and HTTP errors. `fetch` is stubbed; no network is used. |
| `tests/server.test.js` | Temporary `BAR_ROOT`/tweak directories and an ephemeral loopback port: API payloads, toggle validation/persistence, traversal and static responses, corrupt isolated state, oversized-body resilience, and update notification. It snapshots the user's `tweaks/state.json` bytes only as a no-write guard; test behavior never depends on its contents. |
| `tests/default-enabled.test.js`, `tests/tweak-srcs.test.js`, `tests/scavx-hardening.test.js`, `tests/scavx-release.test.js`, `tests/raptor-minibosses.test.js` | Lua source contracts, unit-name validity, gameplay invariants, pack-size limits, and runtime Lua coverage when a Lua executable is available. |
| `tests/fixtures/default-enabled-tweaks.json` | Test-owned expected default-enabled feature profile. It preserves enablement assertions without consulting user-editable `tweaks/state.json`. |
| `tests/fixtures/*.lua` | Small copied Lua examples for deterministic minifier and packer contracts. |
| `tests/manual-checklist.md` | Manual browser/engine checks that are outside the zero-dependency automated suite. |

The suite never writes to the working tree's `tweaks/state.json`. Source tests
read Lua definitions directly; their default enablement expectations come only
from the test-owned manifest. The server integration suite writes only under
temporary directories. Its optional runtime Lua test is skipped when Lua is not
installed; the source-level tests still run.

## Manual checks

See [`manual-checklist.md`](./manual-checklist.md) for UI and in-game checks.
