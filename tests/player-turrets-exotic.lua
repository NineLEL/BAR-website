local pack = arg[1] or "tweaks/defs/player/turrets/player-turrets-exotic.lua"
local function copy(v)
  if type(v) ~= "table" then return v end
  local out = {}
  for k, child in pairs(v) do out[k] = copy(child) end
  return out
end

UnitDefs, UnitDefNames = {}, {}
local function makeBase(name, slots)
  local weapons, weapondefs = {}, {}
  for i = 1, slots do
    local k = "w" .. i
    weapondefs[k] = { name = k, weapontype = "Cannon", range = 800, reloadtime = 1, damage = { default = 100 } }
    weapons[i] = { def = k, onlytargetcategory = "SURFACE" }
  end
  local def = {
    name = name, health = 5000, speed = 0, weapons = weapons, weapondefs = weapondefs,
    buildoptions = {}, customparams = {},
  }
  if name == "legrampart" then
    def.customparams.geothermal = 1
    def.yardmap = "h " .. string.rep("o", 25)
  end
  UnitDefs[name], UnitDefNames[name] = def, def
end

for _, spec in ipairs({
  {"legcluster", 3}, {"armpb", 1}, {"corscavdtl", 1}, {"legbastion", 1},
  {"legacluster", 3}, {"armamb", 3}, {"legrampart", 2}, {"armanavaldefturret", 2}, {"corfdoom", 2},
}) do
  makeBase(spec[1], spec[2])
end
local builders = {
  "armack", "corack", "legack", "armacsub", "armbehem", "corcrabe",
  "armnanotct3", "cornanotct3", "legnanotct3", "armnanotct4", "cornanotct4", "legnanotct4",
}
for _, b in ipairs(builders) do
  local def = { name = b, health = 2000, speed = 50, buildoptions = {"existing_option"} }
  UnitDefs[b], UnitDefNames[b] = def, def
end

local originals = copy(UnitDefs)
assert(loadfile(pack))()

local expected = {
  {"player_sunsplitter", 3, "leg"}, {"player_skewerspike", 1, "arm"},
  {"player_arcpylon", 1, "cor"}, {"player_chronosweep", 1, "leg"},
  {"player_blightmortar", 3, "leg"}, {"player_diskricochet", 3, "arm"},
  {"player_vlsbastion", 2, "leg"}, {"player_abyssalkraken", 2, "arm"},
}

local function checkMenus()
  for _, b in ipairs(builders) do
    if UnitDefs[b] then
      local options = assert(UnitDefs[b].buildoptions, b .. " lost its build options")
      local expectedCount = 1
      assert(options[1] == "existing_option", b .. " lost its original buildoption")
      for _, spec in ipairs(expected) do
        local name, faction = spec[1], spec[3]
        local want = b == faction .. "nanotct4" and 1 or 0
        local found = 0
        for _, opt in ipairs(options) do if opt == name then found = found + 1 end end
        assert(found == want, b .. " has incorrect buildoption count for " .. name)
        expectedCount = expectedCount + want
      end
      assert(#options == expectedCount, b .. " gained unexpected buildoptions")
    end
  end
end

checkMenus()
for _, spec in ipairs(expected) do
  local name, slots = spec[1], spec[2]
  local u = assert(UnitDefs[name], name .. " not registered")
  assert(#u.weapons == slots, name .. " weapon slot count")
  assert(u.customparams.techlevel == 4 and u.customparams.t4_exotic == 1)
  for _, slot in pairs(u.weapons) do
    assert(slot.def and u.weapondefs[slot.def], name .. " unresolved slot")
  end
end

assert(UnitDefs.player_sunsplitter.weapondefs.sun_shard ~= nil)
assert(UnitDefs.player_sunsplitter.weapondefs.HELIOS_SHELL.customparams.speceffect == "split")
assert(UnitDefs.player_skewerspike.cancloak == true and UnitDefs.player_skewerspike.weapondefs.HYPERION_SKEWER.customparams.overpenetrate == true)
assert(UnitDefs.player_arcpylon.weapondefs.ZEUS_ARC.customparams.spark_maxunits == "7")
assert(UnitDefs.player_chronosweep.weapondefs.SOLARIS_SWEEP.sweepfire == true)
assert(UnitDefs.player_blightmortar.weapondefs.VIPER_CAULDRON.customparams.area_onhit_time == 16)
assert(UnitDefs.player_diskricochet.weapondefs.VALKYRIE_GLAIVE.groundbounce == true and UnitDefs.player_diskricochet.weapondefs.VALKYRIE_GLAIVE.numbounce == 4)
assert(UnitDefs.player_vlsbastion.radardistancejam == 950 and UnitDefs.player_vlsbastion.customparams.geothermal == nil)
assert(UnitDefs.player_vlsbastion.weapondefs.AEGIS_VLS_CRUISE.interceptor == 0 and UnitDefs.player_vlsbastion.weapondefs.AEGIS_VLS_CRUISE.collideenemy == true)
assert(UnitDefs.player_diskricochet.weapons[1].maindir == nil and UnitDefs.player_diskricochet.weapons[1].maxangledif == nil)
assert(UnitDefs.player_abyssalkraken.sonardistance == 2200 and UnitDefs.player_abyssalkraken.weapondefs.KRAKEN_TORPEDO.weapontype == "TorpedoLauncher")

for name, def in pairs(originals) do
  assert(def.health == UnitDefs[name].health, name .. " base health modified")
end

local beforeRepeat = copy(UnitDefs)
assert(loadfile(pack))()
checkMenus()
for _, spec in ipairs(expected) do
  local name, slots = spec[1], spec[2]
  local u = assert(UnitDefs[name], name .. " lost on repeat")
  local before = beforeRepeat[name]
  assert(#u.weapons == slots, name .. " changed weapon slot count on repeat")
  for i, slot in ipairs(u.weapons) do
    assert(slot.def == before.weapons[i].def and u.weapondefs[slot.def], name .. " changed mounted weapon on repeat")
  end
  for def in pairs(before.weapondefs) do
    assert(u.weapondefs[def], name .. " lost weapon definition on repeat: " .. def)
  end
  assert(u.customparams.t4_source == before.customparams.t4_source
    and u.customparams.t4_source_weapon_slots == before.customparams.t4_source_weapon_slots, name .. " changed source metadata on repeat")
end

-- A Core fallback chassis must not move Abyssal Kraken out of Armada's menu.
UnitDefs.armanavaldefturret, UnitDefs.player_abyssalkraken, UnitDefs.armnanotct4 = nil, nil, nil
assert(loadfile(pack))()
assert(UnitDefs.player_abyssalkraken.customparams.t4_source == "corfdoom")
checkMenus()
UnitDefs.armnanotct4 = copy(originals.armnanotct4)
assert(loadfile(pack))()
checkMenus()
print("exotic turrets runtime checks passed")
