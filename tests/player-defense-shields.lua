local pack = arg[1] or "tweaks/defs/player/defenses/player-defense-shields.lua"
local applyPack = assert(loadfile(pack))
UnitDefs, UnitDefNames = {}, {}
-- Keep the old AA source chassis available so missing sources cannot hide a regression.
for _, src in ipairs({"armflak", "corflak", "legflak"}) do
  local u = {
    name = src, health = 3000, speed = 0,
    weapons = { { def = src .. "_w", onlytargetcategory = "SURFACE" } },
    weapondefs = { [src .. "_w"] = { name = src .. "_w", weapontype = "Cannon" } },
    customparams = {},
  }
  UnitDefs[src], UnitDefNames[src] = u, u
end

local function shieldSource(src, key, def, shield)
  local u = {
    objectname = src .. ".s3o", script = src .. ".cob",
    weapons = { { def = "dummy" }, { def = def } },
    weapondefs = {
      dummy = { weapontype = "Cannon" },
      unmounted = { weapontype = "Shield", shield = { radius = 77 } },
      [key] = { weapontype = "Shield", shield = shield },
    },
    customparams = { shield_emit_height = #src },
  }
  UnitDefs[src], UnitDefNames[src] = u, u
end
local original = { radius = 450, smart = true, exterior = false, repulser = true, goodcolor = "0 0 1" }
shieldSource("armgate", "repulsor", "REPULSOR", original)
shieldSource("armgatet3", "heavy", "HEAVY", original)
shieldSource("corgate", "CortexShield", "CortexShield", original)
shieldSource("corgatet3", "cortexlate", "CORTEXLATE", original)
shieldSource("legdeflector", "legshield", "LEGSHIELD", nil)
-- Leggatet3 intentionally absent: both upper tiers must stay on Legion assets.

local builderTiers = {
  arm = { {"armack", "armacv", "armaca", "armacsub", "armcs", "armch", "armcsa", "armnanotct2"}, {"armnanotct3"}, {"armnanotct4"} },
  cor = { {"corack", "coracv", "coraca", "coracsub", "corcs", "corch", "cornanotct2"}, {"cornanotct3"}, {"cornanotct4"} },
  leg = { {"legack", "legacv", "legaca", "legch", "legspcon", "leghack", "leghacv", "leghaca", "legnavyconship", "leganavyconsub", "legnanotct2"}, {"legnanotct3"}, {"legnanotct4"} },
}
local function addBuilder(b)
  local u = { name = b, health = 1500, speed = 50, buildoptions = {} }
  UnitDefs[b], UnitDefNames[b] = u, u
end
for _, tiers in pairs(builderTiers) do
  for _, builders in ipairs(tiers) do
    for _, b in ipairs(builders) do addBuilder(b) end
  end
end
addBuilder("corgantuw")

local function countOption(b, id)
  local n = 0
  for _, option in ipairs(UnitDefs[b].buildoptions) do
    if option == id then n = n + 1 end
  end
  return n
end

applyPack()

local shields = {
  arm = {
    { "player_aegisdome", "Aegis Dome", "armgate", "repulsor", 720, 42000, 1200, 4200 },
    { "player_citadelumbrella", "Citadel Umbrella", "armgatet3", "heavy", 950, 130000, 3600, 11500 },
    { "player_arm_aegisstronghold", "Aegis Stronghold", "armgatet3", "heavy", 1220, 340000, 8500, 26000 },
  },
  cor = {
    { "player_cor_ironbastion", "Iron Bastion", "corgate", "CortexShield", 680, 60000, 850, 3300 },
    { "player_cor_ironredoubt", "Iron Redoubt", "corgatet3", "cortexlate", 880, 185000, 2500, 9500 },
    { "player_cor_ironcitadel", "Iron Citadel", "corgatet3", "cortexlate", 1120, 480000, 5900, 22000 },
  },
  leg = {
    { "player_leg_auroraveil", "Aurora Veil", "legdeflector", "legshield", 850, 36000, 950, 3900 },
    { "player_leg_auroracanopy", "Aurora Canopy", "legdeflector", "legshield", 1160, 110000, 2800, 10400 },
    { "player_leg_aurorahorizon", "Aurora Horizon", "legdeflector", "legshield", 1540, 285000, 6700, 24000 },
  },
}
local costs = {
  { 12000, 220000, 180000, 42000, 8, 1 },
  { 42000, 900000, 650000, 135000, 4, 1015 },
  { 115000, 2600000, 1800000, 315000, 2, 1023 },
}
local unpack = table.unpack or unpack
local installed = {}
for faction, tiers in pairs(shields) do
  for i, p in ipairs(tiers) do
    local id, nm, src, key, radius, power, regen, energy = unpack(p)
    local m, e, bt, hp, cap, mask = unpack(costs[i])
    local u = assert(UnitDefs[id], id .. " missing")
    installed[id] = u
    assert(UnitDefNames[id] == u and u.unitname == id and u.name == nm, id)
    assert(u.objectname == src .. ".s3o" and u.script == src .. ".cob", id)
    assert(u.metalcost == m and u.energycost == e and u.buildtime == bt, id)
    assert(u.health == hp and u.maxdamage == hp and u.maxthisunit == cap, id)
    local w = u.weapondefs[key]
    assert(u.weapons[2].def:lower() == key:lower() and w.weapontype == "Shield", id)
    assert(u.weapondefs.unmounted.shield.radius == 77, id)
    local shield = assert(w.shield, id)
    assert(shield.radius == radius and shield.power == power and shield.startingpower == power / 4, id)
    assert(shield.powerregen == regen and shield.powerregenenergy == energy and shield.intercepttype == mask, id)
    if faction ~= "leg" then
      assert(shield.smart == true and shield.exterior == false and shield.repulser == true, id)
      assert(shield.goodcolor == original.goodcolor, id)
    end
    local cp = u.customparams
    assert(cp.shield_radius == radius and cp.shield_power == power and cp.shield_startingpower == power / 4, id)
    assert(cp.shield_powerregen == regen and cp.shield_powerregenenergy == energy, id)
    assert(cp.techlevel == i + 1 and cp.shield_emit_height == #src, id)
    assert(cp.i18n_en_humanname == nm and cp.i18n_en_tooltip:find(radius .. " radius", 1, true), id)
    assert(countOption("corgantuw", id) == 0, id)
    for other, otherTiers in pairs(builderTiers) do
      for j, builders in ipairs(otherTiers) do
        for _, b in ipairs(builders) do
          local eligible = faction == other and (i == 1 or i == j)
          assert(countOption(b, id) == (eligible and 1 or 0), b .. ": " .. id)
        end
      end
    end
  end
end
assert(original.radius == 450 and original.power == nil and UnitDefs.legdeflector.weapondefs.legshield.shield == nil)

-- Reapplying must keep the existing UnitDefs, teach newly available builders and avoid duplicates.
UnitDefs.armnanotct4.buildoptions = {}
applyPack()
applyPack()
for id, u in pairs(installed) do
  assert(UnitDefs[id] == u, id)
  for _, tiers in pairs(builderTiers) do
    for _, builders in ipairs(tiers) do
      for _, b in ipairs(builders) do assert(countOption(b, id) <= 1, b .. ": " .. id) end
    end
  end
end
assert(countOption("armnanotct4", "player_arm_aegisstronghold") == 1)
assert(countOption("armnanotct4", "player_aegisdome") == 1)

-- Only BAR's renderer metadata should apply the mod multiplier before BAR post-processing.
Spring = { GetModOptions = function() return { multiplier_shieldpower = "2" } end }
UnitDefs.player_aegisdome = nil
applyPack()
local scaled = UnitDefs.player_aegisdome
assert(scaled.customparams.shield_power == 84000 and scaled.weapondefs.repulsor.shield.power == 42000)
assert(scaled.customparams.shield_powerregen == 1200 and scaled.customparams.shield_startingpower == 10500)
Spring = nil

for _, id in ipairs({"player_silencearray", "player_prismwall", "player_legionstormguard"}) do
  assert(UnitDefs[id] == nil and UnitDefNames[id] == nil, id .. " must not be registered")
  for b, u in pairs(UnitDefs) do
    if u.buildoptions then
      assert(countOption(b, id) == 0, b .. " must not build " .. id)
    end
  end
end
print("defense shields runtime checks passed")
