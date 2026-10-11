"use strict";
/* Pure-logic suite for the BAR Tweak Packer's directly imported core module.
 * No DOM, no network, no live tweaks/ — deterministic and order-independent.
 * Run: npm test  (or: node --test tests/pure.test.js)
 */
const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("fs");
const path = require("path");
const pure = require("../app-pure");

const LIMIT = 16384;
const PERF_STRICT = process.env.PERF_STRICT === "1";

function perfCheck(name, ms, budget) {
  const msg = name + ": " + ms.toFixed(1) + "ms (budget " + budget + "ms)";
  if (ms > budget) {
    if (PERF_STRICT) throw new Error("PERF BUDGET EXCEEDED — " + msg);
    console.warn("warn (perf, non-strict): " + msg);
  }
}

// Harness over the REAL packer: pure.packChunks() returns index
// chunks; joining here mirrors joinChunk(). autoPack() itself is DOM-bound
// (toast/renderSlots/names), so this pins the sizing contract it relies on:
// worst-case numbered-slot prefix + b64 length <= limit.
function greedyPack(pure, kind, minis, limit) {
  return pure.packChunks(kind, minis, limit).map((idxs) => {
    const items = idxs.map((k) => minis[k]);
    return kind === "tweakdefs" ? items.join("\n") : pure.mergeTweakUnits(items);
  });
}

describe("pure module API", () => {
  it("exports the browser-and-Node logic surface", () => {
    assert.deepEqual(Object.keys(pure), [
      "MAX_SLOTS", "getLimit", "b64encode", "b64decode", "luaMinify",
      "luaPrettify", "slotKey", "cmdPrefix", "buildCommand", "parseDecodeInput",
      "mergeTweakUnits", "planChunks", "packChunks", "findDuplicateDst", "findDuplicateDstDetails",
      "resetCommands", "resetAllCommands",
    ]);
    for (const name of ["b64encode", "b64decode", "luaMinify", "luaPrettify", "slotKey", "cmdPrefix", "buildCommand", "parseDecodeInput", "mergeTweakUnits", "planChunks", "packChunks", "findDuplicateDst", "findDuplicateDstDetails", "getLimit", "resetCommands", "resetAllCommands"]) {
      assert.equal(typeof pure[name], "function", name + " must be callable");
    }
    assert.equal(pure.MAX_SLOTS, 10);
  });
});

describe("b64 codec (UTF-8 safe)", () => {
  it("roundtrips ASCII exactly", () => {
    assert.equal(pure.b64decode(pure.b64encode("hello world")), "hello world");
  });
  it("roundtrips empty string", () => {
    assert.equal(pure.b64encode(""), "");
    assert.equal(pure.b64decode(""), "");
  });
  it("roundtrips UTF-8: CJK, emoji, mixed scripts", () => {
    for (const s of ["Ünïcodé ⚙.lua", "中文测试", "😀🎮✓", "Armada T3 — métal ×8", "a".repeat(5000) + "ß字😀"]) {
      assert.equal(pure.b64decode(pure.b64encode(s)), s, "roundtrip failed for: " + s.slice(0, 20));
    }
  });
  it("accepts URL-safe alphabet (-/_)", () => {
    // bytes 0xfb 0xef produce +/+ in std b64 → -/_ in url-safe
    const std = pure.b64encode("ûï");
    const urlSafe = std.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
    assert.equal(pure.b64decode(urlSafe), "ûï");
  });
  it("ignores whitespace/newlines in input", () => {
    const b64 = pure.b64encode("pack me please");
    const spaced = b64.slice(0, 4) + "  \n\t " + b64.slice(4, 8) + "\r\n" + b64.slice(8);
    assert.equal(pure.b64decode(spaced), "pack me please");
  });
  it("repairs missing padding", () => {
    const b64 = pure.b64encode("pad me");
    assert.equal(pure.b64decode(b64.replace(/=+$/, "")), "pad me");
  });
  it("throws on invalid input", () => {
    assert.throws(() => pure.b64decode("!!!not-base64!!!"), /./);
  });
  it("urlSafe flag emits Base64URL (no +/=, roundtrips)", () => {
    const out = pure.b64encode("hello world", true);
    assert.ok(!/[+/=]/.test(out), out);
    assert.equal(pure.b64decode(out), "hello world");
  });
  it("urlSafe swaps the full alphabet", () => {
    const std = pure.b64encode("\uFFFF");
    assert.ok(std.includes("+") && std.includes("/"), std);
    const url = pure.b64encode("\uFFFF", true);
    assert.ok(!/[+/]/.test(url) && url.includes("-") && url.includes("_"), url);
    assert.equal(pure.b64decode(url), "\uFFFF");
  });
  it("default stays standard padded base64", () => {
    assert.equal(pure.b64encode("hi"), "aGk=");
    assert.equal(pure.b64encode("hi", false), "aGk=");
    assert.equal(pure.b64encode("hi", true), "aGk");
  });
});

