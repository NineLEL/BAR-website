"use strict";
const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const pure = require("../app-pure");
const { assertDefaultEnabled } = require("./helpers/enabledTweaks");
const root = path.join(__dirname, "..");
const relative = "defs/scavx/scavx-unit-hardening.lua";
const source = fs.readFileSync(path.join(root, "tweaks", relative), "utf8");
const ids = source.match(/string\.gmatch\("([^"]+)"/)[1].split(" ");

test("hardening covers all ScavX combat clones but not economy or builders", () => {
  const excluded = new Set(["everyexpe", "t3builder", "t1metalgenerator", "t2metalgenerator", "epicwall"]);
  const dir = path.join(root, "tweaks", "defs", "scavx");
  const clones = fs.readdirSync(dir).filter((file) => /^scavx-custom-unit-pack-\d+\.lua$/.test(file))
    .flatMap((file) => [...fs.readFileSync(path.join(dir, file), "utf8").matchAll(/local n = "(\w+)"/g)].map((m) => m[1]));
  assert.deepEqual([...ids].sort(), clones.filter((id) => !excluded.has(id)).sort());
  assert.equal(new Set(ids).size, ids.length);
  assert.ok(ids.every((id) => !id.startsWith("player_") && !id.startsWith("raptor_")));
});

test("hardening is enabled after imported packs and fits a command slot", () => {
  assertDefaultEnabled(relative);
  for (let i = 0; i < 7; i++) {
    const imported = `defs/scavx/scavx-custom-unit-pack-${String(i).padStart(2, "0")}.lua`;
    assertDefaultEnabled(imported);
    assert.ok(imported < relative);
  }
  assert.ok(pure.buildCommand("tweakdefs", 9, pure.luaMinify(source), false).cmd.length <= 16384);
});

test("hardening preserves mechanics and guards against repeated multiplication", () => {
  assert.match(source, /if not u\.customparams\.scavx_hardened then/);
  assert.match(source, /not seen\[u\]/);
  assert.match(source, /not weaponsSeen\[w\]/);
  assert.match(source, /u\.health = u\.health \* 2/);
  assert.match(source, /damage \* 1\.6/);
  assert.match(source, /w\.reloadtime \* 0\.8/);
  assert.match(source, /shield\[field\] \* 1\.5/);
  assert.doesNotMatch(source, /scavsquad\w+\s*=|\.range\s*=|\.buildoptions\s*=|\.energypershot\s*=/);
});

test("extreme final boss covers current and legacy difficulty variants safely", () => {
  const relative = "defs/scavx/scavx-final-boss-extreme.lua";
  const lua = fs.readFileSync(path.join(root, "tweaks", relative), "utf8");
  assertDefaultEnabled(relative);
  assert.match(lua, /"scavengerbossv4_", "armscavengerbossv2_"/);
  for (const difficulty of ["veryeasy", "easy", "normal", "hard", "veryhard", "epic"]) {
    assert.ok(lua.includes(`"${difficulty}"`));
  }
  const weapons = lua.match(/local combat = \{([\s\S]*?)\n  \}/)[1];
  assert.doesNotMatch(weapons, /sensor_|setting_turbo_delay|special_botcannon/);
  assert.match(lua, /if not u\.customparams\.scavx_extreme_boss then/);
  assert.match(lua, /u\.health \* 12/);
  assert.match(lua, /u\.speed = u\.speed \* 3\s/);
  assert.match(lua, /u\.maxacc = u\.maxacc \* 6/);
  assert.match(lua, /u\.maxdec = u\.maxdec \* 6/);
  assert.match(lua, /u\.turnrate = u\.turnrate \* 3/);
  assert.match(lua, /damage \* 4/);
  assert.match(lua, /volley \+ 0\.05/);
  assert.match(lua, /w\.range < 10000/);
  assert.doesNotMatch(lua, /u\.weapons\s*=|u\.script\s*=|u\.objectname\s*=|scavsquad\w+\s*=/);
  assert.ok(pure.buildCommand("tweakdefs", 9, pure.luaMinify(lua), false).cmd.length <= 16384);
});

