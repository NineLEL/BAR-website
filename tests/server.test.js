"use strict";
/* Server contract suite — isolated temp ROOT, ephemeral port, zero live writes.
 * It snapshots the real state.json bytes only as a no-write guard, never reads
 * its values, and never POSTs to a real server. Each server is explicitly
 * configured with createServer() and only binds when asked, so requiring
 * server.js is side-effect free.
 * Run: npm test  (or: node --test tests/server.test.js)
 */
const { describe, it, before, after } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("fs");
const http = require("http");
const os = require("os");
const path = require("path");

const REPO_ROOT = path.join(__dirname, "..");
const LIVE_STATE = path.join(REPO_ROOT, "tweaks", "state.json");
const SERVER_SRC = fs.readFileSync(path.join(REPO_ROOT, "server.js"), "utf8");

let liveStateSnapshot = null;

function freshServer() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "bar-packer-"));
  const tweaks = path.join(root, "tweaks");
  fs.writeFileSync(path.join(root, "index.html"), "<!doctype html><title>stub</title>");
  // Canary OUTSIDE the root: traversal must never leak it.
  const outside = path.join(path.dirname(root), "bar-canary-" + path.basename(root) + ".txt");
  fs.writeFileSync(outside, "CANARY-DO-NOT-SERVE");

  const srv = require("../server.js").createServer({ root: root, tweaksDir: tweaks });
  srv.ensureDirs();
  return { root, tweaks, outside, srv };
}

it("initializes a missing local state from tracked defaults", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "bar-packer-defaults-"));
  const tweaks = path.join(root, "tweaks");
  const defaults = { "defs/alpha.lua": false };
  fs.mkdirSync(tweaks, { recursive: true });
  fs.writeFileSync(path.join(tweaks, "state.defaults.json"), JSON.stringify(defaults));
  try {
    const srv = require("../server.js").createServer({ root, tweaksDir: tweaks });
    srv.ensureDirs();
    assert.deepEqual(JSON.parse(fs.readFileSync(path.join(tweaks, "state.json"), "utf8")), defaults);
  } finally {
    fs.rmSync(root, { recursive: true, force: true });
  }
});

function listen(srv) {
  return new Promise((resolve) => {
    const s = srv.server.listen(0, "127.0.0.1", () => resolve(s));
  });
}

function req(port, method, url, body, headers) {
  return new Promise((resolve, reject) => {
    const r = http.request(
      { host: "127.0.0.1", port, path: url, method, headers: headers || {} },
      (res) => {
        const chunks = [];
        res.on("data", (c) => chunks.push(c));
        res.on("end", () => resolve({ status: res.statusCode, headers: res.headers, body: Buffer.concat(chunks).toString("utf8") }));
      }
    );
    r.on("error", reject);
    if (body) r.write(body);
    r.end();
  });
}

const postToggle = (port, obj) =>
  req(port, "POST", "/api/tweaks/toggle", JSON.stringify(obj), { "Content-Type": "application/json" });

let box;      // isolated server box
let server;   // listening handle
let port;

before(async () => {
  liveStateSnapshot = fs.existsSync(LIVE_STATE) ? fs.readFileSync(LIVE_STATE, "utf8") : null;
  box = freshServer();
  fs.writeFileSync(path.join(box.tweaks, "defs", "alpha.lua"), "-- alpha\nlocal a = 1\n");
  fs.writeFileSync(path.join(box.tweaks, "units", "beta.lua"), "{ armpw = { metalcost = 10, }, }\n");
  server = await listen(box.srv);
  port = server.address().port;
});

after(async () => {
  if (server) await new Promise((resolve) => server.close(resolve));
  try { fs.rmSync(box.root, { recursive: true, force: true }); } catch {}
  try { fs.unlinkSync(box.outside); } catch {}
  // Guard: live state.json must be byte-identical (we never POST to it).
  const now = fs.existsSync(LIVE_STATE) ? fs.readFileSync(LIVE_STATE, "utf8") : null;
  assert.equal(now, liveStateSnapshot, "LIVE tweaks/state.json was modified by tests!");
});