describe("luaMinify", () => {
  it("strips line comments but keeps code", () => {
    const out = pure.luaMinify("local a = 1 -- comment\nlocal b = 2");
    assert.ok(!out.includes("comment"), out);
    assert.ok(out.includes("local a=1") || out.includes("local a = 1"), out);
    assert.ok(out.includes("local b=2") || out.includes("local b = 2"), out);
  });
  it("strips long --[[...]] comments", () => {
    const out = pure.luaMinify("--[[ block\ncomment ]]local x=1");
    assert.equal(out, "local x=1");
  });
  it("strips long --[===[...]===] comments", () => {
    const out = pure.luaMinify("--[===[ deep ]===]local x=1");
    assert.equal(out, "local x=1");
  });
  it("preserves -- inside single/double-quoted strings", () => {
    const out = pure.luaMinify('local s="a -- not a comment"\nlocal t=\'b -- x\'');
    assert.ok(out.includes('"a -- not a comment"'), out);
    assert.ok(out.includes("'b -- x'"), out);
  });
  it("preserves long [[...]] string literals incl. comment-like text", () => {
    const src = "local s=[[hello -- not a comment, world]]\nlocal x=1";
    const out = pure.luaMinify(src);
    assert.ok(out.includes("[[hello -- not a comment, world]]"), out);
  });
  it("preserves levelled [==[...]==] strings containing [[...]] nests", () => {
    const src = "local s=[==[hello --[[ not a comment ]] world]==]\nlocal x=1";
    const out = pure.luaMinify(src);
    assert.ok(out.includes("[==[hello --[[ not a comment ]] world]==]"), out);
  });
  it("respects long-bracket levels for strings and comments", () => {
    const out = pure.luaMinify("local s=[=[a ]] --[[ inner ]] b]=] --[=[discard ]===] comment]=]\nlocal x=1");
    assert.ok(out.includes("[=[a ]] --[[ inner ]] b]=]"), out);
    assert.ok(out.includes("local x=1"), out);
    assert.ok(!out.includes("discard"), out);
  });
  it("preserves token boundaries when whitespace/comments are removed", () => {
    assert.equal(pure.luaMinify("local x = a - -- split minus\n - b"), "local x=a- -b");
    assert.equal(pure.luaMinify("local y = 1 .. 2"), "local y=1 ..2");
    assert.equal(pure.luaMinify("local z = 1; -- comment\n z = z + .5"), "local z=1;z=z+.5");
  });
  it("keeps exponent and hexadecimal numeric tokens intact", () => {
    assert.equal(pure.luaMinify("local a = 1.25e-3; local b = 0x1.fp+2"), "local a=1.25e-3;local b=0x1.fp+2");
  });
  it("collapses whitespace and drops spaces around symbols", () => {
    assert.equal(pure.luaMinify("local   a   =   1  +  2"), "local a=1+2");
  });
  it("keeps exactly one space between two word chars", () => {
    const out = pure.luaMinify("local  tech  =  1");
    assert.equal(out, "local tech=1");
  });

  it("removes only safe trailing Lua semicolons", () => {
    assert.equal(pure.luaMinify("local a = 1;\nif a then print(a); end;"), "local a=1;if a then print(a)end");
    assert.equal(pure.luaMinify("local a = 1; local b = 2;"), "local a=1;local b=2");
    assert.equal(pure.luaMinify("return { a = 1; };"), "return{a=1}");
  });
  it("prettifies Lua without changing literals or block structure", () => {
    const out = pure.luaPrettify("local s = 'a -- b'; if x then print(s); else print('no'); end");
    assert.match(out, /local s = 'a -- b'/);
    assert.match(out, /if x then\n/);
    assert.match(out, /\n  print\(s\)/);
    assert.match(out, /\nelse\n/);
    assert.match(out, /\nend$/);
  });
  it("handles empty / whitespace-only / comment-only input", () => {
    assert.equal(pure.luaMinify(""), "");
    assert.equal(pure.luaMinify("   \n\t  "), "");
    assert.equal(pure.luaMinify("-- only a comment"), "");
  });
  it("rejects unterminated quoted and long-bracket literals with source locations", () => {
    assert.throws(() => pure.luaMinify("local name = 'unfinished"), /Unterminated quoted string at line 1, column 14/);
    assert.throws(() => pure.luaMinify("local name = \"line one\nline two\""), /Unescaped newline in quoted string at line 1, column 14/);
    assert.throws(() => pure.luaMinify("local value = [==[unfinished"), /Unterminated long-bracket string at line 1, column 15/);
    assert.throws(() => pure.luaMinify("--[==[unfinished"), /Unterminated long-bracket comment at line 1, column 1/);
  });
  it("handles CRLF line comments and escaped physical newlines in strings", () => {
    assert.equal(pure.luaMinify("local value = 'one\\\r\ntwo' -- comment\r\nlocal next = 2"), "local value='one\\\r\ntwo'local next=2");
  });
  it("is deterministic (same input → identical bytes)", () => {
    const src = "for name,ud in pairs(UnitDefs) do -- loop\n  ud.metalcost=(ud.metalcost or 0)*2 end";
    assert.equal(pure.luaMinify(src), pure.luaMinify(src));
  });
});

