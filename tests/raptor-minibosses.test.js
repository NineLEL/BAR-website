"use strict";
const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { spawnSync } = require("node:child_process");
const pure = require("../app-pure");
const { assertDefaultEnabled, defaultEnabled } = require("./helpers/enabledTweaks");
const root = path.join(__dirname, "..");
const relative = "defs/raptorx/raptorx-miniboss-specialists.lua";
const source = fs.readFileSync(path.join(root, "tweaks", relative), "utf8");
const specs = [...source.matchAll(/\{"(raptor_matriarch_\w+)", "(raptorx_miniboss_\w+)", "([^"]+)", (\d+), "(\w+)", (\d+), (\d+), "([^"]+)"\}/g)];

test("five unique native mini-bosses have solo special squads and staged unlocks", () => {
  const known = new Set(JSON.parse(fs.readFileSync(path.join(__dirname, "bar-unit-names.json"), "utf8")));
  assert.equal(specs.length, 5);
  assert.equal(new Set(specs.map(s => s[2])).size, 5);
  assert.deepEqual(specs.map(s => Number(s[4])), [35, 45, 55, 65, 75]);
  for (const [, base, , , , behavior, hp, speed, description] of specs) {
    assert.ok(known.has(base), base);
    assert.ok(["berserk", "artillery", "raider"].includes(behavior));
    assert.ok(Number(hp) >= 160000 && Number(speed) > 0);
    assert.ok(description.length > 60);
  }
  assert.match(source, /cp\.raptorcustomsquad, cp\.raptorsquadrarity = "1", "special"/);
  assert.match(source, /cp\.raptorsquadunitsamount, cp\.raptorsquadweight = 1, 2/);
  assert.match(source, /cp\.raptorsquadminanger, cp\.raptorsquadmaxanger = spec\[4\], 150/);
  assert.doesNotMatch(source, /scavsquad|UnitDef_Post|u\.script\s*=|unit\.script\s*=|unit\.objectname\s*=/);
});

test("mini-boss pack is discoverable, enabled and fits either Base64 alphabet", () => {
  assertDefaultEnabled(relative);
  const temporaryRoot = fs.mkdtempSync(path.join(os.tmpdir(), "bar-miniboss-library-"));
  const tweaksDir = path.join(temporaryRoot, "tweaks");
  const server = require("../server").createServer({ root: temporaryRoot, tweaksDir });
  const libraryName = relative.slice("defs/".length);
  const stagedFile = path.join(tweaksDir, "defs", ...libraryName.split("/"));
  try {
    fs.mkdirSync(path.dirname(stagedFile), { recursive: true });
    fs.writeFileSync(stagedFile, source);
    fs.writeFileSync(path.join(tweaksDir, "state.json"),
      JSON.stringify({ [`defs/${libraryName}`]: defaultEnabled[relative] }));
    server.ensureDirs();
    const entry = server.listTweaks().defs.find(item => item.name === libraryName);
    assert.ok(entry, "server library should discover the packaged mini-boss definition");
    assert.equal(entry.enabled, true, "manifest-enabled mini-boss definition should be enabled in the isolated library");
    assert.equal(entry.content, source, "server library should expose the staged mini-boss source unchanged");
  } finally {
    fs.rmSync(temporaryRoot, { recursive: true, force: true });
  }
  const minified = pure.luaMinify(source);
  for (const urlSafe of [false, true]) {
    const command = pure.buildCommand("tweakdefs", 9, minified, urlSafe).cmd;
    assert.ok(command.length <= 16384, `${command.length} characters`);
    assert.equal(pure.b64decode(command.split(" ").at(-1)), minified);
  }
});

test("boss skills are backed by engine fields and BAR area-damage hooks", () => {
  assert.match(source, /weapons\.melee\.impulsefactor = 4/);
  assert.match(source, /unit\.autoheal = 900/);
  assert.match(source, /area\(weapons\.acidgoo, "acid", 18, 220, 150\)/);
  assert.match(source, /weapons\.goo\.paralyzer, weapons\.goo\.paralyzetime = true, 8/);
  assert.match(source, /cp\.paralyzemultiplier = 1/);
  assert.match(source, /area\(weapons\.flamethrowermain, "fire", 8, 140, 100\)/);
  for (const key of ["ceg", "damageceg", "time", "damage", "range", "resistance"]) {
    assert.ok(source.includes(`cp.area_onhit_${key}`));
  }
  assert.match(source, /"acid-damage-gen" or "burnthermite"/);
  assert.match(source, /unit\.cancloak, unit\.initcloak, unit\.stealth = true, true, true/);
  assert.match(source, /unit\.decloakonfire, unit\.cloaktimeout = true, 180/);
  assert.match(source, /unit\.builder, unit\.buildoptions, unit\.maxthisunit = false, \{\}, nil/);
  const hardening = fs.readFileSync(path.join(root, "tweaks/defs/raptorx/raptorx-unit-hardening.lua"), "utf8");
  assert.match(hardening, /not \(u\.customparams and u\.customparams\.raptorx_miniboss\)/);
});

const lua = process.env.LUA || "lua";
const probe = spawnSync(lua, ["-v"], { encoding: "utf8" });
test("Lua execution: clone isolation, mechanics, hardening and edge cases (raw + minified)", {
  skip: probe.error && !process.env.LUA ? "Lua is not installed; run lua tests/raptor-minibosses.lua for runtime coverage" : false,
}, () => {
  assert.ifError(probe.error);
  assert.equal(probe.status, 0, probe.stderr);
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "bar-miniboss-test-"));
  try {
    const minifiedPath = path.join(dir, "minibosses.lua");
     fs.writeFileSync(minifiedPath, pure.luaMinify(source));
    for (const input of [path.join(root, "tweaks", relative), minifiedPath]) {
      const result = spawnSync(lua, ["tests/raptor-minibosses.lua", input], { cwd: root, encoding: "utf8" });
      assert.ifError(result.error);
      assert.equal(result.status, 0, result.stdout + result.stderr);
      assert.match(result.stdout, /mini-boss runtime checks passed/);
    }
  } finally {
    fs.rmSync(dir, { recursive: true, force: true });
  }
});