describe("GET /api/tweaks contract", () => {
  it("200 + JSON shape {defs[],units[]} with name/enabled/chars/content", async () => {
    const r = await req(port, "GET", "/api/tweaks");
    assert.equal(r.status, 200);
    assert.match(r.headers["content-type"] || "", /application\/json/);
    const data = JSON.parse(r.body);
    assert.ok(Array.isArray(data.defs) && Array.isArray(data.units));
    const names = data.defs.map((f) => f.name);
    assert.ok(names.includes("alpha.lua"));
    const a = data.defs.find((f) => f.name === "alpha.lua");
    assert.equal(a.enabled, true);
    assert.equal(a.chars, a.content.length);
    assert.ok(a.content.includes("local a = 1"));
    assert.equal(data.units.find((f) => f.name === "beta.lua").enabled, true);
  });
  it("query string is ignored (still 200, same payload)", async () => {
    const a = await req(port, "GET", "/api/tweaks");
    const b = await req(port, "GET", "/api/tweaks?foo=bar&kind=defs");
    assert.equal(b.status, 200);
    assert.equal(b.body, a.body);
  });
  it("non-.lua files are not listed", async () => {
    fs.writeFileSync(path.join(box.tweaks, "defs", "notes.txt"), "hi");
    const r = await req(port, "GET", "/api/tweaks");
    assert.ok(!r.body.includes("notes.txt"));
    fs.unlinkSync(path.join(box.tweaks, "defs", "notes.txt"));
  });
  it("discovers Lua files in nested kind folders with relative names", async () => {
    const nested = path.join(box.tweaks, "defs", "economy", "late-game");
    fs.mkdirSync(nested, { recursive: true });
    fs.writeFileSync(path.join(nested, "mex.lua"), "-- nested mex\n");
    const r = await req(port, "GET", "/api/tweaks");
    const data = JSON.parse(r.body);
    assert.equal(data.defs.find((f) => f.name === "economy/late-game/mex.lua").content, "-- nested mex\n");
  });
});

describe("explicit server factory isolation", () => {
  it("creates independent configured servers without import-time filesystem or bind side effects", async () => {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), "bar-packer-isolated-"));
    const tweaks = path.join(root, "custom-library");
    let otherServer;
    try {
      const other = require("../server.js").createServer({ root: root, tweaksDir: tweaks });
      assert.deepEqual(other.getPaths(), {
        ROOT: root,
        TWEAKS_DIR: tweaks,
        STATE_FILE: path.join(tweaks, "state.json")
      });
      assert.equal(other.server.listening, false);
      assert.equal(fs.existsSync(tweaks), false, "factory construction must not create library files");

      other.ensureDirs();
      const file = path.join(tweaks, "defs", "isolated.lua");
      fs.writeFileSync(file, "-- second instance only\n");
      otherServer = await listen(other);
      const otherPort = otherServer.address().port;
      const response = await req(otherPort, "GET", "/api/tweaks");
      assert.equal(response.status, 200);
      assert.deepEqual(JSON.parse(response.body).defs.map((entry) => entry.name), ["isolated.lua"]);
      assert.ok(!JSON.parse((await req(port, "GET", "/api/tweaks")).body).defs.some((entry) => entry.name === "isolated.lua"));
    } finally {
      if (otherServer) await new Promise((resolve) => otherServer.close(resolve));
      fs.rmSync(root, { recursive: true, force: true });
    }
  });
});

describe("server library update logging", () => {
  it("logs when a tweak file changes while the watcher is running", async () => {
    const messages = [];
    const originalLog = console.log;
    let stopWatching;
    let timeout;
    let resolveLog;
    let rejectTimeout;
    const logged = new Promise((resolve) => { resolveLog = resolve; });
    const deadline = new Promise((_, reject) => { rejectTimeout = reject; });
    console.log = (message) => {
      messages.push(message);
      if (message.includes("Library updated")) resolveLog();
    };
    stopWatching = box.srv.watchLibraryUpdates(10);
    try {
      timeout = setTimeout(() => rejectTimeout(new Error("watcher did not report the file change within 1 second")), 1000);
      fs.appendFileSync(path.join(box.tweaks, "defs", "alpha.lua"), "-- changed\n");
      await Promise.race([logged, deadline]);
      assert.equal(messages.length, 1);
      assert.match(messages[0], /Library updated/);
    } finally {
      clearTimeout(timeout);
      stopWatching();
      console.log = originalLog;
    }
  });
});

