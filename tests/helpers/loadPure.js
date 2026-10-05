"use strict";
/* Test helper: extract the pure logic fns from app.js WITHOUT executing it.
 *
 * app.js mixes pure logic (luaMinify, b64encode/b64decode, mergeTweakUnits,
 * slotKey/cmdPrefix/buildCommand) with DOM code that runs on load, so the
 * whole file can never be required/eval'd under node. This loader reads the
 * source, slices out only the named function declarations (balanced-brace
 * scan — robust against nested braces, strings and comments) plus the
 * MAX_SLOTS const, and runs just those slices in a fresh vm context.
 *
 * Returns: { b64encode, b64decode, luaMinify, slotKey, cmdPrefix,
 *            buildCommand, mergeTweakUnits, packChunks, findDuplicateDst,
 *            resetCommands, getLimit, MAX_SLOTS, src }
 * getLimit is included with a stubbable $ — set `pure.__charLimitValue`
 * before calling getLimit() to control the fake #charLimit input.
 */
const fs = require("fs");
const path = require("path");
const vm = require("vm");

const PURE_FNS = [
  "b64encode",
  "b64decode",
  "luaMinify",
  "slotKey",
  "cmdPrefix",
  "buildCommand",
  "mergeTweakUnits",
  "packChunks",
  "findDuplicateDst",
  "resetCommands",
  "getLimit",
];

function extractFunction(src, name) {
  // Boundary detection via the engine's own parser: any proper prefix of the
  // function body ending at an inner `}` (or inside a string/comment/regex)
  // is a syntax error, so the FIRST `}` position that compiles is the true
  // end. Immune to quotes/braces inside regex literals, strings, comments.
  const marker = "function " + name + "(";
  const start = src.indexOf(marker);
  if (start < 0) throw new Error("loadPure: function " + name + " not found in app.js");
  let pos = src.indexOf("{", start);
  if (pos < 0) throw new Error("loadPure: no body for " + name);
  for (;;) {
    pos = src.indexOf("}", pos + 1);
    if (pos < 0) throw new Error("loadPure: unbalanced braces in " + name);
    const slice = src.slice(start, pos + 1);
    try {
      new vm.Script(slice); // eslint-disable-line no-new
      return slice;
    } catch (e) {
      if (!(e instanceof SyntaxError)) throw e;
      // Not a complete function yet — keep scanning.
    }
  }
}

function extractConst(src, name) {
  const m = src.match(new RegExp("var\\s+" + name + "\\s*=\\s*[^;]+;"));
  if (!m) throw new Error("loadPure: const " + name + " not found in app.js");
  return m[0];
}

function loadPure(appPath) {
  const file = appPath || path.join(__dirname, "..", "..", "app.js");
  const src = fs.readFileSync(file, "utf8");

  // Guard: confirm the DOM section is present (so we know whole-file eval
  // would be unsafe) — we only compile the extracted slices below, never
  // the whole file.
  if (!/document\.querySelectorAll/.test(src)) {
    throw new Error("loadPure: app.js DOM section not found —Unexpected source layout");
  }
  const parts = [extractConst(src, "MAX_SLOTS")];
  for (const name of PURE_FNS) parts.push(extractFunction(src, name));
  const code = parts.join("\n\n") + "\n";

  const sandbox = {
    __charLimitValue: "16384",
    TextEncoder: TextEncoder,
    TextDecoder: TextDecoder,
    btoa: btoa,
    atob: atob,
  };
  sandbox.$ = function (id) {
    if (id === "charLimit") return { value: sandbox.__charLimitValue };
    throw new Error("loadPure stub $: unknown id " + id);
  };
  sandbox.globalThis = sandbox;
  vm.createContext(sandbox);
  vm.runInContext(code + "\nthis.__exports = { b64encode, b64decode, luaMinify, slotKey, cmdPrefix, buildCommand, mergeTweakUnits, packChunks, findDuplicateDst, resetCommands, getLimit, MAX_SLOTS };", sandbox, { filename: "app-pure-slice.js" });

  const api = sandbox.__exports;
  api.__charLimitValue = undefined; // placeholder replaced below
  Object.defineProperty(api, "__charLimitValue", {
    get: function () { return sandbox.__charLimitValue; },
    set: function (v) { sandbox.__charLimitValue = v; },
    enumerable: true,
  });
  api.src = src;
  return api;
}

module.exports = { loadPure: loadPure, PURE_FNS: PURE_FNS };
