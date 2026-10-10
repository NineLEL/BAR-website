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

const KINDS = ["defs", "units"];

function createConfiguration(options) {
  options = options || {};
  const env = options.env || process.env;
  const root = path.resolve(options.root || env.BAR_ROOT || __dirname);
  const tweaksDir = path.resolve(options.tweaksDir || env.BAR_TWEAKS_DIR || path.join(root, "tweaks"));
  return { root: root, tweaksDir: tweaksDir, stateFile: path.join(tweaksDir, "state.json") };
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

// Filesystem-backed library and state operations are scoped to one configuration.
function createLibrary(config) {
  function ensureDirs() {
    for (const k of KINDS) fs.mkdirSync(path.join(config.tweaksDir, k), { recursive: true });
    if (!fs.existsSync(config.stateFile)) fs.writeFileSync(config.stateFile, "{}\n");
  }
  function readState() {
    try {
      const s = JSON.parse(fs.readFileSync(config.stateFile, "utf8"));
      return (s && typeof s === "object") ? s : {};
    } catch (e) { return {}; }
  }
  function writeState(st) {
    fs.writeFileSync(config.stateFile, JSON.stringify(st, null, 2) + "\n");
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
      const dir = path.join(config.tweaksDir, kind);
      const files = luaFiles(dir, "");
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
    const files = [config.stateFile];
    for (const kind of KINDS) {
      const dir = path.join(config.tweaksDir, kind);
      luaFiles(dir, "").forEach(function (name) { files.push(path.join(dir, ...name.split("/"))); });
    }
    files.sort();
    return JSON.stringify(files.map(function (file) {
      try {
        const stat = fs.statSync(file);
        return [path.relative(config.tweaksDir, file), stat.mtimeMs, stat.size];
      } catch (e) {
        return [path.relative(config.tweaksDir, file), null, null];
      }
    }));
  }
  function watchLibraryUpdates(intervalMs) {
    let previousVersion = libraryVersion();
    const interval = setInterval(function () {
      const currentVersion = libraryVersion();
      if (currentVersion !== previousVersion) {
        previousVersion = currentVersion;
        console.log("Server library updated");
      }
    }, intervalMs || 2000);
    return function stopWatchingLibrary() { clearInterval(interval); };
  }
  return {
    ensureDirs: ensureDirs,
    readState: readState,
    writeState: writeState,
    listTweaks: listTweaks,
    libraryVersion: libraryVersion,
    watchLibraryUpdates: watchLibraryUpdates
  };
}

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".png": "image/png"
};
function serveStatic(root, res, urlPath) {
  let rel = decodeURIComponent(urlPath.split("?")[0]);
  if (rel === "/") rel = "/index.html";
  const file = path.normalize(path.join(root, rel));
  if (file !== root && !file.startsWith(root + path.sep)) {
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

function createRequestHandler(config, library) {
  return function (req, res) {
    (async function () {
      if (req.method === "GET" && req.url.split("?")[0] === "/api/tweaks") {
        res.writeHead(200, { "Content-Type": "application/json; charset=utf-8" });
        res.end(JSON.stringify(library.listTweaks()));
        return;
      }
      if (req.method === "GET" && req.url.split("?")[0] === "/api/tweaks/version") {
        res.writeHead(200, { "Content-Type": "application/json; charset=utf-8", "Cache-Control": "no-store" });
        res.end(JSON.stringify({ version: library.libraryVersion() }));
        return;
      }
      if (req.method === "POST" && req.url === "/api/tweaks/toggle") {
        let data = {};
        try { data = JSON.parse((await readBody(req)) || "{}"); } catch (e) { data = {}; }
        const safe = safeName(data.name);
        if (KINDS.indexOf(data.kind) < 0 || !safe || typeof data.enabled !== "boolean") {
          res.writeHead(400); res.end("bad request"); return;
        }
        const kindDir = path.resolve(config.tweaksDir, data.kind);
        const target = path.resolve(kindDir, ...safe.split("/"));
        if (!target.startsWith(kindDir + path.sep) || !fs.existsSync(target) || !fs.statSync(target).isFile()) {
          res.writeHead(400); res.end("bad request"); return;
        }
        const state = library.readState();
        state[data.kind + "/" + safe] = data.enabled;
        library.writeState(state);
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ ok: true }));
        return;
      }
      if (req.method === "GET") { serveStatic(config.root, res, req.url); return; }
      res.writeHead(405); res.end("method not allowed");
    })().catch(function (e) {
      try { res.writeHead(500); res.end("server error: " + e.message); } catch (ignored) {}
    });
  };
}

function createServer(options) {
  const config = createConfiguration(options);
  const library = createLibrary(config);
  const server = http.createServer(createRequestHandler(config, library));
  return {
    server: server,
    safeName: safeName,
    listTweaks: library.listTweaks,
    libraryVersion: library.libraryVersion,
    watchLibraryUpdates: library.watchLibraryUpdates,
    readState: library.readState,
    writeState: library.writeState,
    serveStatic: function (res, urlPath) { return serveStatic(config.root, res, urlPath); },
    readBody: readBody,
    ensureDirs: library.ensureDirs,
    KINDS: KINDS,
    getPaths: function () { return { ROOT: config.root, TWEAKS_DIR: config.tweaksDir, STATE_FILE: config.stateFile }; }
  };
}

let defaultInstance = null;
function getDefaultInstance() {
  if (!defaultInstance) defaultInstance = createServer();
  return defaultInstance;
}

if (require.main === module) {
  const PORT = parseInt(process.argv[2], 10) || 8080;
  const instance = createServer();
  instance.ensureDirs();
  instance.watchLibraryUpdates();
  const server = instance.server;
  server.listen(PORT, function () {
    console.log("BAR Tweak Packer at http://localhost:" + PORT + "  (tweaks folder: ./tweaks)");
  });
}

// Compatibility wrappers initialize a non-listening, non-writing default instance
// only when a legacy export is accessed. New callers should use createServer(options).
const exportsObject = { createServer: createServer, createConfiguration: createConfiguration, KINDS: KINDS };
for (const name of ["safeName", "listTweaks", "libraryVersion", "watchLibraryUpdates", "readState", "writeState", "serveStatic", "readBody", "ensureDirs", "getPaths"]) {
  exportsObject[name] = function () {
    return getDefaultInstance()[name].apply(null, arguments);
  };
}
Object.defineProperty(exportsObject, "server", { enumerable: true, get: function () { return getDefaultInstance().server; } });
module.exports = exportsObject;