describe("POST /api/tweaks/toggle — 200 happy path", () => {
  it("disables then re-enables; persists to TEMP state.json only", async () => {
    let r = await postToggle(port, { kind: "defs", name: "alpha.lua", enabled: false });
    assert.equal(r.status, 200);
    assert.equal(JSON.parse(r.body).ok, true);
    const st = JSON.parse(fs.readFileSync(path.join(box.tweaks, "state.json"), "utf8"));
    assert.equal(st["defs/alpha.lua"], false);

    let list = JSON.parse((await req(port, "GET", "/api/tweaks")).body);
    assert.equal(list.defs.find((f) => f.name === "alpha.lua").enabled, false);

    r = await postToggle(port, { kind: "defs", name: "alpha.lua", enabled: true });
    assert.equal(r.status, 200);
    list = JSON.parse((await req(port, "GET", "/api/tweaks")).body);
    assert.equal(list.defs.find((f) => f.name === "alpha.lua").enabled, true);
  });
  it("toggles a nested relative path and persists it independently", async () => {
    const nested = path.join(box.tweaks, "defs", "economy", "late-game");
    fs.mkdirSync(nested, { recursive: true });
    fs.writeFileSync(path.join(nested, "mex.lua"), "-- nested mex\n");
    const r = await postToggle(port, { kind: "defs", name: "economy/late-game/mex.lua", enabled: false });
    assert.equal(r.status, 200);
    const state = JSON.parse(fs.readFileSync(path.join(box.tweaks, "state.json"), "utf8"));
    assert.equal(state["defs/economy/late-game/mex.lua"], false);
  });
});

describe("POST /api/tweaks/toggle — 400 strict-match matrix", () => {
  const cases = [
    ["bad kind", { kind: "nope", name: "alpha.lua", enabled: true }],
    ["missing kind", { name: "alpha.lua", enabled: true }],
    ["traversal ../", { kind: "defs", name: "../server.js", enabled: true }],
    ["traversal nested", { kind: "defs", name: "a/../../x.lua", enabled: true }],
    ["absolute path", { kind: "defs", name: "/etc/passwd.lua", enabled: true }],
    ["windows drive", { kind: "defs", name: "C:\\evil.lua", enabled: true }],
    ["wrong extension", { kind: "defs", name: "evil.js", enabled: false }],
    ["no extension", { kind: "defs", name: "evil", enabled: true }],
    ["empty name", { kind: "defs", name: "", enabled: true }],
    ["missing name", { kind: "defs", enabled: true }],
    ["enabled not boolean (string)", { kind: "defs", name: "alpha.lua", enabled: "true" }],
    ["enabled not boolean (number)", { kind: "defs", name: "alpha.lua", enabled: 1 }],
    ["missing enabled", { kind: "defs", name: "alpha.lua" }],
    ["null body fields", { kind: null, name: null, enabled: null }],
  ];
  for (const [label, payload] of cases) {
    it("400 for " + label, async () => {
      const r = await postToggle(port, payload);
      assert.equal(r.status, 400, label + " → " + r.status);
      assert.equal(r.body, "bad request");
    });
  }
  it("400 on malformed JSON body (no crash, no 500)", async () => {
    const r = await req(port, "POST", "/api/tweaks/toggle", "{not json", { "Content-Type": "application/json" });
    assert.equal(r.status, 400);
  });
  it("400 responses never echo untrusted input", async () => {
    const evil = "../../EVILPAYLOAD123.lua";
    const r = await postToggle(port, { kind: "defs", name: evil, enabled: true });
    assert.equal(r.status, 400);
    assert.ok(!r.body.includes("EVILPAYLOAD123"), "error envelope leaked input: " + r.body);
  });
});

