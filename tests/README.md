# tests/ — single-writer verify system

Fast (`< 5 s`), isolated, zero-dependency suite for the BAR Tweak Packer.
How to run and what is manual lives in [`manual-checklist.md`](./manual-checklist.md).

```
tests/
├── helpers/loadPure.js   # slice the 7 pure fns out of app.js (fs+vm, never whole-file eval)
├── pure.test.js          # codec · minifier · slots · merge · autopack boundary · fixtures · W1/W2/W4
├── server.test.js        # API + static contracts on a temp BAR_ROOT / ephemeral port · W3
├── fixtures/             # COPIES of live tweaks/*.lua (byte snapshots, never the live files)
└── manual-checklist.md   # run commands + DOM checklist (jsdom forbidden)
```

Rules: `node:test` + `node:assert/strict` only. Temp dirs / ephemeral ports.
Never POST to a real server, never touch live `tweaks/` or `state.json`
(`server.test.js` snapshots the live `state.json` and asserts it is
byte-identical afterwards). Perf budgets warn by default; `PERF_STRICT=1`
turns overruns into failures.
