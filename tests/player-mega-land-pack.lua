local pack = arg[1] or "tweaks/defs/player/megas/player-mega-land-pack.lua"
local function copy(v)
  if type(v) ~= "table" then return v end
  local out = {}
  for k, child in pairs(v) do out[k] = copy(child) end
  return out
end

UnitDefs, UnitDefNames = {}, {}
local bases = {
  "armbanth", "armrattet4", "corjugg", "corkarganetht4", "corkarg", "armraz",
  "armmar", "legapollyon", "corpun", "corint", "armapt3", "corapt3", "legapt3",
  "everyexpe", "armaap", "coraap", "legaap", "armshltx", "corgant", "leggant",
}
for _, name in ipairs(bases) do
  local def = {name = name, health = 100000, speed = 50, weapons = {}, weapondefs = {}, buildoptions = {}}
  UnitDefs[name], UnitDefNames[name] = def, def
end
for _, name in ipairs({"armshltx", "corgant", "leggant", "everyexpe", "armapt3", "corapt3", "legapt3", "armrattet4", "corjugg", "corkarganetht4", "corkarg", "armraz", "armmar", "legapollyon", "corpun", "corint"}) do
  table.insert(UnitDefs[name].buildoptions, "existing_option")
end
local originals = copy(UnitDefs)
assert(loadfile(pack))()
local units = {
  {"player_riftcolossus", 1}, {"player_aegisbreaker", 1}, {"player_solardecimator", 1},
  {"player_skyfurnace", 1}, {"player_stormsovereign", 1}, {"player_pyroclast", 1},
  {"player_apollyonfortress", 6},
}
for _, spec in ipairs(units) do
  local name, slots = spec[1], spec[2]
  local u = assert(UnitDefs[name], name .. " not registered")
  assert(#u.weapons == slots, name .. " weapon slot count")
  assert(u.unitname == name and u.builder == false and u.cantbetransported)
  assert(u.customparams.techlevel == 4)
  for _, slot in pairs(u.weapons) do
    assert(slot.def and u.weapondefs[slot.def], name .. " has an unresolved weapon slot")
  end
end
local fortress = UnitDefs.player_apollyonfortress
assert(fortress.weapons[6].def == "apollyon_6")
assert(fortress.weapondefs.apollyon_6.weapontype == "Shield")
for _, name in ipairs({"armshltx", "corgant", "leggant", "everyexpe"}) do
  local found = false
  for _, option in ipairs(UnitDefs[name].buildoptions) do if option == "player_riftcolossus" then found = true end end
  assert(found, name .. " was not taught the land mega")
end
for name, def in pairs(originals) do
  assert(def.health == UnitDefs[name].health, name .. " base health was modified")
end
assert(loadfile(pack))()
for _, spec in ipairs(units) do assert(UnitDefs[spec[1]], spec[1] .. " lost on repeat application") end
print("mega land runtime checks passed")
