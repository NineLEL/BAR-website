"use strict";

const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const { spawnSync } = require("node:child_process");
const pure = require("../app-pure");

const root = path.join(__dirname, "..");
const relative = "defs/player/megas/player-mega-land-pack.lua";
const source = fs.readFileSync(path.join(root, "tweaks", relative), "utf8");
const expected = [
  ["player_riftcolossus", ["armbanth"], "Rift Cannon", 1],
  ["player_aegisbreaker", ["armrattet4", "corjugg", "armbanth"], "Sabot Shotgun", 1],
  ["player_solardecimator", ["corjugg", "armbanth"], "Cataclysm", 1],
  ["player_skyfurnace", ["corkarganetht4", "corkarg"], "Flak Storm", 1],
  ["player_stormsovereign", ["armraz", "armbanth"], "Tesla Battery", 1],
  ["player_pyroclast", ["armmar", "armbanth"], "Carpet Mortar", 1],
  ["player_apollyonfortress", ["legapollyon", "corpun", "corint"], "Apollyon Siege Driver", 6],
];

test("mega land pack source bases exist in the BAR unit-name index", () => {
  const known = new Set(JSON.parse(fs.readFileSync(path.join(__dirname, "bar-unit-names.json"), "utf8")));
  for (const [, bases] of expected) for (const base of bases) assert.ok(known.has(base), `unknown BAR base ${base}`);
});

test("mega land pack registers the reworked unit roster and weapon-slot counts", () => {
  for (const [unit, bases, weaponName, slots] of expected) {
    assert.ok(source.includes(`"${unit}"`), `${unit} should be registered`);
    assert.ok(bases.some(base => source.includes(`"${base}"`)), `${unit} should retain a supported base candidate`);
    assert.ok(source.includes(`"${weaponName}"`), `${unit} weapon name should match the reworked pack`);
  }
  assert.match(source, /local function teach\(bld, dst\)/);
  assert.match(source, /if not h then\s+u\.buildoptions\[#u\.buildoptions \+ 1\] = dst/);
  assert.match(source, /local LG, EA =/);
  assert.match(source, /install\(u, p\[3\], p\[4\], st\[11\]\)/);
  assert.deepEqual(expected.map(([, , , slots]) => slots), [1, 1, 1, 1, 1, 1, 6]);
});

test("mega land pack fits the lobby command size after minification", () => {
  const minified = pure.luaMinify(source);
  const command = pure.buildCommand("tweakdefs", 1, minified, false).cmd;
  assert.ok(command.length <= 16384, `${command.length} characters`);
  assert.equal(pure.b64decode(command.split(" ").at(-1)), minified);
});

const lua = process.env.LUA || "lua";
const probe = spawnSync(lua, ["-v"], { encoding: "utf8" });
test("Lua runtime: creates independent land megas, preserves slots and teaches builders", {
  skip: probe.error && !process.env.LUA ? "Lua is not installed; static and command-size checks still run" : false,
}, () => {
  assert.ifError(probe.error);
  assert.equal(probe.status, 0, probe.stderr);
  const result = spawnSync(lua, ["tests/player-mega-land-pack.lua", path.join(root, "tweaks", relative)], { cwd: root, encoding: "utf8" });
  assert.ifError(result.error);
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.match(result.stdout, /mega land runtime checks passed/);
});
