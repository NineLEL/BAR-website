"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const pure = require("../app-pure");

const LIMIT = 16384;

function autoPackHarness(limit) {
  const app = fs.readFileSync(path.join(__dirname, "..", "app.js"), "utf8");
  const start = app.indexOf("function joinChunk(g, minis, idxs)");
  const end = app.indexOf("function collectCommands(g)", start);
  assert.ok(start >= 0 && end > start, "could not isolate autoPack source");
  const calls = { notices: [], renders: 0 };
  const sandbox = {
    MAX_SLOTS: pure.MAX_SLOTS,
    luaMinify: pure.luaMinify,
    buildCommand: pure.buildCommand,
    mergeTweakUnits: pure.mergeTweakUnits,
    planChunks: pure.planChunks,
    findDuplicateDstDetails: pure.findDuplicateDstDetails,
    findDuplicateTweakUnitKeyDetails: pure.findDuplicateTweakUnitKeyDetails,
    findUnsupportedTweakUnitFieldSources: pure.findUnsupportedTweakUnitFieldSources,
    splitTweakUnitsSource: pure.splitTweakUnitsSource,
    getLimit: () => limit,
    useUrlSafe: () => false,
    toast: (message) => calls.notices.push(message),
    renderSlots: () => { calls.renders++; }
  };
  vm.createContext(sandbox);
  vm.runInContext(app.slice(start, end), sandbox, { filename: "app.js#autoPack" });
  return { autoPack: sandbox.autoPack, calls };
}

describe("base64 codec", () => {
  it("roundtrips ASCII, empty, and UTF-8 strings", () => {
    for (const s of ["", "hello world", "Ünïcodé ⚙.lua", "中文测试", "😀🎮✓", "a".repeat(2000) + "ß字😀"]) {
      assert.equal(pure.b64decode(pure.b64encode(s)), s);
    }
  });

  it("supports URL-safe encoding, missing padding, and whitespace", () => {
    const std = pure.b64encode("\uFFFF");
    const url = pure.b64encode("\uFFFF", true);
    assert.ok(std.includes("+") && std.includes("/"));
    assert.ok(!/[+/=]/.test(url) && url.includes("-") && url.includes("_"));
    assert.equal(pure.b64decode(url), "\uFFFF");

    const spaced = std.slice(0, 2) + " \n\t " + std.slice(2).replace(/=+$/, "");
    assert.equal(pure.b64decode(spaced), "\uFFFF");
    assert.throws(() => pure.b64decode("!!!not-base64!!!"), /./);
  });
});

describe("luaMinify & luaPrettify", () => {
  it("strips line and levelled block comments while keeping strings intact", () => {
    assert.equal(pure.luaMinify("-- line\n--[===[ block ]===]local x = 1"), "local x=1");
    assert.equal(pure.luaMinify("local s='a -- b' local t=[=[a ]] --[[ inner ]] b]=]"), "local s='a -- b'local t=[=[a ]] --[[ inner ]] b]=]");
    assert.equal(pure.luaMinify("   \n\t -- only comment"), "");
  });

  it("preserves Lua token boundaries, numbers, and safe semicolons", () => {
    assert.equal(pure.luaMinify("local x = a - -- split\n - b"), "local x=a- -b");
    assert.equal(pure.luaMinify("local y = 1 .. 2"), "local y=1 ..2");
    assert.equal(pure.luaMinify("local a = 1.25e-3; local b = 0x1.fp+2"), "local a=1.25e-3;local b=0x1.fp+2");
    assert.equal(pure.luaMinify("local a = 1;\nif a then print(a); end;"), "local a=1;if a then print(a)end");
    assert.equal(pure.luaMinify("return { a = 1; };"), "return{a=1}");
    assert.equal(pure.luaMinify("local v = 'one\\\r\ntwo' -- c\r\nlocal n = 2"), "local v='one\\\r\ntwo'local n=2");
  });

  it("rejects unterminated strings and comments with line/column info", () => {
    assert.throws(() => pure.luaMinify("local a = 'unterminated"), /line 1, column 11/);
    assert.throws(() => pure.luaMinify("local a = \"line1\nline2\""), /line 1, column 11/);
    assert.throws(() => pure.luaMinify("local a = [==[unterminated"), /line 1, column 11/);
    assert.throws(() => pure.luaMinify("--[==[unterminated"), /line 1, column 1/);
  });

  it("prettifies minified Lua with indented blocks", () => {
    const out = pure.luaPrettify("local s='a -- b';if x then print(s);else print('no');end");
    assert.match(out, /local s = 'a -- b'/);
    assert.match(out, /if x then\n  print\(s\)\nelse\n  print\('no'\)\nend$/);
  });
});