describe("slot addressing + command builder", () => {
  it("slotKey: index 0 is bare, 1..9 suffixed", () => {
    assert.equal(pure.slotKey("tweakdefs", 0), "tweakdefs");
    assert.equal(pure.slotKey("tweakdefs", 1), "tweakdefs1");
    assert.equal(pure.slotKey("tweakunits", 9), "tweakunits9");
  });
  it("cmdPrefix shape", () => {
    assert.equal(pure.cmdPrefix("tweakdefs", 0), "!bset tweakdefs ");
    assert.equal(pure.cmdPrefix("tweakunits", 3), "!bset tweakunits3 ");
  });
  it("buildCommand: cmd = prefix + b64, decodes back to minified", () => {
    const min = pure.luaMinify("local a = 1 -- c");
    const r = pure.buildCommand("tweakdefs", 2, min);
    assert.equal(r.cmd, pure.cmdPrefix("tweakdefs", 2) + r.b64);
    assert.equal(pure.b64decode(r.b64), min);
  });
  it("numbered-slot prefix is 1 char longer (worst case for pack fits)", () => {
    assert.equal(pure.cmdPrefix("tweakdefs", 1).length - pure.cmdPrefix("tweakdefs", 0).length, 1);
  });
  it("MAX_SLOTS is 10", () => {
    assert.equal(pure.MAX_SLOTS, 10);
  });
});

describe("mergeTweakUnits", () => {
  it("merges two table sources into one brace pair", () => {
    const out = pure.mergeTweakUnits([
      "{ armpw = { metalcost = 10, }, }",
      "{ corak = { metalcost = 10, }, }",
    ]);
    assert.ok(out.startsWith("{") && out.endsWith("}"), out);
    assert.ok(out.includes("armpw") && out.includes("corak"), out);
    assert.equal(out.indexOf("{"), out.lastIndexOf("{") === 0 ? 0 : out.indexOf("{"), "single outer brace");
  });
  it("strips -- and --[[...]] comments before merging", () => {
    const out = pure.mergeTweakUnits(["-- head\n{ a = { x = 1, }, }", "--[[ b ]] { b = { y = 2, }, }"]);
    assert.ok(!out.includes("--"), out);
    assert.ok(out.includes("a =") && out.includes("b ="), out);
  });
  it("matches nested table braces without treating string/comment contents as delimiters", () => {
    const out = pure.mergeTweakUnits([
      "--[==[ ignored { braces } ]==]\n{ a = { label = 'literal } {', body = [=[also } {]=], }, }",
      "{ b = { value = 2, }, }",
    ]);
    assert.ok(out.startsWith("{") && out.endsWith("}"), out);
    assert.ok(out.includes("literal } {"), out);
    assert.ok(out.includes("[=[also } {]=]"), out);
    assert.ok(out.includes("b = { value = 2, }"), out);
  });
  it("rejects tweakunits sources that cannot be safely extracted as one table", () => {
    assert.throws(() => pure.mergeTweakUnits(["local units = { a = 1 }"]), /standalone tweakunits table/);
    assert.throws(() => pure.mergeTweakUnits(["{ a = 1 } extra"]), /Unexpected content after the tweakunits table/);
    assert.throws(() => pure.mergeTweakUnits(["{ a = { b = 1 }"]), /Unclosed '\{' in tweakunits table/);
  });
  it("skips empties; empty input yields empty table", () => {
    assert.equal(pure.mergeTweakUnits([]), "{  }");
    assert.equal(pure.mergeTweakUnits(["  ", "-- nothing"]), "{  }");
  });
});