describe("405 method handling", () => {
  it("GET /api/tweaks/toggle → 404 (falls through to static, as coded)", async () => {
    assert.equal((await req(port, "GET", "/api/tweaks/toggle")).status, 404);
  });
  it("POST /api/tweaks (wrong path) → 405", async () => {
    const r = await req(port, "POST", "/api/tweaks", "{}", { "Content-Type": "application/json" });
    assert.equal(r.status, 405);
  });
  it("PUT /api/tweaks/toggle → 405", async () => {
    const r = await req(port, "PUT", "/api/tweaks/toggle", "{}", { "Content-Type": "application/json" });
    assert.equal(r.status, 405);
  });
  it("DELETE / → 405", async () => {
    assert.equal((await req(port, "DELETE", "/")).status, 405);
  });
});

describe("safeName unit matrix", () => {
  const good = ["a.lua", "my tweak 1.LUA", "t3-t4-mex_all.factions.lua", "x.y_z-1 .lua", "UPPER.Lua", "air/late game.lua"];
  for (const n of good) {
    it("accepts " + JSON.stringify(n), () => assert.equal(box.srv.safeName(n), n));
  }
  const bad = ["../x.lua", "..\\x.lua", "a/../../x.lua", "/abs.lua", "", ".lua", "x.js", "x.lua ", " x.lua".replace(" ", "\0"), "é.lua", "a".repeat(300) + ".exe", null, undefined, 42, {}, "x.LUA.bak"];
  for (const n of bad) {
    it("rejects " + JSON.stringify(n), () => assert.equal(box.srv.safeName(n), null));
  }
});

describe("serveStatic traversal guard", () => {
  it("serves in-root files (200)", async () => {
    const r = await req(port, "GET", "/index.html");
    assert.equal(r.status, 200);
    assert.ok(r.body.includes("stub"));
  });
  it("403 on percent-encoded escape that resolves outside ROOT", async () => {
    const canary = path.basename(box.outside);
    const r = await req(port, "GET", "/..%2f..%2f" + canary);
    assert.ok(r.status === 403 || r.status === 404, "expected 403/404, got " + r.status);
    assert.ok(!r.body.includes("CANARY-DO-NOT-SERVE"), "traversal leaked outside file!");
  });
  it("403 on double-encoded / nested dotdot", async () => {
    for (const p of ["/%2e%2e/%2e%2e/x", "/a/%2e%2e/%2e%2e/%2e%2e/x", "/..%5c..%5cx"]) {
      const r = await req(port, "GET", p);
      assert.ok([403, 404].includes(r.status), p + " → " + r.status);
    }
  });
  it("404 on missing file (no leak, no 500)", async () => {
    const r = await req(port, "GET", "/does-not-exist-12345.html");
    assert.equal(r.status, 404);
    assert.equal(r.body, "not found");
  });
});

describe("corrupt state.json fallback", () => {
  it("garbage state file → 200 with all entries enabled ({} fallback)", async () => {
    const sf = path.join(box.tweaks, "state.json");
    const prev = fs.readFileSync(sf, "utf8");
    fs.writeFileSync(sf, "NOT JSON{{{corrupt");
    try {
      const r = await req(port, "GET", "/api/tweaks");
      assert.equal(r.status, 200);
      const data = JSON.parse(r.body);
      for (const f of data.defs.concat(data.units)) assert.equal(f.enabled, true, f.name);
    } finally {
      fs.writeFileSync(sf, prev);
    }
  });
  it("toggle after corruption recreates a valid state file", async () => {
    const sf = path.join(box.tweaks, "state.json");
    fs.writeFileSync(sf, "garbage!!");
    const r = await postToggle(port, { kind: "units", name: "beta.lua", enabled: false });
    assert.equal(r.status, 200);
    const st = JSON.parse(fs.readFileSync(sf, "utf8"));
    assert.equal(st["units/beta.lua"], false);
    await postToggle(port, { kind: "units", name: "beta.lua", enabled: true });
  });
});

describe("oversized body / abort resilience", () => {
  it("1MB+ body destroys the socket; server stays alive for the next GET", async () => {
    const big = "x".repeat(1_100_000);
    let outcome = "unknown";
    try {
      const r = await req(port, "POST", "/api/tweaks/toggle", big, { "Content-Type": "application/json" });
      outcome = "responded:" + r.status;
    } catch (e) {
      outcome = "socket-destroyed:" + (e.code || e.message);
    }
    assert.ok(
      outcome.startsWith("socket-destroyed") || outcome.startsWith("responded:400"),
      "unexpected outcome: " + outcome
    );
    // Server must still serve afterwards (no crash, no wedged state).
    const r2 = await req(port, "GET", "/api/tweaks");
    assert.equal(r2.status, 200);
  });
});

