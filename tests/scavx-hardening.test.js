"use strict";
const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const { loadPure } = require("./helpers/loadPure");
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
  const state = JSON.parse(fs.readFileSync(path.join(root, "tweaks", "state.json"), "utf8"));
  assert.equal(state[relative], true);
  for (let i = 0; i < 7; i++) {
    const imported = `defs/scavx/scavx-custom-unit-pack-${String(i).padStart(2, "0")}.lua`;
    assert.equal(state[imported], true);
    assert.ok(imported < relative);
  }
  const pure = loadPure();
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
