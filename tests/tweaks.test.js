"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const { spawnSync } = require("node:child_process");
const pure = require("../app-pure");

const ROOT = path.join(__dirname, "..");
const DEFS_DIR = path.join(ROOT, "tweaks", "defs");
const UNITS_DIR = path.join(ROOT, "tweaks", "units");
const KNOWN_UNITS = new Set(JSON.parse(fs.readFileSync(path.join(__dirname, "bar-unit-names.json"), "utf8")));
const LIMIT = pure.getLimit();

function luaFiles(dir) {
  const out = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...luaFiles(full));
    else if (entry.isFile() && entry.name.endsWith(".lua")) out.push(full);
  }
  return out.sort();
}

function rel(file) {
  return path.relative(path.join(ROOT, "tweaks"), file).replace(/\\/g, "/");
}

function cmdLen(kind, source, urlSafe = false) {
  const min = pure.luaMinify(source);
  const body = kind === "tweakunits" ? pure.mergeTweakUnits([min]) : min;
  return pure.buildCommand(kind, pure.MAX_SLOTS - 1, body, urlSafe).cmd.length;
}

describe("tweakdefs pack integrity", () => {
  const files = luaFiles(DEFS_DIR);

  it("every tweakdefs file minifies and fits a BAR command slot", () => {
    assert.ok(files.length > 0, "no tweakdefs files found");
    for (const file of files) {
      const len = cmdLen("tweakdefs", fs.readFileSync(file, "utf8"));
      assert.ok(len <= LIMIT, `${rel(file)}: ${len}/${LIMIT} chars`);
    }
  });

  it("every clone src = \"...\" names a known BAR unit", () => {
    const missing = [];
    for (const file of files) {
      const text = fs.readFileSync(file, "utf8");
      for (const [, name] of text.matchAll(/\bsrc\s*=\s*"([A-Za-z0-9_]+)"/g)) {
        if (!KNOWN_UNITS.has(name)) missing.push(`${rel(file)}: ${name}`);
      }
    }
    assert.deepEqual(missing, [], `unknown clone sources:\n${missing.join("\n")}`);
  });
});

describe("tweakunits pack integrity", () => {
  const files = luaFiles(UNITS_DIR);

  it("every tweakunits file is a valid standalone Lua table", () => {
    assert.ok(files.length > 0, "no tweakunits files found");
    for (const file of files) {
      const min = pure.luaMinify(fs.readFileSync(file, "utf8"));
      const merged = pure.mergeTweakUnits([min]);
      assert.ok(merged.startsWith("{") && merged.endsWith("}"), rel(file));
    }
  });

  it("RaptorX rosters fit one slot and use only Raptor squad keys", () => {
    const raptorDir = path.join(UNITS_DIR, "raptorx");
    const behaviors = new Set(["raider", "berserk", "artillery", "kamikaze", "healer"]);
    const seen = new Set();
    for (const file of luaFiles(raptorDir)) {
      const text = fs.readFileSync(file, "utf8");
      const len = cmdLen("tweakunits", text);
      assert.ok(len <= LIMIT, `${rel(file)}: ${len}/${LIMIT} chars`);
      assert.doesNotMatch(text, /\bscav(?:custom)?squad/, `${rel(file)} must not use scav squad keys`);
      for (const [, name, body] of text.matchAll(/^  (\w+) = \{([^\n]+)/gm)) {
        assert.ok(!seen.has(name), `duplicate RaptorX key: ${name}`);
        seen.add(name);
        assert.ok(name.startsWith("raptor_") || name.startsWith("raptorx_"), `${name} is not a Raptor unit`);
        assert.ok(KNOWN_UNITS.has(name) || name.startsWith("raptorx_"), `unknown BAR Raptor unit: ${name}`);
        const behavior = body.match(/raptorsquadbehavior = "(\w+)"/)?.[1];
        assert.ok(behaviors.has(behavior), `${name}: invalid behavior ${behavior}`);
        const min = Number(body.match(/raptorsquadminanger = (\d+)/)?.[1]);
        const max = Number(body.match(/raptorsquadmaxanger = (\d+)/)?.[1]);
        assert.ok(min >= 0 && min < max && max <= 150, `${name}: invalid anger window ${min}-${max}`);
      }
    }
    assert.ok(seen.size > 0, "RaptorX roster is empty");
  });

  it("ScavX rosters fit one slot and have valid squad metadata", () => {
    const scavxDir = path.join(UNITS_DIR, "scavx");
    const behaviors = new Set(["raider", "berserk", "artillery", "kamikaze", "healer"]);
    for (const file of luaFiles(scavxDir)) {
      const text = fs.readFileSync(file, "utf8");
      const len = cmdLen("tweakunits", text);
      assert.ok(len <= LIMIT, `${rel(file)}: ${len}/${LIMIT} chars`);
      for (const [, name, body] of text.matchAll(/^  (\w+) = \{([\s\S]*?)(?=^  \w+ = \{|^\})/gm)) {
        if (!body.includes("scavcustomsquad")) continue;
        const behavior = body.match(/scavsquadbehavior = "(\w+)"/)?.[1];
        assert.ok(behaviors.has(behavior), `${rel(file)} ${name}: invalid behavior ${behavior}`);
        const min = Number(body.match(/scavsquadminanger = (\d+)/)?.[1]);
        const max = Number(body.match(/scavsquadmaxanger = (\d+)/)?.[1]);
        assert.ok(min >= 0 && min < max && max <= 150, `${rel(file)} ${name}: invalid anger window ${min}-${max}`);
      }
    }
  });
});

const lua = process.env.LUA || "lua";
const probe = spawnSync(lua, ["-v"], { encoding: "utf8" });
const skipLua = probe.error && !process.env.LUA ? "lua not installed" : false;

describe("Lua runtime checks", { skip: skipLua }, () => {
  function runLua(script, arg) {
    const res = spawnSync(lua, [script, arg], { cwd: ROOT, encoding: "utf8" });
    assert.ifError(res.error);
    assert.equal(res.status, 0, res.stdout + res.stderr);
    return res.stdout;
  }

  it("raptor mini-boss specialists execute cleanly (raw and minified)", (t) => {
    const srcPath = path.join(DEFS_DIR, "raptorx", "raptorx-miniboss-specialists.lua");
    assert.match(runLua("tests/raptor-minibosses.lua", srcPath), /mini-boss runtime checks passed/);

    const os = require("node:os");
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), "bar-miniboss-"));
    t.after(() => fs.rmSync(dir, { recursive: true, force: true }));
    const minPath = path.join(dir, "min.lua");
    fs.writeFileSync(minPath, pure.luaMinify(fs.readFileSync(srcPath, "utf8")));
    assert.match(runLua("tests/raptor-minibosses.lua", minPath), /mini-boss runtime checks passed/);
  });

  it("player mega land pack executes cleanly", () => {
    const srcPath = path.join(DEFS_DIR, "player", "megas", "player-mega-land-pack.lua");
    assert.match(runLua("tests/player-mega-land-pack.lua", srcPath), /mega land runtime checks passed/);
  });
});
