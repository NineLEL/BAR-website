"use strict";
/* BAR Tweak Packer — tiny local server, zero dependencies.
 * Serves the site + exposes .lua files from tweaks/defs and tweaks/units.
 *
 *   node server.js [port]     (default 8080)
 *   → open http://localhost:8080
 *
 * Add files:  tweaks/defs/*.lua   (runnable Lua, UnitDefs in scope)
 *             tweaks/units/*.lua  (Lua table merged into UnitDefs)
 * Enable/disable is stored in tweaks/state.json (files are never moved).
 */
const http = require("http");
const fs = require("fs");
const path = require("path");

// TESTABILITY NOTE (single-writer harness): ROOT/TWEAKS_DIR honour env overrides so
// tests can point the server at a temp dir instead of the live ./tweaks folder.
// Behaviour is unchanged when the env vars are unset. The server only binds when
// run directly (require.main === module); requiring this file has no side effects.
const ROOT = process.env.BAR_ROOT || __dirname;
const TWEAKS_DIR = process.env.BAR_TWEAKS_DIR || path.join(ROOT, "tweaks");
const KINDS = ["defs", "units"];
const STATE_FILE = path.join(TWEAKS_DIR, "state.json");
const PORT = parseInt(process.argv[2], 10) || 8080;

function ensureDirs() {
  for (const k of KINDS) fs.mkdirSync(path.join(TWEAKS_DIR, k), { recursive: true });
  if (!fs.existsSync(STATE_FILE)) fs.writeFileSync(STATE_FILE, "{}\n");
}
function readState() {
  try {
    const s = JSON.parse(fs.readFileSync(STATE_FILE, "utf8"));
    return (s && typeof s === "object") ? s : {};
  } catch (e) { return {}; }
}
function writeState(st) {
  fs.writeFileSync(STATE_FILE, JSON.stringify(st, null, 2) + "\n");
}
function safeName(name) {
  if (typeof name !== "string") return null;
  const rel = name.replace(/\\/g, "/");
  const parts = rel.split("/");
  if (!parts.length || parts.some(function (part) { return !part || part === "." || part === ".."; })) return null;
  if (parts.some(function (part) { return !/^[A-Za-z0-9 _.\-]+$/i.test(part); })) return null;
  if (!/^[A-Za-z0-9 _.\-]+\.lua$/i.test(parts[parts.length - 1])) return null;
  return parts.join("/");
}
function luaFiles(dir, prefix) {
  const out = [];
  let entries = [];
  try { entries = fs.readdirSync(dir, { withFileTypes: true }); } catch (e) { return out; }
  for (const entry of entries) {
    const rel = prefix ? prefix + "/" + entry.name : entry.name;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push.apply(out, luaFiles(full, rel));
    else if (entry.isFile() && entry.name.toLowerCase().endsWith(".lua")) out.push(rel);
  }
  return out;
}
function listTweaks() {
  const state = readState();
  const out = { defs: [], units: [] };
  for (const kind of KINDS) {
    const dir = path.join(TWEAKS_DIR, kind);
    let files = [];
    files = luaFiles(dir, "");
    files.sort();
    for (const name of files) {
      const key = kind + "/" + name;
      let content = "";
      try { content = fs.readFileSync(path.join(dir, ...name.split("/")), "utf8"); }
      catch (e) { content = "-- unreadable: " + e.message; }
      out[kind].push({ name: name, enabled: state[key] !== false, chars: content.length, content: content });
    }
  }
  return out;
}
function libraryVersion() {
  let newest = 0;
  const files = [STATE_FILE];
  for (const kind of KINDS) {
    const dir = path.join(TWEAKS_DIR, kind);
    luaFiles(dir, "").forEach(function (name) { files.push(path.join(dir, ...name.split("/"))); });
  }
  for (const file of files) {
    try {
      const stat = fs.statSync(file);
      newest = Math.max(newest, stat.mtimeMs, stat.size);
    } catch (e) {}
  }
  return String(newest) + ":" + files.length;
}

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".png": "image/png"
};
function serveStatic(res, urlPath) {
  let rel = decodeURIComponent(urlPath.split("?")[0]);
  if (rel === "/") rel = "/index.html";
  const file = path.normalize(path.join(ROOT, rel));
  if (file !== ROOT && !file.startsWith(ROOT + path.sep)) {
    res.writeHead(403); res.end("forbidden"); return;
  }
  let stat = null;
  try { stat = fs.statSync(file); } catch (e) { stat = null; }
  if (!stat || stat.isDirectory()) { res.writeHead(404); res.end("not found"); return; }
  res.writeHead(200, { "Content-Type": MIME[path.extname(file).toLowerCase()] || "application/octet-stream" });
  fs.createReadStream(file).pipe(res);
}
function readBody(req) {
  return new Promise(function (resolve, reject) {
    let body = "";
    req.on("data", function (c) { body += c; if (body.length > 1e6) req.destroy(); });
    req.on("end", function () { resolve(body); });
    req.on("error", reject);
  });
}

const server = http.createServer(function (req, res) {
  (async function () {
    if (req.method === "GET" && req.url.split("?")[0] === "/api/tweaks") {
      res.writeHead(200, { "Content-Type": "application/json; charset=utf-8" });
      res.end(JSON.stringify(listTweaks()));
      return;
    }
    if (req.method === "GET" && req.url.split("?")[0] === "/api/tweaks/version") {
      res.writeHead(200, { "Content-Type": "application/json; charset=utf-8", "Cache-Control": "no-store" });
      res.end(JSON.stringify({ version: libraryVersion() }));
      return;
    }
    if (req.method === "POST" && req.url === "/api/tweaks/toggle") {
      let data = {};
      try { data = JSON.parse((await readBody(req)) || "{}"); } catch (e) { data = {}; }
      const safe = safeName(data.name);
      if (KINDS.indexOf(data.kind) < 0 || !safe || typeof data.enabled !== "boolean") {
        res.writeHead(400); res.end("bad request"); return;
      }
      const kindDir = path.resolve(TWEAKS_DIR, data.kind);
      const target = path.resolve(kindDir, ...safe.split("/"));
      if (!target.startsWith(kindDir + path.sep) || !fs.existsSync(target) || !fs.statSync(target).isFile()) {
        res.writeHead(400); res.end("bad request"); return;
      }
      const state = readState();
      state[data.kind + "/" + safe] = data.enabled;
      writeState(state);
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ ok: true }));
      return;
    }
    if (req.method === "GET") { serveStatic(res, req.url); return; }
    res.writeHead(405); res.end("method not allowed");
  })().catch(function (e) {
    try { res.writeHead(500); res.end("server error: " + e.message); } catch (ignored) {}
  });
});

if (require.main === module) {
  ensureDirs();
  server.listen(PORT, function () {
    console.log("BAR Tweak Packer at http://localhost:" + PORT + "  (tweaks folder: ./tweaks)");
  });
}

module.exports = {
  server: server,
  safeName: safeName,
  listTweaks: listTweaks,
  libraryVersion: libraryVersion,
  readState: readState,
  writeState: writeState,
  serveStatic: serveStatic,
  readBody: readBody,
  ensureDirs: ensureDirs,
  KINDS: KINDS,
  getPaths: function () { return { ROOT: ROOT, TWEAKS_DIR: TWEAKS_DIR, STATE_FILE: STATE_FILE }; }
};
