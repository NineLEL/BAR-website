// Guards against phantom clone sources: every `src = "..."` in tweaks/defs/**/*.lua
// must name a real BAR unit (see bar-unit-names.json snapshot). A wrong src is
// either silently skipped (missing unit) or, worse, clones a different unit that
// happens to share the key (e.g. a wall), producing broken in-game units.
// Regenerate the snapshot from BAR master when the roster changes.
const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const defsDir = path.join(__dirname, "..", "tweaks", "defs");
const known = new Set(JSON.parse(fs.readFileSync(path.join(__dirname, "bar-unit-names.json"), "utf8")));
function luaFiles(dir) {
  const out = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...luaFiles(full));
    else if (entry.isFile() && entry.name.endsWith(".lua")) out.push(full);
  }
  return out;
}

test("every tweak clone src exists in BAR", () => {
  const files = luaFiles(defsDir).sort();
  assert.ok(files.length > 0, "no tweak files found");
  const missing = [];
  for (const f of files) {
    const src = fs.readFileSync(f, "utf8");
    const re = /\bsrc\s*=\s*"([A-Za-z0-9_]+)"/g;
    let m;
    while ((m = re.exec(src)) !== null) {
       if (!known.has(m[1])) missing.push(`${path.relative(defsDir, f)}: ${m[1]}`);
    }
  }
  assert.deepEqual(missing, [], `unknown clone sources:\n${missing.join("\n")}`);
});

