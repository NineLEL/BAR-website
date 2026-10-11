"use strict";

// Source-contract regression checks for the library's load/render boundary.
// The app is a browser IIFE with extensive DOM wiring; these checks intentionally
// avoid a heavyweight DOM dependency and validate only the relevant orchestration.
const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const app = fs.readFileSync(path.join(__dirname, "..", "app.js"), "utf8");

function functionSource(name) {
  const start = app.indexOf(`function ${name}(`);
  assert.notEqual(start, -1, `missing function ${name}`);
  const brace = app.indexOf("{", start);
  let depth = 0;
  let quote = null;
  let escaped = false;
  for (let i = brace; i < app.length; i++) {
    const c = app[i];
    if (quote) {
      if (escaped) escaped = false;
      else if (c === "\\") escaped = true;
      else if (c === quote) quote = null;
      continue;
    }
    if (c === "'" || c === '"' || c === "`") { quote = c; continue; }
    if (c === "{") depth++;
    if (c === "}" && --depth === 0) return app.slice(start, i + 1);
  }
  assert.fail(`unterminated function ${name}`);
}

test("library fetch synchronizes enabled snippets before optional deferred DOM render", () => {
  const source = functionSource("renderLib");
  assert.match(source, /window\._lib\s*=\s*data/);
  assert.ok(source.indexOf("syncLibToPacker()") < source.indexOf("if (libraryRendered) renderLibrary()"));
  assert.match(functionSource("syncLibToPacker"), /data\.defs\.filter\(function \(f\) \{ return f\.enabled; \}\)/);
  assert.match(functionSource("syncLibToPacker"), /data\.units\.filter\(function \(f\) \{ return f\.enabled; \}\)/);
  assert.match(source, /if \(libraryRendered\) renderLibrary\(\)/,
    "refreshes update existing rows but must not build rows before first activation");
});

test("first Library-tab activation is the render trigger", () => {
  const activate = functionSource("activateTab");
  assert.match(activate, /if \(btn\.dataset\.tab === "library"\) renderLibrary\(\)/);
  const render = functionSource("renderLibrary");
  assert.match(render, /if \(!window\._lib\) return/);
  assert.match(render, /libraryRendered\s*=\s*true/);
  assert.match(render, /renderLibGroup\(\$\("libDefs"\), "defs", window\._lib\.defs\)/);
  assert.match(render, /renderLibGroup\(\$\("libUnits"\), "units", window\._lib\.units\)/);
});

