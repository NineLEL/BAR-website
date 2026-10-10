"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const pure = require("../app-pure");
const root = path.join(__dirname, "..");
const release = fs.readFileSync(path.join(root, "ScavX_Commands_SunlessK (1).txt"), "utf8");
const commands = [...release.matchAll(/^!bset (tweak(?:defs|units)\d*) ([A-Za-z0-9+/_=-]+)/gm)];

// Restored tables omit some optional trailing commas. Never normalize literals.
function normalize(lua) {
  return pure.luaMinify(lua).replace(/"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|,}/g,
    (token) => token === ",}" ? "}" : token);
}

test("ScavX restored imports match the new release and remain packable", () => {
  assert.equal(commands.length, 8, "expected all eight upstream commands");
  const expected = ["tweakunits", "tweakdefs", ...Array.from({ length: 6 }, (_, i) => `tweakdefs${i + 1}`)];
  assert.deepEqual(commands.map((command) => command[1]), expected);
  for (const [i, command] of commands.entries()) {
    const relative = i === 0 ? "units/scavx/scavx-standard-overrides.lua"
      : `defs/scavx/scavx-custom-unit-pack-${String(i - 1).padStart(2, "0")}.lua`;
    const restored = fs.readFileSync(path.join(root, "tweaks", relative), "utf8");
    const upstream = Buffer.from(command[2], "base64").toString("utf8");
    let comparable = restored;
    if (i === 2) {
      // The sole local import extension adds player Megas to everyexpe after
      // its creation. Separate build-menu tests cover this retained hook.
      const hook = /\t\t\t-- player-mega-units[\s\S]*?(?=\t\tend\r?\n\tend)/;
      assert.match(comparable, hook, "preserve the local Mega build-menu hook");
      comparable = comparable.replace(hook, "");
    }
    assert.equal(normalize(comparable), normalize(upstream), `${relative}: upstream drift`);
    const kind = i === 0 ? "tweakunits" : "tweakdefs";
    const encoded = pure.buildCommand(kind, 9, pure.luaMinify(restored), false).cmd;
    assert.ok(encoded.length <= 16384, `${relative}: encoded command exceeds BAR limit`);
  }
});