// This data-only tweak uses two-space top-level keys. Inspect the roster without
// executing Lua or touching live state; this is not a replacement for an in-game run.
function nightmareRoster() {
  const entries = nightmareSources().flatMap((text) =>
    [...text.matchAll(/^  (\w+) = \{([\s\S]*?)(?=^  \w+ = \{|^\})/gm)]);
  const roster = new Map(entries.map(([, name, body]) => [name, body]));
  assert.ok(entries.length > 0, "Nightmare roster is empty");
  assert.equal(roster.size, entries.length, "duplicate Nightmare unit keys");
  return roster;
}

function nightmareSources() {
  return ["ScavXNightmare.lua", "ScavXNightmare-support.lua"].map((name) =>
    fs.readFileSync(path.join(__dirname, "..", "tweaks", "units", "scavx", name), "utf8"));
}

test("Nightmare files each fit the BAR command limit", () => {
  const pure = require("./helpers/loadPure").loadPure();
  for (const text of nightmareSources()) {
    const encoded = pure.b64encode(pure.luaMinify(text));
    assert.ok((pure.cmdPrefix("tweakunits", 9) + encoded).length <= 16384,
      "Nightmare file exceeds a numbered tweakunits command slot");
  }
});

test("Nightmare unit keys resolve to BAR units or our ScavX clones", () => {
  const clones = new Set();
  for (const file of luaFiles(path.join(defsDir, "scavx"))) {
    const text = fs.readFileSync(file, "utf8");
    for (const [, name] of text.matchAll(/local n = "(\w+)"/g)) clones.add(name);
  }
  for (const name of nightmareRoster().keys()) {
    assert.ok(known.has(name) || clones.has(name), `unknown Nightmare unit: ${name}`);
  }
});

test("Nightmare includes our mobile ScavX heavies and additional combined arms", () => {
  const roster = nightmareRoster();
  const additions = [
    "busters", "fatherbehe", "kingchimera", "ratteking", "thetyrannus",
    "titaniator", "quincy", "walkingfort", "wallnut",
    "armstump", "corraid", "armrock", "corstorm", "armzeus", "corsumo",
    "armmerl", "corvroc", "armliche", "corhurc", "armroy", "corroy", "armsptkt4",
  ];
  for (const name of additions) {
    assert.match(roster.get(name) || "", /scavcustomsquad = "1"/, `${name} needs a squad`);
  }
  for (const name of ["everyexpe", "t3builder", "t1metalgenerator", "t2metalgenerator",
    "epicwall", "epicsanctuary", "t5sanctuary", "pulsinator", "decimator"]) {
    assert.doesNotMatch(roster.get(name) || "", /scavcustomsquad/, `${name} is not a combat squad`);
  }
  assert.match(roster.get("armsptkt4"), /adv_rocket = \{ reloadtime = 3 \}/,
    "preserve the existing T4 spider weapon buff");
});

test("Nightmare squad metadata has valid behaviors, anger windows and spawn weights", () => {
  const behaviors = new Set(["raider", "berserk", "artillery", "kamikaze", "healer"]);
  for (const [name, body] of nightmareRoster()) {
    if (!body.includes("scavcustomsquad")) continue;
    const number = (key) => {
      const match = body.match(new RegExp(`\\b${key} = (\\d+(?:\\.\\d+)?)`));
      assert.ok(match, `${name}: missing numeric ${key}`);
      return Number(match[1]);
    };
    assert.ok(behaviors.has(body.match(/scavsquadbehavior = "(\w+)"/)?.[1]), `${name}: behavior`);
    assert.match(body, /scavsquadrarity = "(?:basic|special)"/, `${name}: rarity`);
    const min = number("scavsquadminanger");
    const max = number("scavsquadmaxanger");
    assert.ok(min >= 0 && min < max && max <= 150, `${name}: anger window`);
    assert.equal(number("scavsquadbehaviorchance"), 1, `${name}: behavior chance`);
    for (const key of ["scavsquadunitsamount", "scavsquadweight", "scavsquadbehaviordistance"]) {
      const value = number(key);
      assert.ok(Number.isInteger(value) && value > 0, `${name}: ${key}`);
    }
  }
});

test("Rift Colossus is gated until 55% anger", () => {
  const body = nightmareRoster().get("armbanth");
  assert.match(body || "", /scavsquadminanger = 55/, "armbanth/Rift Colossus must start at 55% anger");
});

test("Scav AI smarts is enabled and has tactical role coverage", () => {
  const file = path.join(__dirname, "..", "tweaks", "units", "scav", "scav-ai-smarts.lua");
  const body = fs.readFileSync(file, "utf8");
  assert.equal(JSON.parse(fs.readFileSync(path.join(__dirname, "..", "tweaks", "state.json"), "utf8"))["units/scav/scav-ai-smarts.lua"], true);
  for (const role of ["scavsquadbehavior = \"raider\"", "scavsquadbehavior = \"artillery\"", "scavsquadbehavior = \"healer\""]) {
    assert.match(body, new RegExp(role.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")), `missing tactical role: ${role}`);
  }
  for (const unit of ["armspy", "armjam", "armsehak", "armliche", "armcroc"]) {
    assert.match(body, new RegExp(`\\b${unit}\\s*=\\s*\\{[\\s\\S]*?scavcustomsquad`), `${unit} needs a tactical squad`);
  }
});

function raptorSources() {
  return ["RaptorX.lua", "RaptorX-support.lua"].map((name) =>
    fs.readFileSync(path.join(__dirname, "..", "tweaks", "units", "raptorx", name), "utf8"));
}

function raptorRoster() {
  const entries = raptorSources().flatMap((text) =>
    [...text.matchAll(/^  (raptor_\w+) = \{([\s\S]*?)(?=^  raptor_\w+ = \{|^\})/gm)]);
  const roster = new Map(entries.map(([, name, body]) => [name, body]));
  assert.ok(entries.length > 0, "RaptorX roster is empty");
  assert.equal(roster.size, entries.length, "duplicate RaptorX unit keys");
  return roster;
}

test("RaptorX files are enabled, packable and use actual Raptor units", () => {
  const state = JSON.parse(fs.readFileSync(path.join(__dirname, "..", "tweaks", "state.json"), "utf8"));
  assert.equal(state["units/raptorx/RaptorX.lua"], true);
  assert.equal(state["units/raptorx/RaptorX-support.lua"], true);
  const pure = require("./helpers/loadPure").loadPure();
  for (const text of raptorSources()) {
    assert.ok((pure.cmdPrefix("tweakunits", 9) + pure.b64encode(pure.luaMinify(text))).length <= 16384);
    for (const [, name] of text.matchAll(/^  (\w+) = \{/gm)) {
      assert.ok(name.startsWith("raptor_") || name.startsWith("raptorx_"), `${name} is not a Raptor unit`);
      assert.ok(known.has(name) || name.startsWith("raptorx_"), `${name} is not in the BAR roster or custom pack`);
    }
  }
});

test("RaptorX custom definitions are enabled, verified and wired into squads", () => {
  const definition = fs.readFileSync(path.join(__dirname, "..", "tweaks", "defs", "raptorx", "raptorx-custom-units-core.lua"), "utf8");
  const state = JSON.parse(fs.readFileSync(path.join(__dirname, "..", "tweaks", "state.json"), "utf8"));
  assert.equal(state["defs/raptorx/raptorx-custom-units-core.lua"], true);
  const specs = [...definition.matchAll(/\{"(raptor_\w+)","(raptorx_\w+)"/g)];
  assert.equal(specs.length, 25, "expected twenty-five Raptor custom definitions");
  const destinations = new Set();
  for (const [, source, destination] of specs) {
    assert.ok(known.has(source), `${source} is not a verified BAR Raptor unit`);
    assert.equal(destinations.has(destination), false, `duplicate custom unit: ${destination}`);
    destinations.add(destination);
    assert.match(definition, /UnitDefs\[s\[2\]\] = unit/);
    assert.match(definition, new RegExp(`"${destination}"`));
  }
  const roster = new Map(raptorSources().flatMap((text) =>
    [...text.matchAll(/^  (\w+) = \{([\s\S]*?)(?=^  \w+ = \{|^\})/gm)].map(([, unit, body]) => [unit, body])));
  for (const destination of destinations) assert.match(roster.get(destination) || "", /raptorcustomsquad/);
  assert.match(definition, /unit\.buildoptions = \{\}/, "custom Raptors must not be builder-exposed");
  for (const unit of ["raptorx_razorclaw", "raptorx_stormmaw", "raptorx_broodlord"]) {
    assert.match(raptorSources().join("\n"), new RegExp(`^  ${unit} = \\{`, "m"), `${unit} needs a spammable squad`);
  }
  for (const unit of ["raptorx_ironfang", "raptorx_dreadrunner", "raptorx_burnmaw"]) {
    assert.match(raptorSources().join("\n"), new RegExp(`^  ${unit} = \\{`, "m"), `${unit} needs an early squad`);
  }
  const pure = require("./helpers/loadPure").loadPure();
  assert.ok((pure.cmdPrefix("tweakdefs", 9) + pure.b64encode(pure.luaMinify(definition))).length <= 16384,
    "Raptor custom definitions exceed a numbered tweakdefs command slot");
});

test("RaptorX squad metadata and progression are valid", () => {
  const behaviors = new Set(["raider", "berserk", "artillery", "kamikaze", "healer"]);
  const roster = raptorRoster();
  for (const [name, body] of roster) {
    assert.equal(body.match(/raptorsquadbehavior = "(\w+)"/)?.[1] && behaviors.has(body.match(/raptorsquadbehavior = "(\w+)"/)[1]), true, `${name}: behavior`);
    const n = (key) => Number(body.match(new RegExp(`\\b${key} = (\\d+(?:\\.\\d+)?)`))?.[1]);
    assert.ok(n("raptorsquadbehaviorchance") === 1 && n("raptorsquadunitsamount") > 0 && n("raptorsquadweight") > 0 && n("raptorsquadbehaviordistance") > 0, `${name}: squad values`);
    assert.ok(n("raptorsquadminanger") >= 0 && n("raptorsquadminanger") < n("raptorsquadmaxanger") && n("raptorsquadmaxanger") <= 150, `${name}: anger window`);
  }
  assert.ok((roster.get("raptor_land_assault_basic_t4_v1") || "").includes("raptorsquadminanger = 65"));
  assert.ok((roster.get("raptor_queen_hard") || "").includes("raptorsquadminanger = 110"));
  const allRaptorUnits = raptorSources().join("\n");
  assert.match(allRaptorUnits, /raptorx_razorclaw[\s\S]*?raptorsquadunitsamount = 14/);
  assert.match(allRaptorUnits, /raptorx_stormmaw[\s\S]*?raptorsquadunitsamount = 10/);
  assert.match(allRaptorUnits, /raptorx_broodlord[\s\S]*?raptorsquadunitsamount = 5/);
  assert.match(allRaptorUnits, /raptorx_ironfang[\s\S]*?raptorsquadminanger = 8/);
  assert.match(allRaptorUnits, /raptorx_dreadrunner[\s\S]*?raptorsquadunitsamount = 18/);
  assert.match(allRaptorUnits, /raptorx_burnmaw[\s\S]*?raptorsquadminanger = 18/);
  for (const unit of ["raptorx_apex_colossus", "raptorx_spectre_overlord", "raptorx_queen_ascendant"]) {
    assert.match(allRaptorUnits, new RegExp(`${unit}[\\s\\S]*?raptorsquadunitsamount = 1`), `${unit} must spawn alone`);
  }
  assert.match(allRaptorUnits, /raptorx_queen_ascendant[\s\S]*?raptorsquadminanger = 145/);
  assert.match(allRaptorUnits, /raptorx_overmatriarch[\s\S]*?raptorsquadminanger = 75/);
  assert.match(allRaptorUnits, /raptorx_overmatriarch[\s\S]*?raptorsquadunitsamount = 3/);
  assert.match(allRaptorUnits, /raptorx_elderqueen[\s\S]*?raptorsquadminanger = 105/);
  assert.match(allRaptorUnits, /raptorx_elderqueen[\s\S]*?raptorsquadunitsamount = 2/);
  for (const unit of ["raptorx_earlycrusher", "raptorx_earlytalon", "raptorx_midravager", "raptorx_midfirewing", "raptorx_latebehemoth", "raptorx_lateskyreaper"]) {
    assert.match(allRaptorUnits, new RegExp(`${unit}[\\s\\S]*?raptorcustomsquad = "1"`), `${unit} needs a squad`);
  }
  assert.match(allRaptorUnits, /raptorx_earlycrusher[\s\S]*?raptorsquadminanger = 5/);
  assert.match(allRaptorUnits, /raptorx_midravager[\s\S]*?raptorsquadminanger = 35/);
  assert.match(allRaptorUnits, /raptorx_latebehemoth[\s\S]*?raptorsquadminanger = 75/);
  assert.match(allRaptorUnits, /raptorx_earlytalon[\s\S]*?raptorsquadunitsamount = 12/);
  assert.match(allRaptorUnits, /raptorx_midfirewing[\s\S]*?raptorsquadunitsamount = 8/);
  assert.match(allRaptorUnits, /raptorx_lateskyreaper[\s\S]*?raptorsquadunitsamount = 4/);
});

test("RaptorX uses the native Raptors squad metadata keys", () => {
  const text = raptorSources().join("\n");
  assert.match(text, /raptorcustomsquad = "1"/);
  assert.match(text, /raptorsquadminanger = \d+/);
  assert.match(text, /raptorsquadunitsamount = \d+/);
  assert.doesNotMatch(text, /scavcustomsquad|scavsquad(?:behavior|unitsamount|weight|maxanger|minanger)/,
    "RaptorX must not use Scavenger squad keys");
});

test("RaptorX custom units have explicit weapon mechanics and effects", () => {
  const text = fs.readFileSync(path.join(__dirname, "..", "tweaks", "defs", "raptorx", "raptorx-artillery-pack.lua"), "utf8");
  for (const mechanic of ["range = 2700", "burst = 7", "paralyzer = true", "paralyzetime = 8", "disruption = true"]) {
    assert.match(text, new RegExp(mechanic.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")), `missing mechanic: ${mechanic}`);
  }
  assert.match(text, /custom:exp_emp_large/);
  assert.match(text, /custom:genericshellexplosion-large/);
  assert.match(text, /custom:exp_emp_large/);
  for (const weapon of ["siege", "cluster", "empmortar"]) {
    assert.match(text, new RegExp(`${weapon} = \\{`), `missing artillery weapon identity: ${weapon}`);
  }
});

test("Aegis Breaker has explicit shotgun projectile behavior", () => {
  const text = fs.readFileSync(path.join(__dirname, "..", "tweaks", "defs", "player", "megas", "player-mega-pack.lua"), "utf8");
  const body = text.match(/crack = W\([\s\S]*?\n\s*\}\),\n\s*sol =/u)?.[0] || "";
  assert.match(body, /projectilespershot = 8/);
  assert.match(body, /burst = 2/);
  assert.match(body, /burstrate = 0\.08/);
  assert.match(body, /sprayangle = 850/);
  assert.match(body, /customparams = \{ shotgun = true/);
});

test("Mirror Array is configured as the Prism Disruptor", () => {
  const text = fs.readFileSync(path.join(__dirname, "..", "tweaks", "defs", "player", "turrets", "player-ultra-turret-pack-2.lua"), "utf8");
  const start = text.indexOf('"player_mirrorarray"');
  const end = text.indexOf('"player_voidvortex"');
  const body = start >= 0 && end > start ? text.slice(start, end) : "";
  assert.match(body, /"Prism Disruptor"/);
  assert.match(body, /weapontype = "BeamLaser"/);
  assert.match(body, /paralyzer = true/);
  assert.match(body, /paralyzetime = 5/);
  assert.doesNotMatch(body, /"Mirror Array"/);
});