describe("slots, commands, limits, and decode parsing", () => {
  it("addresses 30 slots (0 bare, 1..29 suffixed) and builds decodable commands", () => {
    assert.equal(pure.MAX_SLOTS, 30);
    assert.equal(pure.slotKey("tweakdefs", 0), "tweakdefs");
    assert.equal(pure.slotKey("tweakdefs", 29), "tweakdefs29");
    assert.equal(pure.cmdPrefix("tweakdefs", 29).length - pure.cmdPrefix("tweakdefs", 0).length, 2);

    const min = pure.luaMinify("local a = 1");
    const built = pure.buildCommand("tweakdefs", 4, min);
    assert.equal(built.cmd, "!bset tweakdefs4 " + built.b64);
    assert.deepEqual(pure.parseDecodeInput(built.cmd), { key: "tweakdefs4", b64: built.b64 });
    assert.equal(pure.b64decode(built.b64), min);
  });

  it("emits 30 reset commands per kind and 60 combined", () => {
    const defs = pure.resetCommands("tweakdefs");
    const units = pure.resetCommands("tweakunits");
    const all = pure.resetAllCommands();
    assert.equal(defs.length, 30);
    assert.equal(units.length, 30);
    assert.equal(all.length, 60);
    assert.equal(all[0], "!bset tweakunits 0");
    assert.equal(all[29], "!bset tweakunits29 0");
    assert.equal(all[30], "!bset tweakdefs 0");
    assert.equal(all[59], "!bset tweakdefs29 0");
  });

  it("parses case-insensitive commands, bare payloads, and blank input", () => {
    assert.deepEqual(pure.parseDecodeInput("!BSET   tweakunits2    QUJD"), { key: "tweakunits2", b64: "QUJD" });
    assert.deepEqual(pure.parseDecodeInput("not-a-cmd\nQUJD"), { key: "(unknown key)", b64: "QUJD" });
    assert.deepEqual(pure.parseDecodeInput(" \n\t "), { key: "(unknown key)", b64: "" });
  });

  it("validates custom character limits with 16384 fallback", () => {
    for (const bad of ["", "abc", "0", "999", "-5", null, undefined]) {
      assert.equal(pure.getLimit(bad), LIMIT);
    }
    assert.equal(pure.getLimit("8000"), 8000);
  });
});

describe("tweakunits merge, split, and diagnostics", () => {
  it("merges Lua tables safely across comments and nested strings", () => {
    const out = pure.mergeTweakUnits([
      "--[==[ ignored { braces } ]==]\n{ a = { label = 'literal } {', body = [=[also } {]=], }, }",
      "{ b = { value = 2, }, }",
    ]);
    assert.ok(out.startsWith("{") && out.endsWith("}"));
    assert.ok(out.includes("literal } {") && out.includes("[=[also } {]=]") && out.includes("b = { value = 2, }"));
    assert.equal(pure.mergeTweakUnits(["  ", "-- empty"]), "{  }");
    assert.throws(() => pure.mergeTweakUnits(["local u = { a = 1 }"]), /standalone tweakunits table/);
    assert.throws(() => pure.mergeTweakUnits(["{ a = 1 } extra"]), /Unexpected content/);
    assert.throws(() => pure.mergeTweakUnits(["{ a = { b = 1 }"]), /Unclosed '\{'/);
  });

  it("splits large tweakunits tables cleanly and rejects unsafe tables", () => {
    const src = "{ alpha = { nested = 1, other = 2 }, beta = 2, gamma = 3, delta = 4 }";
    const pieces = pure.splitTweakUnitsSource(src, 100, false);
    assert.ok(pieces.length > 1);
    assert.equal(pure.mergeTweakUnits(pieces), src);
    for (const p of pieces) assert.ok(pure.buildCommand("tweakunits", pure.MAX_SLOTS - 1, p).cmd.length <= 100);

    assert.throws(() => pure.splitTweakUnitsSource("{ big = " + "x".repeat(200) + " }", 60), /field cannot fit/);
    assert.throws(() => pure.splitTweakUnitsSource("{ same = {}, same = {} }", 40), /repeated top-level/);
    assert.throws(() => pure.splitTweakUnitsSource("{ [dyn] = {}, other = {} }", 40), /non-identifier/);
    assert.throws(() => pure.splitTweakUnitsSource("{ fn = function() local a,b=1 end, x = '" + "x".repeat(200) + "' }", 90), /function bodies/);
    assert.throws(() => pure.splitTweakUnitsSource("{ a = ([)], b = '" + "x".repeat(200) + "' }", 90), /Mismatched delimiters/);
  });

  it("detects duplicate dst names, duplicate unit keys, and unsupported fields", () => {
    const a = pure.luaMinify('{ dst = "shared", note = "dst = \\\"fake\\\"", }');
    const b = pure.luaMinify("{ dst = 'shared', }");
    assert.deepEqual(pure.findDuplicateDst([a, b]), ["shared"]);
    assert.deepEqual(pure.findDuplicateDstDetails([a, b]), [{ dst: "shared", sources: [0, 1] }]);
    assert.deepEqual(pure.findDuplicateDst([pure.luaMinify('{ dst = "solo" }\n{ dst = "solo" }')]), []);

    assert.deepEqual(pure.findDuplicateTweakUnitKeyDetails([
      '{ armpw = { x = 1 }, note = "fake = {}" } -- ghost = {}',
      "{ armpw = { x = 2 } }",
      "{ armflash = {}, armflash = {} }"
    ]), [
      { key: "armpw", sources: [0, 1] },
      { key: "armflash", sources: [2] }
    ]);
    assert.deepEqual(pure.findUnsupportedTweakUnitFieldSources(["{ [unitName] = {} }", "{ armpw = {} }"]), [0]);
  });
});

