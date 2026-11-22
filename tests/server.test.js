"use strict";

const { describe, it, before, after } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const http = require("node:http");
const os = require("node:os");
const path = require("node:path");

const createServer = require("../server.js").createServer;
const LIVE_STATE = path.join(__dirname, "..", "tweaks", "state.json");

let liveStateSnapshot = null;
let box;
let server;
let port;

function req(targetPort, method, url, body, headers = {}) {
  return new Promise((resolve, reject) => {
    const r = http.request({ host: "127.0.0.1", port: targetPort, path: url, method, headers }, (res) => {
      const chunks = [];
      res.on("data", (c) => chunks.push(c));
      res.on("end", () => resolve({ status: res.statusCode, headers: res.headers, body: Buffer.concat(chunks).toString("utf8") }));
    });
    r.on("error", reject);
    if (body) r.write(body);
    r.end();
  });
}

const postToggle = (obj) => req(port, "POST", "/api/tweaks/toggle", JSON.stringify(obj), { "Content-Type": "application/json" });

before(async () => {
  liveStateSnapshot = fs.existsSync(LIVE_STATE) ? fs.readFileSync(LIVE_STATE, "utf8") : null;
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "bar-packer-"));
  const tweaks = path.join(root, "tweaks");
  const outside = path.join(path.dirname(root), "bar-canary-" + path.basename(root) + ".txt");
  fs.writeFileSync(path.join(root, "index.html"), "<!doctype html><title>stub</title>");
  fs.writeFileSync(outside, "CANARY-DO-NOT-SERVE");

  const srv = createServer({ root, tweaksDir: tweaks });
  srv.ensureDirs();
  fs.writeFileSync(path.join(tweaks, "defs", "alpha.lua"), "-- alpha\nlocal a = 1\n");
  fs.writeFileSync(path.join(tweaks, "units", "beta.lua"), "{ armpw = { metalcost = 10, }, }\n");
  fs.mkdirSync(path.join(tweaks, "defs", "nested"), { recursive: true });
  fs.writeFileSync(path.join(tweaks, "defs", "nested", "mex.lua"), "-- nested\n");
  fs.writeFileSync(path.join(tweaks, "defs", "notes.txt"), "ignored");

  box = { root, tweaks, outside, srv };
  server = await new Promise((resolve) => { const s = srv.server.listen(0, "127.0.0.1", () => resolve(s)); });
  port = server.address().port;
});

after(async () => {
  if (server) await new Promise((resolve) => server.close(resolve));
  try { fs.rmSync(box.root, { recursive: true, force: true }); } catch {}
  try { fs.unlinkSync(box.outside); } catch {}
  const now = fs.existsSync(LIVE_STATE) ? fs.readFileSync(LIVE_STATE, "utf8") : null;
  assert.equal(now, liveStateSnapshot, "live tweaks/state.json was modified by tests");
});