test("all Scav-only Mega squads spawn three units starting at 20 percent anger", () => {
  const lua = fs.readFileSync(path.join(root, "tweaks/units/scavx/scavx-nightmare-hardmode-roster.lua"), "utf8");
  const expected = {
    riftcolossus: [20, 900], riftjump: [30, 875], vortexdominator: [20, 900],
    vortexwell: [25, 850], aegisbreaker: [40, 950], solardecimator: [20, 900],
    skyfurnace: [40, 950], stormsovereign: [30, 950], pyroclast: [30, 950],
    worldbeam: [20, 900], singularity: [25, 900], aethersiege: [20, 900],
    phantomleviathan: [25, 1000], archangel: [40, 1000],
  };
  const entries = [...lua.matchAll(/scavx_mega_(\w+) = \{ customparams = \{([^\n]+)\} \},/g)];
  assert.equal(entries.length, Object.keys(expected).length);
  for (const [, name, body] of entries) {
    assert.ok(expected[name], name);
    assert.match(body, /scavsquadunitsamount = 3\b/);
    assert.match(body, new RegExp(`scavsquadweight = ${expected[name][1]}\\b`));
    assert.match(body, /scavsquadrarity = "basic"/);
    assert.match(body, /scavsquadminanger = 20, scavsquadmaxanger = 150/);
  }
  assert.ok(pure.buildCommand("tweakunits", 9, pure.luaMinify(lua), false).cmd.length <= 16384);
});

test("enemy Mega definitions have existing sources, isolated weapons and no player build path", () => {
  const relative = "defs/scavx/scavx-mega-enemy-variants.lua";
  const lua = fs.readFileSync(path.join(root, "tweaks", relative), "utf8");
  const player = fs.readFileSync(path.join(root, "tweaks/defs/player/megas/player-mega-units.lua"), "utf8");
  const defined = new Set([...player.matchAll(/^\s*"(player_\w+)",/gm)].map(m => m[1]));
  const specs = [...lua.matchAll(/\{ "(scavx_(?:mega|boss)_\w+)", "(player_\w+)"/g)];
  assert.equal(specs.length, 17);
  assert.equal(new Set(specs.map(m => m[1])).size, 17);
  for (const [, , source] of specs) assert.ok(defined.has(source), `missing source ${source}`);
  assert.match(lua, /local u = copy\(source\)/);
  assert.match(lua, /u\.maxthisunit, u\.buildoptions, u\.builder = nil, nil, false/);
  assert.match(lua, /hp, damage, reload, speed, shield = 3, 2, 0\.7, 1\.2, 2\.5/);
  assert.match(lua, /hp, damage, reload, speed, shield = 10, 4, 0\.55, 1\.5, 5/);
  assert.match(lua, /volley \+ 0\.05/);
  assert.doesNotMatch(lua, /source\.\w+\s*=|teach\(|u\.script\s*=|u\.objectname\s*=|u\.weapons\s*=/);
  assertDefaultEnabled(relative);
  assertDefaultEnabled("defs/player/megas/player-mega-units.lua");
  assert.ok("defs/player/megas/player-mega-units.lua" < relative);
  assert.ok(pure.buildCommand("tweakdefs", 9, pure.luaMinify(lua), false).cmd.length <= 16384);
});

test("three distinct boss-class waves stay rare and solo", () => {
  const lua = fs.readFileSync(path.join(root, "tweaks/units/scavx/scavx-nightmare-hardmode-roster.lua"), "utf8");
  const entries = [...lua.matchAll(/scavx_boss_(\w+) = \{ customparams = \{([^\n]+)\} \},/g)];
  assert.equal(entries.length, 3);
  for (const [, , body] of entries) {
    assert.match(body, /scavsquadunitsamount = 1,/);
    assert.match(body, /scavsquadrarity = "special"/);
    assert.ok(Number(body.match(/scavsquadminanger = (\d+)/)[1]) >= 55);
  }
});