describe("chunk planning and autoPack", () => {
  it("packs order-preserving chunks, flags oversized inputs, and detects 31-slot overflow", () => {
    const small = Array.from({ length: 15 }, (_, i) => pure.luaMinify(`local v${i} = ${i}`));
    const plan = pure.planChunks("tweakdefs", small, LIMIT);
    assert.deepEqual(plan.chunks.flat(), small.map((_, i) => i));
    assert.deepEqual(plan.oversized, []);
    assert.deepEqual(plan.overflow, []);

    const over = pure.planChunks("tweakdefs", ["x".repeat(LIMIT * 2)], LIMIT);
    assert.deepEqual(over.oversized, [0]);
    assert.ok(over.sizes[0] > LIMIT);

    const overflow = pure.planChunks("tweakdefs", Array.from({ length: 31 }, (_, i) => "x".repeat(9000) + i), LIMIT);
    assert.equal(overflow.chunks.length, 31);
    assert.deepEqual(overflow.overflow, [30]);
    assert.deepEqual(overflow.oversized, []);
  });

  it("uses worst-case two-digit slot prefix sizing at the b64 boundary", () => {
    const prefix = pure.cmdPrefix("tweakdefs", pure.MAX_SLOTS - 1).length;
    const maxB64 = LIMIT - prefix - ((LIMIT - prefix) % 4);
    const fitBytes = (maxB64 / 4) * 3;
    const overBytes = fitBytes + 1;

    const fitPlan = pure.planChunks("tweakdefs", ["x".repeat(fitBytes)], LIMIT);
    assert.deepEqual(fitPlan.oversized, []);
    assert.ok(fitPlan.sizes[0] <= LIMIT);

    const overPlan = pure.planChunks("tweakdefs", ["x".repeat(overBytes)], LIMIT);
    assert.deepEqual(overPlan.oversized, [0]);
    assert.ok(overPlan.sizes[0] > LIMIT);
    assert.equal(pure.buildCommand("tweakdefs", 0, "x".repeat(overBytes)).cmd.length, LIMIT);
  });

  it("autoPack retains prior output on overflow and splits oversized tweakunits tables", () => {
    const overflowHarness = autoPackHarness(LIMIT);
    const files = Array.from({ length: 31 }, (_, i) => ({ name: `defs-${i}.lua`, text: `local v${i} = '${"x".repeat(9000)}'` }));
    const g1 = { kind: "tweakdefs", serverSnippets: files, snippets: [], packed: ["keep"], packedNames: [["keep"]], packNotice: null };
    overflowHarness.autoPack(g1);
    assert.equal(g1.packed[0], "keep");
    assert.match(g1.packNotice, /requires 31 slot\(s\)/);

    const splitHarness = autoPackHarness(1000);
    const fields = Array.from({ length: 10 }, (_, i) => `unit${i} = { name = '${"x".repeat(250)}' }`);
    const g2 = { kind: "tweakunits", serverSnippets: [{ name: "large.lua", text: `{ ${fields.join(", ")} }` }], snippets: [], packed: [], packedNames: [], packNotice: null };
    splitHarness.autoPack(g2);
    assert.ok(g2.packed.length > 1);
    assert.ok(g2.packedNames.every((names) => names[0].startsWith("large.lua (part ")));
    g2.packed.forEach((src, i) => assert.ok(pure.buildCommand("tweakunits", i, src).cmd.length <= 1000));
  });
});
