-- Representative native Raptor fixtures for unique RaptorX enemies, not a Spring simulation.
local pack = arg[1] or "tweaks/defs/raptorx/raptorx-unique-enemies.lua"
local function copy(v)
  if type(v) ~= "table" then return v end
  local out = {}
  for k, child in pairs(v) do out[k] = copy(child) end
  return out
end
local function equal(a, b)
  if type(a) ~= type(b) then return false end
  if type(a) ~= "table" then return a == b end
  for k, v in pairs(a) do if not equal(v, b[k]) then return false end end
  for k in pairs(b) do if a[k] == nil then return false end end
  return true
end
local bases = {
  "raptor_land_spiker_spectre_t4_v1",
  "raptor_land_assault_emp_t2_v1",
  "raptor_allterrain_arty_brood_t4_v1",
  "raptor_allterrain_arty_basic_t4_v1",
  "raptor_air_gunship_emp_t2_v1",
  "raptor_land_swarmer_fire_t4_v1",
  "raptor_air_bomber_brood_t4_v2",
  "raptor_allterrain_arty_emp_t4_v1",
}
local function fixture(name)
  local canfly = name:find("_air_", 1, true) ~= nil
  return {
    health = 8000, speed = 80, builder = false, canfly = canfly,
    customparams = { israptor = true, paralyzemultiplier = 0 },
    weapons = { { def = "WEAPON" } },
    weapondefs = { weapon = { range = 400, reloadtime = 5, damage = { default = 100 } } },
  }
end
UnitDefs = {}
for _, b in ipairs(bases) do UnitDefs[b] = fixture(b) end
local originals = copy(UnitDefs)
assert(loadfile(pack))()

local expected = {
  raptorx_voidlance_piercer = { base = "raptor_land_spiker_spectre_t4_v1", anger = 45, behavior = "skirmisher", slots = 1 },
  raptorx_arcweaver_conduit = { base = "raptor_land_assault_emp_t2_v1", anger = 50, behavior = "berserk", slots = 2 },
  raptorx_broodscatter_mortar = { base = "raptor_allterrain_arty_brood_t4_v1", anger = 55, behavior = "artillery", slots = 1 },
  raptorx_pyreburst_lobber = { base = "raptor_allterrain_arty_basic_t4_v1", anger = 60, behavior = "artillery", slots = 1 },
  raptorx_tempest_swooper = { base = "raptor_air_gunship_emp_t2_v1", anger = 65, behavior = "raider", slots = 1 },
  raptorx_miasma_crawler = { base = "raptor_land_swarmer_fire_t4_v1", anger = 70, behavior = "berserk", slots = 3 },
  raptorx_abyssal_skynest = { base = "raptor_air_bomber_brood_t4_v2", anger = 75, behavior = "raider", slots = 1 },
  raptorx_chronovore_apex = { base = "raptor_allterrain_arty_emp_t4_v1", anger = 85, behavior = "artillery", slots = 1 },
}

for id, spec in pairs(expected) do
  assert(equal(UnitDefs[spec.base], originals[spec.base]), spec.base .. " mutated")
  local u = assert(UnitDefs[id], id .. " missing")
  assert(u.unitname == id and u.builder == false and next(u.buildoptions) == nil)
  assert(u.customparams.raptorcustomsquad == "1" and u.customparams.raptorsquadminanger == spec.anger)
  assert(u.customparams.raptorsquadbehavior == spec.behavior)
  assert(#u.weapons == spec.slots, id .. " slot count")
  for _, slot in ipairs(u.weapons) do
    local w = assert(u.weapondefs[string.lower(slot.def)], id .. " missing weapondef " .. slot.def)
    assert(w.reloadtime >= ((w.burst or 1) - 1) * (w.burstrate or 0) + 0.05)
  end
end

-- Verify specific gadget hooks.
local lance = UnitDefs.raptorx_voidlance_piercer
assert(lance.cancloak and lance.initcloak and lance.stealth and lance.decloakonfire)
assert(lance.weapondefs.voidlance.impactonly and lance.weapondefs.voidlance.noexplode)
assert(lance.weapondefs.voidlance.customparams.overpenetrate == true)

local arc = UnitDefs.raptorx_arcweaver_conduit
assert(arc.weapondefs.arclance.weapontype == "LightningCannon")
assert(arc.weapondefs.arclance.customparams.spark_forkdamage == "0.55")
assert(arc.weapons[2].onlytargetcategory == "VTOL")

local mortar = UnitDefs.raptorx_broodscatter_mortar
assert(mortar.weapondefs.splitpod.customparams.speceffect == "split")
assert(mortar.weapondefs.splitpod.customparams.speceffect_def == "raptorx_broodscatter_mortar_hatchpod")
assert(mortar.weapondefs.hatchpod.customparams.spawns_name)

local pyre = UnitDefs.raptorx_pyreburst_lobber
assert(pyre.weapondefs.pyreshell.customparams.cluster_def == "pyre_bomblet")
assert(pyre.weapondefs.pyre_bomblet.weapontype == "Cannon")
assert(pyre.weapondefs.pyre_bomblet.customparams.area_onhit_ceg == "fire-area-75-repeat")

local miasma = UnitDefs.raptorx_miasma_crawler
assert(miasma.customparams.area_ondeath_ceg == "fire-area-150-repeat")
assert(miasma.weapondefs.acid_sector.customparams.speceffect == "sector_fire")
assert(miasma.weapondefs.thermite_maw.weapontype == "Flame")
assert(miasma.weapons[3].onlytargetcategory == "VTOL")

local skynest = UnitDefs.raptorx_abyssal_skynest
assert(skynest.canfly == true and skynest.weapondefs.vanguard_pods.weapontype == "AircraftBomb")
assert(skynest.weapondefs.vanguard_pods.customparams.spawns_mode == "sequential")

local apex = UnitDefs.raptorx_chronovore_apex
assert(apex.customparams.area_ondeath_ceg == "acid-area-200-repeat")
assert(apex.weapondefs.chrono_shell.paralyzer == true)
assert(apex.weapondefs.chrono_shell.customparams.cluster_def == "chrono_shard")
assert(not apex.weapondefs.chrono_shard.paralyzer)

-- Idempotent repeat application.
local before = copy(UnitDefs)
assert(loadfile(pack))()
assert(equal(before, UnitDefs), "repeat application changed definitions")

-- Compatible with hardening pack without violating burst/reload invariants.
assert(loadfile("tweaks/defs/raptorx/raptorx-unit-hardening.lua"))()
for id in pairs(expected) do
  local u = assert(UnitDefs[id])
  assert(u.customparams.raptorx_ultra_hardened == 1, id .. " should harden cleanly")
  for _, w in pairs(u.weapondefs) do
    if type(w.reloadtime) == "number" and w.reloadtime > 0 then
      assert(w.reloadtime >= ((w.burst or 1) - 1) * (w.burstrate or 0) + 0.05)
    end
  end
end

-- Missing bases are skipped gracefully.
UnitDefs = {}
assert(loadfile(pack))()
assert(next(UnitDefs) == nil, "missing bases were registered")
print("unique enemies runtime checks passed")