describe("autopack sizing contract (limit 16384)", () => {
  it("reports individually oversized inputs without changing the chunks-only API", () => {
    const plan = pure.planChunks("tweakdefs", ["x".repeat(LIMIT * 2)], LIMIT);
    assert.equal(plan.chunks.length, 1);
    assert.deepEqual(plan.oversized, [0]);
    assert.deepEqual(plan.overflow, []);
    assert.ok(plan.sizes[0] > LIMIT);
    assert.deepEqual(pure.packChunks("tweakdefs", ["x".repeat(LIMIT * 2)], LIMIT), plan.chunks);
  });
  it("identifies every source beyond the ten-slot capacity", () => {
    const minis = Array.from({ length: 11 }, (_, i) => "x".repeat(9000) + i);
    const plan = pure.planChunks("tweakdefs", minis, LIMIT);
    assert.equal(plan.chunks.length, 11);
    assert.deepEqual(plan.overflow, [10]);
    assert.deepEqual(plan.oversized, []);
    assert.equal(plan.chunks.flat().length, minis.length);
  });
  it("reports exact final merged sizes for URL-safe tweakunits commands", () => {
    const minis = ["{ a = 1, }", "{ b = 2, }"];
    const plan = pure.planChunks("tweakunits", minis, LIMIT, true);
    assert.deepEqual(plan.oversized, []);
    assert.deepEqual(plan.overflow, []);
    const merged = pure.mergeTweakUnits(minis);
    assert.equal(plan.sizes[0], pure.buildCommand("tweakunits", 1, merged, true).cmd.length);
  });
  it("single small snippet packs into exactly 1 slot under limit", () => {
    const minis = [pure.luaMinify("local a=1")];
    const chunks = greedyPack(pure, "tweakdefs", minis, LIMIT);
    assert.equal(chunks.length, 1);
    for (let i = 0; i < chunks.length; i++) {
      const cmd = pure.buildCommand("tweakdefs", i, chunks[i]).cmd;
      assert.ok(cmd.length <= LIMIT, "cmd " + cmd.length + " > " + LIMIT);
    }
  });
  it("boundary: payload sized to the top b64 quantum still fits", () => {
    // b64 length is always a multiple of 4, so exact LIMIT fill is impossible
    // when (LIMIT - prefix) % 4 !== 0; target the top fitting quantum instead.
    const prefix = pure.cmdPrefix("tweakdefs", 1).length;
    const maxB64 = LIMIT - prefix - ((LIMIT - prefix) % 4);
    // b64 length for n bytes is 4*ceil(n/3); search n giving exactly maxB64.
    let body = null;
    for (let n = 3000; n < 20000; n++) {
      if (4 * Math.ceil(n / 3) === maxB64) {
        const candidate = "x" + "y".repeat(n - 2) + "z"; // word chars, minifier-stable
        if (pure.luaMinify(candidate).length === n) { body = candidate; break; }
      }
    }
    assert.ok(body, "could not construct top-quantum body");
    const chunks = greedyPack(pure, "tweakdefs", [body], LIMIT);
    assert.equal(chunks.length, 1);
    const cmd = pure.buildCommand("tweakdefs", 1, chunks[0]).cmd;
    assert.ok(cmd.length <= LIMIT, cmd.length + " > " + LIMIT);
    assert.ok(LIMIT - cmd.length < 4, "expected top quantum, slack " + (LIMIT - cmd.length));
  });
  it("boundary: one quantum over the limit stays solo and is flagged over", () => {
    const prefix = pure.cmdPrefix("tweakdefs", 1).length;
    const maxB64 = LIMIT - prefix - ((LIMIT - prefix) % 4);
    let n = null;
    for (let k = 3000; k < 20000; k++) {
      if (4 * Math.ceil(k / 3) === maxB64 + 4) { n = k; break; } // next b64 quantum
    }
    assert.ok(n, "no over-limit size found");
    const body = "x" + "y".repeat(n - 2) + "z";
    const chunks = greedyPack(pure, "tweakdefs", [body], LIMIT);
    assert.equal(chunks.length, 1); // kept solo (caller warns)
    // Worst-case (numbered-slot) prefix overflows; bare slot 0 fits exactly.
    const worst = pure.buildCommand("tweakdefs", 1, chunks[0]).cmd;
    assert.ok(worst.length > LIMIT, "expected over-limit, got " + worst.length);
    const bare = pure.buildCommand("tweakdefs", 0, chunks[0]).cmd;
    assert.equal(bare.length, LIMIT);
  });
  it("many small snippets combine; no chunk exceeds limit; order preserved", () => {
    const minis = [];
    for (let i = 0; i < 20; i++) minis.push(pure.luaMinify("local v" + i + " = " + i + " -- c" + i));
    const chunks = greedyPack(pure, "tweakdefs", minis, LIMIT);
    assert.ok(chunks.length >= 1 && chunks.length <= minis.length);
    for (let i = 0; i < chunks.length; i++) {
      const cmd = pure.buildCommand("tweakdefs", i, chunks[i]).cmd;
      assert.ok(cmd.length <= LIMIT, "chunk " + i + " over limit: " + cmd.length);
    }
    const flat = chunks.join("\n");
    for (let i = 0; i < 20; i++) assert.ok(flat.includes("local v" + i + "=" + i), "snippet " + i + " lost");
  });
  it("tweakunits path merges tables per chunk and stays under limit", () => {
    const minis = ["{ a" + "1".repeat(50) + " = { x = 1, }, }", "{ b2 = { y = 2, }, }", "{ c3 = { z = 3, }, }"];
    const chunks = greedyPack(pure, "tweakunits", minis, LIMIT);
    assert.ok(chunks.length >= 1);
    for (const c of chunks) {
      assert.ok(c.startsWith("{") && c.endsWith("}"), c);
      const cmd = pure.buildCommand("tweakunits", 0, c).cmd;
      assert.ok(cmd.length <= LIMIT);
    }
  });
});