describe("XSS / envelope guards (as-coded behaviour)", () => {
  it("API never serves HTML content-type (no script execution context)", async () => {
    const r = await req(port, "GET", "/api/tweaks");
    assert.ok(!(r.headers["content-type"] || "").includes("text/html"));
  });
  it("toggle success echoes only {ok:true}, never the filename", async () => {
    const r = await postToggle(port, { kind: "defs", name: "alpha.lua", enabled: true });
    assert.equal(r.body, JSON.stringify({ ok: true }));
  });
  it("app.js forbids innerHTML with untrusted data (grep guard)", () => {
    const app = fs.readFileSync(path.join(REPO_ROOT, "app.js"), "utf8");
    const hits = app.split("\n").filter((ln) => ln.includes("innerHTML"));
    // As coded, innerHTML is used only for static markup and numeric counts,
    // while all untrusted file content flows through textContent. Pin that:
    for (const ln of hits) {
      assert.ok(
        !/\b(content|b64|cmd|min)\b|\bf\.name\b|decodeOutput/.test(ln),
        "suspicious innerHTML with untrusted data: " + ln.trim()
      );
    }
    assert.ok(app.includes("pre.textContent = f.content"), "file content must use textContent");
  });
});

describe("KNOWN GAPS pinned (fail loudly when fixed — update these tests)", () => {
  it("GAP-1: server binds all interfaces (no explicit host) — documents 0.0.0.0 exposure", () => {
    assert.ok(
      /server\.listen\(port\)/.test(SERVER_SRC),
      "server no longer binds bare PORT — GAP-1 may be fixed; update this test + docs"
    );
  });
  it("GAP-2: /api/tweaks returns FULL file contents unbounded — pins current behaviour", async () => {
    const big = "-- big\n" + ("local pad = '" + "x".repeat(200) + "'\n").repeat(20);
    fs.writeFileSync(path.join(box.tweaks, "defs", "big.lua"), big);
    try {
      const r = await req(port, "GET", "/api/tweaks");
      const data = JSON.parse(r.body);
      assert.equal(data.defs.find((f) => f.name === "big.lua").content, big);
    } finally {
      fs.unlinkSync(path.join(box.tweaks, "defs", "big.lua"));
    }
  });
  it("GAP-3: 500 handler echoes e.message — pins current leak surface", () => {
    assert.ok(
      /server error: " \+ e\.message/.test(SERVER_SRC),
      "500 handler changed — GAP-3 may be fixed; update this test + docs"
    );
  });
});

describe("perf smoke W3: list-200 ≤ 2000ms (size asserts primary)", () => {
  it("200-file library lists fast and stays a sane size", async () => {
    const dir = path.join(box.tweaks, "units");
    const made = [];
    for (let i = 0; i < 200; i++) {
      const n = "w3-" + String(i).padStart(3, "0") + ".lua";
      fs.writeFileSync(path.join(dir, n), "{ u" + i + " = { metalcost = 10, }, }\n");
      made.push(n);
    }
    try {
      const t0 = performance.now();
      const r = await req(port, "GET", "/api/tweaks");
      const ms = performance.now() - t0;
      assert.equal(r.status, 200);
      const data = JSON.parse(r.body);
      assert.ok(data.units.length >= 200);
      const budget = 2000;
      const msg = "W3 list-200: " + ms.toFixed(1) + "ms (budget " + budget + "ms)";
      if (ms > budget) {
        if (process.env.PERF_STRICT === "1") throw new Error("PERF BUDGET EXCEEDED — " + msg);
        console.warn("warn (perf, non-strict): " + msg);
      }
      assert.ok(r.body.length < 2_000_000, "list payload unexpectedly large: " + r.body.length);
    } finally {
      for (const n of made) { try { fs.unlinkSync(path.join(dir, n)); } catch {} }
    }
  });
});