describe("server API", () => {
  it("lists nested .lua tweaks, ignores non-.lua files, and seeds state from defaults", async () => {
    const r = await req(port, "GET", "/api/tweaks?ignored=1");
    assert.equal(r.status, 200);
    assert.match(r.headers["content-type"] || "", /application\/json/);
    const data = JSON.parse(r.body);
    assert.deepEqual(data.defs.map((f) => f.name), ["alpha.lua", "nested/mex.lua"]);
    assert.equal(data.defs[0].enabled, true);
    assert.equal(data.defs[0].chars, data.defs[0].content.length);
    assert.equal(data.units.find((f) => f.name === "beta.lua").enabled, true);

    const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "bar-defaults-"));
    try {
      const tweaks = path.join(tmp, "tweaks");
      fs.mkdirSync(tweaks, { recursive: true });
      fs.writeFileSync(path.join(tweaks, "state.defaults.json"), JSON.stringify({ "defs/a.lua": false }));
      createServer({ root: tmp, tweaksDir: tweaks }).ensureDirs();
      assert.deepEqual(JSON.parse(fs.readFileSync(path.join(tweaks, "state.json"), "utf8")), { "defs/a.lua": false });
    } finally {
      fs.rmSync(tmp, { recursive: true, force: true });
    }
  });

  it("persists toggles for root and nested tweaks and recovers from corrupt state.json", async () => {
    let r = await postToggle({ kind: "defs", name: "nested/mex.lua", enabled: false });
    assert.equal(r.status, 200);
    assert.equal(r.body, JSON.stringify({ ok: true }));
    let data = JSON.parse((await req(port, "GET", "/api/tweaks")).body);
    assert.equal(data.defs.find((f) => f.name === "nested/mex.lua").enabled, false);

    const sf = path.join(box.tweaks, "state.json");
    fs.writeFileSync(sf, "NOT JSON{{{");
    data = JSON.parse((await req(port, "GET", "/api/tweaks")).body);
    assert.equal(data.defs.find((f) => f.name === "nested/mex.lua").enabled, true);

    r = await postToggle({ kind: "units", name: "beta.lua", enabled: false });
    assert.equal(r.status, 200);
    assert.equal(JSON.parse(fs.readFileSync(sf, "utf8"))["units/beta.lua"], false);
    await postToggle({ kind: "units", name: "beta.lua", enabled: true });
  });

  it("rejects invalid toggle payloads, wrong methods, and oversized bodies", async () => {
    const badPayloads = [
      { kind: "bad", name: "alpha.lua", enabled: true },
      { kind: "defs", name: "../server.js", enabled: true },
      { kind: "defs", name: "evil.js", enabled: false },
      { kind: "defs", name: "alpha.lua", enabled: "true" },
      { kind: "defs", name: "", enabled: true },
    ];
    for (const payload of badPayloads) {
      const r = await postToggle(payload);
      assert.equal(r.status, 400);
      assert.equal(r.body, "bad request");
    }
    assert.equal((await req(port, "POST", "/api/tweaks/toggle", "{bad json")).status, 400);
    assert.equal((await req(port, "POST", "/api/tweaks", "{}")).status, 405);
    assert.equal((await req(port, "DELETE", "/")).status, 405);

    const big = await req(port, "POST", "/api/tweaks/toggle", "x".repeat(1_050_000));
    assert.equal(big.status, 413);
    assert.equal((await req(port, "GET", "/api/tweaks")).status, 200);
  });

  it("validates safeName inputs", () => {
    for (const ok of ["a.lua", "my tweak 1.LUA", "air/late game.lua"]) {
      assert.equal(box.srv.safeName(ok), ok);
    }
    for (const bad of ["../x.lua", "..\\x.lua", "/abs.lua", "", ".lua", "x.js", "x\0.lua", null, 42]) {
      assert.equal(box.srv.safeName(bad), null);
    }
  });
});

describe("static serving & hardening", () => {
  it("serves allowed static files and blocks traversal, internal files, and bad encoding", async () => {
    const ok = await req(port, "GET", "/index.html");
    assert.equal(ok.status, 200);
    assert.ok(ok.body.includes("stub"));

    const canary = path.basename(box.outside);
    for (const badUrl of [`/..%2f..%2f${canary}`, "/%2e%2e/%2e%2e/x", "/..%5c..%5cx"]) {
      const r = await req(port, "GET", badUrl);
      assert.ok([403, 404].includes(r.status), `${badUrl} -> ${r.status}`);
      assert.ok(!r.body.includes("CANARY-DO-NOT-SERVE"));
    }

    fs.mkdirSync(path.join(box.root, ".git"), { recursive: true });
    fs.writeFileSync(path.join(box.root, ".git", "config"), "private");
    fs.writeFileSync(path.join(box.root, "secret.txt"), "private");
    for (const hidden of ["/.git/config", "/secret.txt", "/tweaks/state.json", "/missing.html"]) {
      const r = await req(port, "GET", hidden);
      assert.equal(r.status, 404, hidden);
      assert.ok(!r.body.includes("private"));
    }

    assert.equal((await req(port, "GET", "/%E0%A4%A")).status, 400);
  });
});
