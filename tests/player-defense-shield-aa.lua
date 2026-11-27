local pack = arg[1] or "tweaks/defs/player/defenses/player-defense-shield-aa.lua"
UnitDefs, UnitDefNames = {}, {}
for _, src in ipairs({"armgate", "armgatet3", "armflak", "corflak", "legflak"}) do
  local u = {
    name = src, health = 3000, speed = 0,
    weapons = { { def = src .. "_w", onlytargetcategory = "SURFACE" } },
    weapondefs = { [src .. "_w"] = { name = src .. "_w", weapontype = "Cannon" } },
    customparams = {},
  }
  if src == "armgate" or src == "armgatet3" then
    u.weapons[1].def = "repulsor"
    u.weapondefs = { repulsor = { weapontype = "Shield" } }
  end
  UnitDefs[src], UnitDefNames[src] = u, u
end
for _, b in ipairs({"armack", "corack", "legack", "leghack"}) do
  local u = { name = b, health = 1500, speed = 50, buildoptions = {} }
  UnitDefs[b], UnitDefNames[b] = u, u
end

assert(loadfile(pack))()

local sg = assert(UnitDefs.player_legionstormguard, "Storm Guard missing")
local w = assert(sg.weapondefs.player_legionstormguard, "Storm Guard weapondef missing")
assert(sg.weapons[1].def == "player_legionstormguard", "Storm Guard slot casing mismatch")
assert(sg.weapons[1].onlytargetcategory == "VTOL", "Storm Guard must target VTOL")
assert(w.turret == true, "Storm Guard turret must be true")
assert(w.burnblow == true and w.canattackground == false, "Storm Guard must air-detonate via burnblow")
assert(not (w.customparams and w.customparams.speceffect), "Storm Guard must not have broken sector_fire")
assert(sg.canattack == true and sg.maxdamage == sg.health)

for _, aa in ipairs({"player_silencearray", "player_prismwall"}) do
  local u = assert(UnitDefs[aa], aa .. " missing")
  local key = u.weapons[1].def
  local def = assert(u.weapondefs[key], aa .. " unresolved weapondef")
  assert(def.turret == true and def.noselfdamage == true)
end
print("defense shield aa runtime checks passed")