describe("packChunks index contract + findDuplicateDst", () => {
  it("covers every input exactly once, in order", () => {
    const minis = [];
    for (let i = 0; i < 15; i++) minis.push(pure.luaMinify("local w" + i + " = " + i));
    const idxChunks = pure.packChunks("tweakdefs", minis, LIMIT);
    // Normalize to the host realm in case the implementation returns an
    // array-like value with a different prototype in a future browser build.
    const flat = JSON.parse(JSON.stringify(idxChunks)).flat();
    assert.deepEqual(flat, minis.map((_, i) => i));
  });
  it("chooses the fewest order-preserving chunks", () => {
    const minis = ["a", "b", "c"].map((x) => pure.luaMinify("-- " + x + "\n" + "x".repeat(28)));
    const chunks = pure.packChunks("tweakdefs", minis, 120);
    const flat = JSON.parse(JSON.stringify(chunks)).flat();
    assert.deepEqual(flat, [0, 1, 2]);
    assert.ok(chunks.length <= minis.length);
  });
  it("findDuplicateDst: flags dst claimed by 2+ sources", () => {
    const a = pure.luaMinify('{ dst = "armmoho_t3", src = "armmoho", }');
    const b = pure.luaMinify('{ dst = "cormoho_t3", src = "cormoho", }');
    const c = pure.luaMinify('{ dst = "armmoho_t3", src = "armmoho", }');
    assert.equal(JSON.stringify(pure.findDuplicateDst([a, b])), "[]");
    assert.equal(JSON.stringify(pure.findDuplicateDst([a, b, c])), '["armmoho_t3"]');
  });
  it("findDuplicateDst: repeat inside ONE source is not a duplicate", () => {
    const m = pure.luaMinify('u.explodeas = "x"\n{ dst = "solo", }\n{ dst = "solo", }');
    assert.equal(JSON.stringify(pure.findDuplicateDst([m])), "[]");
  });
  it("findDuplicateDst ignores string contents and reports source indexes for real fields", () => {
    const a = pure.luaMinify('{ dst = "shared", note = "dst = \\\"fake\\\"", }');
    const b = pure.luaMinify("{ dst = 'shared', }");
    assert.deepEqual(pure.findDuplicateDst([a, b]), ["shared"]);
    assert.deepEqual(pure.findDuplicateDstDetails([a, b]), [{ dst: "shared", sources: [0, 1] }]);
    assert.deepEqual(pure.findDuplicateDst([pure.luaMinify('{ note = "dst = \\\"alone\\\"", }')]), []);
  });
  it("live scenario: both defs fixtures combine into ONE slot", () => {
    const dir = path.join(__dirname, "fixtures");
    const files = fs.readdirSync(dir).filter((f) => f.startsWith("defs-")).sort();
    assert.ok(files.length >= 2, "need ≥2 defs fixtures");
    const minis = files.map((f) => pure.luaMinify(fs.readFileSync(path.join(dir, f), "utf8")));
    const chunks = greedyPack(pure, "tweakdefs", minis, LIMIT);
    assert.equal(chunks.length, 1, "expected 1 combined slot, got " + chunks.length);
    const cmd = pure.buildCommand("tweakdefs", 0, chunks[0]).cmd;
    assert.ok(cmd.length <= LIMIT, cmd.length + " > " + LIMIT);
    assert.equal(JSON.stringify(pure.findDuplicateDst(minis)), "[]");
  });
});