test("search, clear, reload, and preview remain lazy and functional", () => {
  assert.match(app, /\$\("libSearch"\)\.oninput\s*=\s*function \(\)[\s\S]*?if \(libraryRendered\) renderLibrary\(\)/);
  assert.match(app, /\$\("libSearchClear"\)\.onclick\s*=\s*function \(\)[\s\S]*?if \(libraryRendered\) renderLibrary\(\)/);
  assert.match(app, /\$\("libReload"\)\.onclick\s*=\s*libFetch/);
  assert.match(functionSource("libFetch"), /LibraryApi\.fetchLibrary\(\)/);
  const group = functionSource("renderLibGroup");
  assert.match(group, /f\.name\.toLowerCase\(\)\.indexOf\(query\)/);
  assert.match(group, /toggleLibraryFile\(kind, f\.name, cb\.checked\)/);
  assert.match(group, /toggleLibraryFiles\(groupFiles\.map\(function \(f\)/);
  assert.match(group, /setAllLib\(enable, kind\)/);
  assert.match(group, /if \(opening\)[\s\S]*?pre\.textContent = f\.content[\s\S]*?pre\.hidden = false/);
  assert.match(group, /pre\.textContent = ""[\s\S]*?pre\.hidden = true/);
  assert.match(group, /pre\.id = "lib-preview-" \+ kind \+ "-" \+ fileIndexes\[f\.name\]/);
  assert.match(group, /pv\.setAttribute\("aria-controls", pre\.id\)/);
  assert.match(group, /checkboxLabel\.appendChild\(cb\)[\s\S]*?checkboxLabel\.appendChild\(nm\)/);
  assert.match(group, /checkboxLabel\.setAttribute\("aria-label", \(f\.enabled \? "Disable " : "Enable "\) \+ f\.name\)/);
});

test("library toggles serialize requests per file while bulk operations fan out", () => {
  const toggle = functionSource("toggleLibraryFile");
  assert.match(toggle, /var key = kind \+ "\/" \+ name/);
  assert.match(toggle, /var previous = libraryToggleQueues\[key\] \|\| Promise\.resolve\(\)/);
  assert.match(toggle, /previous\.catch\(function \(\) \{\}\)\.then\(function \(\) \{[\s\S]*?LibraryApi\.toggle\(kind, name, enabled\)/);
  assert.match(toggle, /libraryToggleQueues\[key\] === current/);

  const toggleFiles = functionSource("toggleLibraryFiles");
  assert.match(toggleFiles, /Promise\.all\(files\.map\(function \(file\)/);
  assert.match(toggleFiles, /toggleLibraryFile\(file\.kind, file\.name, enabled\)/);

  const bulk = functionSource("setAllLib");
  assert.match(bulk, /toggleLibraryFiles\(files, enabled\)/);
});

function deferred() {
  let resolve, reject;
  const promise = new Promise((res, rej) => { resolve = res; reject = rej; });
  return { promise, resolve, reject };
}

test("same-file toggles execute serially and persist the latest choice", async () => {
  const writes = [];
  let persisted;
  const LibraryApi = {
    toggle(kind, name, enabled) {
      const gate = deferred();
      writes.push({ kind, name, enabled, gate });
      return gate.promise.then((result) => { persisted = enabled; return result; });
    }
  };
  const toggleLibraryFile = new Function("LibraryApi", "libraryToggleQueues", "Promise", "return (" +
    functionSource("toggleLibraryFile") + ");")(LibraryApi, Object.create(null), Promise);

  const enable = toggleLibraryFile("defs", "example.lua", true);
  const disable = toggleLibraryFile("defs", "example.lua", false);
  await new Promise((resolve) => setImmediate(resolve));
  assert.deepEqual(writes.map(({ enabled }) => enabled), [true]);
  writes[0].gate.resolve({ ok: true });
  await enable;
  await Promise.resolve();
  assert.deepEqual(writes.map(({ enabled }) => enabled), [true, false]);
  writes[1].gate.resolve({ ok: true });
  await disable;
  assert.equal(persisted, false);
});

test("same-file toggle queue recovers after a rejected write", async () => {
  const writes = [];
  const LibraryApi = { toggle(_kind, _name, enabled) {
    const gate = deferred(); writes.push({ enabled, gate }); return gate.promise;
  } };
  const toggleLibraryFile = new Function("LibraryApi", "libraryToggleQueues", "Promise", "return (" +
    functionSource("toggleLibraryFile") + ");")(LibraryApi, Object.create(null), Promise);
  const first = toggleLibraryFile("units", "x.lua", true);
  const second = toggleLibraryFile("units", "x.lua", false);
  await new Promise((resolve) => setImmediate(resolve));
  writes[0].gate.reject(new Error("write failed"));
  await assert.rejects(first, /write failed/);
  await new Promise((resolve) => setImmediate(resolve));
  assert.deepEqual(writes.map(({ enabled }) => enabled), [true, false]);
  writes[1].gate.resolve({ ok: true });
  await second;
});

test("libFetch ignores an older response that resolves last", async () => {
  const rendered = [];
  const nodes = { libStatus: { textContent: "" } };
  const firstGate = deferred(), secondGate = deferred();
  let calls = 0;
  const fetcher = new Function("$", "LibraryApi", "renderLib", "libraryRequest", "libraryRendered", "window", "return " + functionSource("libFetch"))(
    (id) => nodes[id] || (nodes[id] = { textContent: "" }),
    { fetchLibrary: () => [firstGate, secondGate][calls++].promise },
    (data) => rendered.push(data), 0, false, {});
  fetcher(); fetcher();
  const older = { defs: [{ name: "old" }], units: [] };
  const newer = { defs: [{ name: "new" }], units: [] };
  secondGate.resolve(newer);
  await Promise.resolve();
  firstGate.resolve(older);
  await Promise.resolve();
  assert.deepEqual(rendered, [newer]);
  assert.equal(nodes.libStatus.textContent, "Loading tweak library…");
});
