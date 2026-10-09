// Guards against phantom clone sources: every `src = "..."` in tweaks/defs/**/*.lua
// must name a real BAR unit (see bar-unit-names.json snapshot). A wrong src is
// either silently skipped (missing unit) or, worse, clones a different unit that
// happens to share the key (e.g. a wall), producing broken in-game units.
// Regenerate the snapshot from BAR master when the roster changes.
const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const { loadPure } = require("./helpers/loadPure");

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
  return ["scavx-nightmare-ground-roster.lua", "scavx-nightmare-support-roster.lua", "scavx-nightmare-hardmode-roster.lua"].map((name) =>
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
    for (const [, name] of text.matchAll(/\{ "(scavx_(?:mega|boss)_\w+)", "player_\w+"/g)) clones.add(name);
  }
  const megaText = fs.readFileSync(path.join(__dirname, "..", "tweaks", "defs", "player", "megas", "player-mega-units.lua"), "utf8");
  for (const [, name] of megaText.matchAll(/\n\s*"(player_[a-z0-9]+)",/g)) clones.add(name);
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

test("ScavX hard mode adds distinct supported mechanics", () => {
  const text = fs.readFileSync(path.join(__dirname, "..", "tweaks", "units", "scavx", "scavx-nightmare-hardmode-roster.lua"), "utf8");
  for (const behavior of ["raider", "healer", "berserk", "artillery"]) {
    assert.match(text, new RegExp(`scavsquadbehavior = \\\"${behavior}\\\"`));
  }
  assert.match(text, /projectilespershot = 6/);
  assert.match(text, /paralyzer = true, paralyzetime = 7/);
  assert.match(text, /cancloak = true/);
  assert.match(text, /radarjamdistance = 650/);
  assert.match(text, /builddistance = 300, workertime = 600/);
  assert.match(text, /burst = 3, burstrate = 0\.25/);
  assert.doesNotMatch(text, /shield_power|shield_radius/);
  const state = JSON.parse(fs.readFileSync(path.join(__dirname, "..", "tweaks", "state.json"), "utf8"));
  assert.equal(state["units/scavx/scavx-nightmare-hardmode-roster.lua"], true);
});

test("Late-game T3/T4 units begin at 35% anger", () => {
  const body = nightmareRoster().get("armbanth");
  assert.match(body || "", /scavsquadminanger = 35/, "armbanth/Rift Colossus must start at 35% anger");
  for (const name of ["armpwt4", "armrattet4", "legfort", "legfortt4", "legmost3", "corjugg", "busters", "fatherbehe", "kingchimera", "ratteking", "thetyrannus", "titaniator", "quincy", "walkingfort", "wallnut"]) {
    assert.match(nightmareRoster().get(name) || "", /scavsquadminanger = 35/, `${name} must start at 35% anger`);
  }
});

test("T4 Nightmare units spawn in reinforced squads", () => {
  const roster = nightmareRoster();
  const minimums = {
    armbanth: 110, armpwt4: 90, armrattet4: 70, legfortt4: 65, corjugg: 65,
    busters: 40, fatherbehe: 28, kingchimera: 5, ratteking: 6, thetyrannus: 18,
    titaniator: 50, quincy: 36, walkingfort: 18, wallnut: 10,
  };
  for (const [name, minimum] of Object.entries(minimums)) {
    const match = (roster.get(name) || "").match(/scavsquadunitsamount = (\d+)/);
    assert.ok(match, `${name} needs a squad size`);
    assert.ok(Number(match[1]) >= minimum, `${name} squad should be at least ${minimum}`);
  }
});

test("ScavX mega units have frequent reinforced spawns", () => {
  const roster = nightmareRoster();
  const minimums = {
    busters: [60, 210], fatherbehe: [42, 210], kingchimera: [8, 220],
    ratteking: [9, 200], thetyrannus: [27, 220], titaniator: [75, 220],
    quincy: [54, 230], walkingfort: [27, 230], wallnut: [15, 190],
  };
  for (const [name, [units, weight]] of Object.entries(minimums)) {
    const body = roster.get(name) || "";
    assert.match(body, new RegExp(`scavsquadunitsamount = ${units}`), `${name} needs a larger squad`);
    assert.match(body, new RegExp(`scavsquadweight = ${weight}`), `${name} needs a higher spawn weight`);
  }
});

test("Scav-only Mega variants replace player Mega Units in ScavX squads", () => {
  const roster = nightmareRoster();
  const megaIds = [
    "player_riftcolossus", "player_riftjump", "player_vortexdominator", "player_vortexwell",
    "player_aegisbreaker", "player_solardecimator", "player_skyfurnace", "player_stormsovereign",
    "player_pyroclast", "player_worldbeam", "player_singularity", "player_aethersiege",
    "player_phantomleviathan", "player_archangel",
  ];
  assert.ok(megaIds.length >= 14, "expected the player mega pack roster");
  for (const name of megaIds) {
    assert.equal(roster.has(name), false, `${name} must stay player-only`);
    const body = roster.get(name.replace("player_", "scavx_mega_")) || "";
    assert.match(body, /scavcustomsquad = "1"/, `${name} needs a ScavX squad entry`);
    assert.match(body, /scavsquadunitsamount = \d+/, `${name} needs a squad size`);
    assert.match(body, /scavsquadweight = \d+/, `${name} needs a spawn weight`);
  }
});

test("Everything Experimental exposes every player Mega Unit", () => {
  const text = fs.readFileSync(path.join(__dirname, "..", "tweaks", "defs", "scavx", "scavx-custom-unit-pack-01.lua"), "utf8");
  const megaIds = [
    "player_riftcolossus", "player_riftjump", "player_vortexdominator", "player_vortexwell",
    "player_aegisbreaker", "player_solardecimator", "player_skyfurnace", "player_stormsovereign",
    "player_pyroclast", "player_worldbeam", "player_singularity", "player_aethersiege",
    "player_phantomleviathan", "player_archangel",
  ];
  assert.match(text, /local megaUnits = \{/);
  for (const name of megaIds) {
    assert.match(text, new RegExp(`"${name}"`), `${name} must be available from everyexpe`);
  }
  assert.equal(JSON.parse(fs.readFileSync(path.join(__dirname, "..", "tweaks", "state.json"), "utf8"))["defs/player/megas/player-mega-units.lua"], true);
});

test("Scav AI smarts is enabled and has tactical role coverage", () => {
  const file = path.join(__dirname, "..", "tweaks", "units", "scav", "scav-tactical-ai.lua");
  const body = fs.readFileSync(file, "utf8");
  assert.equal(JSON.parse(fs.readFileSync(path.join(__dirname, "..", "tweaks", "state.json"), "utf8"))["units/scav/scav-tactical-ai.lua"], true);
  for (const role of ["scavsquadbehavior = \"raider\"", "scavsquadbehavior = \"artillery\"", "scavsquadbehavior = \"healer\""]) {
    assert.match(body, new RegExp(role.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")), `missing tactical role: ${role}`);
  }
  for (const unit of ["armspy", "armjam", "armsehak", "armliche", "armcroc"]) {
    assert.match(body, new RegExp(`\\b${unit}\\s*=\\s*\\{[\\s\\S]*?scavcustomsquad`), `${unit} needs a tactical squad`);
  }
});

function raptorSources() {
  return ["raptorx-assault-roster.lua", "raptorx-support-roster.lua"].map((name) =>
    fs.readFileSync(path.join(__dirname, "..", "tweaks", "units", "raptorx", name), "utf8"));
}

function raptorRoster() {
  const entries = raptorSources().flatMap((text) =>
    [...text.matchAll(/^  (raptor(?:x)?_\w+) = \{([^\n]+)/gm)]);
  const roster = new Map(entries.map(([, name, body]) => [name, body]));
  assert.ok(entries.length > 0, "RaptorX roster is empty");
  assert.equal(roster.size, entries.length, "duplicate RaptorX unit keys");
  return roster;
}

test("RaptorX files are enabled, packable and use actual Raptor units", () => {
  const state = JSON.parse(fs.readFileSync(path.join(__dirname, "..", "tweaks", "state.json"), "utf8"));
  assert.equal(state["units/raptorx/raptorx-assault-roster.lua"], true);
  assert.equal(state["units/raptorx/raptorx-support-roster.lua"], true);
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
  const definition = fs.readFileSync(path.join(__dirname, "..", "tweaks", "defs", "raptorx", "raptorx-custom-unit-core.lua"), "utf8");
  const state = JSON.parse(fs.readFileSync(path.join(__dirname, "..", "tweaks", "state.json"), "utf8"));
  assert.equal(state["defs/raptorx/raptorx-custom-unit-core.lua"], true);
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
  assert.match(definition, /unit\.unitname, unit\.name = s\[2\], s\[3\]/);
  assert.match(definition, /unit\.description = "\?\?\?"/, "all RaptorX custom units must have a mystery description");
  assert.match(definition, /local languages = \{ "en", "de", "fr", "es", "it", "ru", "zh", "cs", "hr", "lt" \}/);
  assert.match(definition, /cp\["i18n_" \..*\] = s\[3\]/, "localized Raptor names must use the custom display name");
  assert.match(definition, /cp\["i18n_" \..*"_tooltip"\] = unit\.description/, "localized tooltips must use the mystery description");
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
  assert.ok((roster.get("raptor_land_assault_basic_t4_v1") || "").includes("raptorsquadminanger = 35"));
  assert.ok((roster.get("raptor_queen_hard") || "").includes("raptorsquadminanger = 75"));
  const allRaptorUnits = raptorSources().join("\n");
  assert.match(allRaptorUnits, /raptorx_razorclaw[^\n]*raptorsquadunitsamount = 42/);
  assert.match(allRaptorUnits, /raptorx_stormmaw[^\n]*raptorsquadunitsamount = 20/);
  assert.match(allRaptorUnits, /raptorx_broodlord[^\n]*raptorsquadunitsamount = 10/);
  assert.match(allRaptorUnits, /raptorx_ironfang[\s\S]*?raptorsquadminanger = 20/);
  assert.match(allRaptorUnits, /raptorx_dreadrunner[^\n]*raptorsquadunitsamount = 54/);
  assert.match(allRaptorUnits, /raptorx_burnmaw[\s\S]*?raptorsquadminanger = 30/);
  for (const unit of ["raptorx_apex_colossus", "raptorx_spectre_overlord", "raptorx_queen_ascendant"]) {
    assert.match(allRaptorUnits, new RegExp(`${unit}[\\s\\S]*?raptorsquadunitsamount = 1`), `${unit} must spawn alone`);
  }
  assert.match(allRaptorUnits, /raptorx_queen_ascendant[^\n]*raptorsquadminanger = 100/);
  assert.match(allRaptorUnits, /raptorx_overmatriarch[^\n]*raptorsquadminanger = 70/);
  assert.match(allRaptorUnits, /raptorx_overmatriarch[^\n]*raptorsquadunitsamount = 6/);
  assert.match(allRaptorUnits, /raptorx_elderqueen[^\n]*raptorsquadminanger = 80/);
  assert.match(allRaptorUnits, /raptorx_elderqueen[^\n]*raptorsquadunitsamount = 4/);
  for (const unit of ["raptorx_earlycrusher", "raptorx_earlytalon", "raptorx_midravager", "raptorx_midfirewing", "raptorx_latebehemoth", "raptorx_lateskyreaper"]) {
    assert.match(allRaptorUnits, new RegExp(`${unit}[\\s\\S]*?raptorcustomsquad = "1"`), `${unit} needs a squad`);
  }
  assert.match(allRaptorUnits, /raptorx_earlycrusher[\s\S]*?raptorsquadminanger = 10/);
  assert.match(allRaptorUnits, /raptorx_midravager[^\n]*raptorsquadminanger = 30/);
  assert.match(allRaptorUnits, /raptorx_latebehemoth[^\n]*raptorsquadminanger = 40/);
  assert.match(allRaptorUnits, /raptorx_earlytalon[^\n]*raptorsquadunitsamount = 36/);
  assert.match(allRaptorUnits, /raptorx_midfirewing[^\n]*raptorsquadunitsamount = 16/);
  assert.match(allRaptorUnits, /raptorx_lateskyreaper[^\n]*raptorsquadunitsamount = 8/);

  const customTiers = new Map([...roster]
    .filter(([name]) => name.startsWith("raptorx_"))
    .map(([name, body]) => [name, Number(body.match(/raptorsquadminanger = (\d+)/)?.[1])]));
  const core = fs.readFileSync(path.join(__dirname, "..", "tweaks", "defs", "raptorx", "raptorx-custom-unit-core.lua"), "utf8");
  const coreTiers = new Map([...core.matchAll(/^\s*(raptorx_\w+) = \{"\w+",(\d+),/gm)]
    .map(([, name, anger]) => [name, Number(anger)]));
  assert.equal(customTiers.size, 25);
  assert.equal(coreTiers.size, customTiers.size);
  for (const [name, anger] of customTiers) assert.equal(coreTiers.get(name), anger, `${name}: core and roster anger tiers differ`);
  for (let anger = 10; anger <= 100; anger += 10) {
    assert.ok([...customTiers.values()].includes(anger), `missing RaptorX unlock at ${anger}% anger`);
  }
  assert.equal(Number(roster.get("raptor_land_swarmer_basic_t1_v1").match(/raptorsquadminanger = (\d+)/)?.[1]), 0,
    "0-9% anger should retain the baseline Raptor wave");
});

test("RaptorX uses the native Raptors squad metadata keys", () => {
  const text = raptorSources().join("\n");
  assert.match(text, /raptorcustomsquad = "1"/);
  assert.match(text, /raptorsquadminanger = \d+/);
  assert.match(text, /raptorsquadunitsamount = \d+/);
  assert.doesNotMatch(text, /scavcustomsquad|scavsquad(?:behavior|unitsamount|weight|maxanger|minanger)/,
    "RaptorX must not use Scavenger squad keys");
});

test("RaptorX custom clones get stronger hardening without further buffing base Raptors", () => {
  const text = fs.readFileSync(path.join(__dirname, "..", "tweaks", "defs", "raptorx", "raptorx-unit-hardening.lua"), "utf8");
  assert.match(text, /local customUnit = name:sub\(1, 8\) == "raptorx_"/);
  assert.match(text, /if customUnit then\s+hp, damage, reload, speed, floor = hp \* 2, damage \* 2, reload \* 0\.85, speed \* 1\.1, floor \* 2/);
  assert.match(text, /local hp, damage, reload, speed, floor = 20, 6, 0\.65, 1\.2, 200000/);
});

test("RaptorX custom squads outweight default Raptor squads", () => {
  const text = fs.readFileSync(path.join(__dirname, "..", "tweaks", "defs", "raptorx", "raptorx-unit-hardening.lua"), "utf8");
  assert.match(text, /local bias = customUnit and 3 or 0\.4/);
  assert.match(text, /if minimumAnger < 25 then\s+bias = customUnit and 1\.5 or 0\.75/);
  assert.match(text, /squadData\.raptorsquadweight = math\.max\(1, math\.floor\(weight \* bias \+ 0\.5\)\)/);
  assert.match(text, /not squadData\.raptorx_squadweight_adjusted/);
});

test("RaptorX custom units scale health and damage at every 10% anger tier", () => {
  const text = fs.readFileSync(path.join(__dirname, "..", "tweaks", "defs", "raptorx", "raptorx-unit-hardening.lua"), "utf8");
  assert.match(text, /local angerTier = math\.min\(10, math\.floor\(minimumAnger \/ 10\)\)/);
  assert.match(text, /local angerScale = customUnit and \(1\.25 \^ angerTier\) or 1/);
  assert.match(text, /u\.health = math\.max\(health \* hp, floor\) \* angerScale/);
  assert.match(text, /w\.damage\[armor\] = value \* damage \* angerScale/);
});

test("RaptorX custom units have explicit weapon mechanics and effects", () => {
  const text = fs.readFileSync(path.join(__dirname, "..", "tweaks", "defs", "raptorx", "raptorx-siege-artillery.lua"), "utf8");
  for (const mechanic of ["range = 10200", "burst = 7", "paralyzer = true", "paralyzetime = 12", "disruption = true"]) {
    assert.match(text, new RegExp(mechanic.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")), `missing mechanic: ${mechanic}`);
  }
  assert.match(text, /custom:exp_emp_large/);
  assert.match(text, /custom:genericshellexplosion-large/);
  assert.match(text, /custom:exp_emp_large/);
  for (const weapon of ["siege", "cluster", "empmortar"]) {
    assert.match(text, new RegExp(`${weapon} = \\{`), `missing artillery weapon identity: ${weapon}`);
  }
});

test("Phantom Leviathan uses its three corcrwh slots for combat and shielding", () => {
  const text = fs.readFileSync(path.join(__dirname, "..", "tweaks", "defs", "player", "megas", "player-mega-units.lua"), "utf8");
  assert.match(text, /pshield\s*=\s*\{/);
  assert.match(text, /weapontype\s*=\s*"Shield"/);
  assert.match(text, /slots\s*=\s*\{\s*\[1\]\s*=\s*WEAPONS\.torpedo,\s*\[2\]\s*=\s*WEAPONS\.pshield,\s*\[3\]\s*=\s*WEAPONS\.pbarrage/);
  assert.match(text, /u\.cancloak, u\.cloakable, u\.initcloaked = true, true, true/);
  assert.match(text, /u\.customparams\.stealthhealth = 0\.35/);
  assert.match(text, /{ 220e3, 48e5, 42e4, 72, 4, 3200, 0, 420, 0, true }/);
});

test("all player turret packs significantly reduce energy costs", () => {
  for (const file of ["player-turrets-ultra.lua", "player-turrets-ultra-advanced.lua"]) {
    const text = fs.readFileSync(path.join(__dirname, "..", "tweaks", "defs", "player", "turrets", file), "utf8");
    assert.match(text, /TURRET_ENERGY_FACTOR\s*=\s*0\.25/);
    assert.match(text, /energyupkeep, u\.energyuse = st\[[56]\] \* TURRET_ENERGY_FACTOR/);
    assert.match(text, /weapon\.energypershot = weapon\.energypershot \* TURRET_ENERGY_FACTOR/);
  }
});

test("Needle Swarm is a fast-tracking long-range AA interceptor", () => {
  const text = fs.readFileSync(path.join(__dirname, "..", "tweaks", "defs", "player", "turrets", "player-turrets-ultra.lua"), "utf8");
  const start = text.indexOf('"player_needleswarm"');
  const end = text.indexOf("-- 3. BLACKOUT CASCADE", start);
  assert.ok(start >= 0 && end > start, "Needle Swarm spec was not found");
  const body = text.slice(start, end);
  assert.ok(known.has("armmercury") && known.has("corscreamer"), "AA turret donor units must exist in BAR");
  assert.match(body, /\{\s*"armmercury",\s*"corscreamer"\s*\}/, "must use stationary AA missile turret sources");
  assert.match(body, /installWeapon\(u, src, 1, "NEEDLE_SWARM"/);
  assert.match(body, /"Fast-tracking long-range AA missiles"/);
  assert.match(body, /weapontype = C_MSL/);
  assert.match(body, /range = 3200/);
  assert.match(body, /reloadtime = 1\.8/);
  assert.match(body, /burst = 6/);
  assert.match(body, /burstrate = 0\.08/);
  assert.match(body, /tracks = true/);
  assert.match(body, /turnrate = 200e3/);
  assert.match(body, /dance = 0/);
  assert.match(body, /wobble = 0/);
  assert.match(body, /onlytargetcategory = T_V/);
  assert.match(text, /created\[#created \+ 1\] = spec\[1\]/);
  assert.match(text, /teach\(BUILDERS, unitName\)/, "generated turret must flow into builder build menus");
});

test("player ultra turrets pack into one BAR command", () => {
  const pure = loadPure();
  const source = fs.readFileSync(path.join(__dirname, "..", "tweaks", "defs", "player", "turrets", "player-turrets-ultra.lua"), "utf8");
  const minified = pure.luaMinify(source);
  const command = pure.buildCommand("tweakdefs", 1, minified, true).cmd;
  assert.ok(command.length <= pure.getLimit(), `${command.length}/${pure.getLimit()} characters`);
});

test("slot preview buttons capture their own command and minified text", () => {
  const text = fs.readFileSync(path.join(__dirname, "..", "app.js"), "utf8");
  assert.match(text, /\}\)\(cmd, pre, showCmd\);/);
  assert.match(text, /\}\)\(min, prev2, pv\);/);
});

test("Aegis Breaker has explicit shotgun projectile behavior", () => {
  const text = fs.readFileSync(path.join(__dirname, "..", "tweaks", "defs", "player", "megas", "player-mega-units.lua"), "utf8");
  const body = text.match(/crack = W\([\s\S]*?\n\s*\}\),\n\s*sol =/u)?.[0] || "";
  assert.match(body, /projectilespershot = 8/);
  assert.match(body, /burst = 2/);
  assert.match(body, /burstrate = 0\.08/);
  assert.match(body, /sprayangle = 850/);
  assert.match(body, /customparams = \{ shotgun = true/);
});

test("Mirror Array is configured as the Prism Disruptor", () => {
  const text = fs.readFileSync(path.join(__dirname, "..", "tweaks", "defs", "player", "turrets", "player-turrets-ultra-advanced.lua"), "utf8");
  const start = text.indexOf('"player_mirrorarray"');
  const end = text.indexOf('"player_voidvortex"');
  const body = start >= 0 && end > start ? text.slice(start, end) : "";
  assert.match(body, /"Prism Disruptor"/);
  assert.match(body, /weapontype = "BeamLaser"/);
  assert.match(body, /paralyzer = true/);
  assert.match(body, /paralyzetime = 5/);
  assert.doesNotMatch(body, /"Mirror Array"/);
});