describe("resetCommands", () => {
  it("emits one '0' reset per slot, 10 total, bare slot first", () => {
    const cmds = Array.from(pure.resetCommands("tweakdefs"));
    assert.equal(cmds.length, 10);
    assert.equal(cmds[0], "!bset tweakdefs 0");
    assert.equal(cmds[9], "!bset tweakdefs9 0");
  });
  it("works for tweakunits", () => {
    const cmds = Array.from(pure.resetCommands("tweakunits"));
    assert.equal(cmds.length, 10);
    assert.equal(cmds[0], "!bset tweakunits 0");
    assert.equal(cmds[5], "!bset tweakunits5 0");
  });
  it("resetAllCommands clears both command groups in combined-copy order", () => {
    const cmds = Array.from(pure.resetAllCommands());
    assert.equal(cmds.length, 20);
    assert.equal(cmds[0], "!bset tweakunits 0");
    assert.equal(cmds[9], "!bset tweakunits9 0");
    assert.equal(cmds[10], "!bset tweakdefs 0");
    assert.equal(cmds[19], "!bset tweakdefs9 0");
  });
});

describe("collect/decode parser", () => {
  it("parses '!bset tweakdefsN <b64>' into key + payload", () => {
    const min = pure.luaMinify("local a = 1");
    const { cmd } = pure.buildCommand("tweakdefs", 4, min);
    const p = pure.parseDecodeInput(cmd);
    assert.equal(p.key, "tweakdefs4");
    assert.equal(pure.b64decode(p.b64), min);
  });
  it("is case-insensitive on !bset and tolerates extra spaces", () => {
    const p = pure.parseDecodeInput("!BSET   tweakunits2    QUJD");
    assert.equal(p.key, "tweakunits2");
    assert.equal(p.b64, "QUJD");
  });
  it("falls back to last token + unknown key for bare b64", () => {
    const p = pure.parseDecodeInput("QUJD");
    assert.equal(p.key, "(unknown key)");
    assert.equal(p.b64, "QUJD");
  });
  it("uses the final non-command token for an unrecognized input", () => {
    assert.deepEqual(pure.parseDecodeInput("not-a-bset-command\nQUJD"), {
      key: "(unknown key)", b64: "QUJD",
    }, "unrecognized input should retain the existing bare-payload fallback");
  });
  it("returns an empty payload for blank input", () => {
    assert.deepEqual(pure.parseDecodeInput(" \n\t "), {
      key: "(unknown key)", b64: "",
    });
  });
});

describe("getLimit fallback", () => {
  it("falls back to 16384 for empty/garbage/too-small values", () => {
    for (const v of ["", "abc", "0", "999", "-5", null, undefined]) {
      assert.equal(pure.getLimit(v), 16384, "value: " + String(v));
    }
  });
  it("honours valid custom limits >= 1000", () => {
    assert.equal(pure.getLimit("8000"), 8000);
    assert.equal(pure.getLimit("16384"), 16384);
  });
});

describe("minifier vs live-tweak fixtures (tests/fixtures/*.lua)", () => {
  const dir = path.join(__dirname, "fixtures");
  const files = fs.readdirSync(dir).filter((f) => f.endsWith(".lua")).sort();
  it("fixtures exist (copies of live tweaks/, never the live files)", () => {
    assert.ok(files.length >= 3, "expected ≥3 fixtures, got " + files.length);
    assert.ok(!path.resolve(dir).startsWith(path.resolve(__dirname, "..", "tweaks")));
  });
  for (const f of fs.readdirSync(path.join(__dirname, "fixtures")).filter((x) => x.endsWith(".lua")).sort()) {
    it("fixture " + f + ": minifies smaller, stays packable ≤16384, bytes stable", () => {
      const src = fs.readFileSync(path.join(dir, f), "utf8");
      const min = pure.luaMinify(src);
      assert.ok(min.length > 0, "minifier emptied " + f);
      assert.ok(min.length < src.length, f + ": " + min.length + " !< " + src.length);
      assert.equal(min, pure.luaMinify(src), "nondeterministic output");
      // Packer output bytes identical across runs (same pipeline, twice):
      const kind = f.startsWith("units-") ? "tweakunits" : "tweakdefs";
      const body = kind === "tweakunits" ? pure.mergeTweakUnits([min]) : min;
      const c1 = pure.buildCommand(kind, 0, body).cmd;
      const src2 = fs.readFileSync(path.join(dir, f), "utf8");
      const min2 = pure.luaMinify(src2);
      const body2 = kind === "tweakunits" ? pure.mergeTweakUnits([min2]) : min2;
      const c2 = pure.buildCommand(kind, 0, body2).cmd;
      assert.equal(c1, c2, "packer bytes unstable for " + f);
      assert.ok(c1.length <= LIMIT, f + " packed cmd " + c1.length + " exceeds " + LIMIT);
      assert.equal(pure.b64decode(c1.slice(pure.cmdPrefix(kind, 0).length)), body);
    });
  }
});

describe("perf smoke (size asserts primary, budgets warn unless PERF_STRICT=1)", () => {
  it("W1: minify ~50k chars ≤ 1000ms", () => {
    const line = "for name,ud in pairs(UnitDefs) do -- tweak\n  ud.metalcost = (ud.metalcost or 0) * 2 end\n";
    const src = line.repeat(Math.ceil(50000 / line.length));
    assert.ok(src.length >= 50000);
    const t0 = performance.now();
    const out = pure.luaMinify(src);
    perfCheck("W1 minify-50k", performance.now() - t0, 1000);
    assert.ok(out.length < src.length && out.length > 0);
  });
  it("W2: pack 60 snippets ≤ 2000ms", () => {
    const minis = [];
    for (let i = 0; i < 60; i++) minis.push(pure.luaMinify("local item" + i + " = " + i + " -- c"));
    const t0 = performance.now();
    const chunks = greedyPack(pure, "tweakdefs", minis, LIMIT);
    perfCheck("W2 pack-60", performance.now() - t0, 2000);
    assert.ok(chunks.length >= 1 && chunks.length <= 60);
  });
  it("W4: b64 ~64k chars ≤ 500ms", () => {
    const s = "Üñîcodé ⚙ test — ".repeat(Math.ceil(64000 / 18));
    const t0 = performance.now();
    const rt = pure.b64decode(pure.b64encode(s));
    perfCheck("W4 b64-64k", performance.now() - t0, 500);
    assert.equal(rt, s);
  });
});
