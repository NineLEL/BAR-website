-- Player shield pack.
-- Shields use faction-specific T2 constructors and T3/T4 construction turrets.
do
local unpack = table.unpack or unpack
local function copy(t)
  if type(t) ~= "table" then return t end
  local r = {}
  for k, v in pairs(t) do r[copy(k)] = copy(v) end
  return r
end
local function teach(builders, dst)
  for _, b in ipairs(builders) do
    local u = UnitDefs[b]
    if u ~= nil then
      u.buildoptions = u.buildoptions or {}
      local found = false
      for _, x in ipairs(u.buildoptions) do if x == dst then found = true break end end
      if not found then u.buildoptions[#u.buildoptions + 1] = dst end
    end
  end
end
local function name(u, nm, tip)
  u.customparams = u.customparams or {}
  for _, l in ipairs({ "en", "de", "fr", "es", "it", "ru", "zh", "cs", "hr", "lt" }) do
    u.customparams["i18n_" .. l .. "_humanname"] = nm
    u.customparams["i18n_" .. l .. "_tooltip"] = tip
  end
end
local ARM_BUILDERS = { "armack", "armacv", "armaca", "armacsub", "armcs", "armch", "armcsa" }
local LEG_BUILDERS = { "legack", "legacv", "legaca", "legch", "legspcon", "leghack", "leghacv", "leghaca", "legnavyconship", "leganavyconsub" }
local SHIELD_FACTIONS = {
  { prefix = "arm", base = "armgate", late = "armgatet3", builders = ARM_BUILDERS, tiers = {
    { "player_aegisdome", "Aegis Dome", 720, 42000, 1200, 4200 },
    { "player_citadelumbrella", "Citadel Umbrella", 950, 130000, 3600, 11500 },
    { "player_arm_aegisstronghold", "Aegis Stronghold", 1220, 340000, 8500, 26000 },
  } },
  { prefix = "cor", base = "corgate", late = "corgatet3", builders = {
    "corack", "coracv", "coraca", "coracsub", "corcs", "corch",
  }, tiers = {
    { "player_cor_ironbastion", "Iron Bastion", 680, 60000, 850, 3300 },
    { "player_cor_ironredoubt", "Iron Redoubt", 880, 185000, 2500, 9500 },
    { "player_cor_ironcitadel", "Iron Citadel", 1120, 480000, 5900, 22000 },
  } },
  { prefix = "leg", base = "legdeflector", late = "leggatet3", builders = LEG_BUILDERS, tiers = {
    { "player_leg_auroraveil", "Aurora Veil", 850, 36000, 950, 3900 },
    { "player_leg_auroracanopy", "Aurora Canopy", 1160, 110000, 2800, 10400 },
    { "player_leg_aurorahorizon", "Aurora Horizon", 1540, 285000, 6700, 24000 },
  } },
}
-- Tier costs and limits: metal, energy, build time, health, unit cap, intercept mask.
-- None of the masks include BAR's default strategic starburst bit (1024).
local SHIELD_TIERS = {
  { 12000, 220000, 180000, 42000, 8, 1 },
  { 42000, 900000, 650000, 135000, 4, 1015 },
  { 115000, 2600000, 1800000, 315000, 2, 1023 },
}
local function mountedShield(u)
  if not (u.weapons and u.weapondefs) then return end
  for _, slot in ipairs(u.weapons) do
    if type(slot.def) == "string" then
      local def = u.weapondefs[slot.def:lower()] or u.weapondefs[slot.def]
      if def and (def.weapontype or ""):lower() == "shield" then return def end
    end
  end
end
local modOptions = Spring and Spring.GetModOptions and Spring.GetModOptions()
local shieldPowerMultiplier = tonumber(modOptions and modOptions.multiplier_shieldpower) or 1
local function registerShield(faction, tier, spec, tierStats)
  local dst, nm, radius, power, regen, regenE = unpack(spec)
  local u = UnitDefs[dst]
  if not u then
    local s = tier > 2 and UnitDefs[faction.late] or UnitDefs[faction.base]
    if not s then return end
    u = copy(s)
    local w = mountedShield(u)
    if not w then return end

    local m, e, bt, hp, cap, mask = unpack(tierStats)
    local start = power * 0.25
    w.shield = w.shield or {}
    local shield = w.shield
    shield.radius, shield.power = radius, power
    shield.powerregen, shield.powerregenenergy, shield.startingpower = regen, regenE, start
    shield.intercepttype = mask

    u.unitname, u.name = dst, nm
    u.metalcost, u.energycost, u.buildtime, u.health, u.maxdamage, u.maxthisunit = m, e, bt, hp, hp, cap
    u.customparams = u.customparams or {}
    local cp = u.customparams
    cp.techlevel, cp.shield_radius = tier, radius
    -- BAR's post-process applies this option to the weapon, but not the renderer's metadata.
    cp.shield_power = power * shieldPowerMultiplier
    cp.shield_powerregen, cp.shield_powerregenenergy, cp.shield_startingpower = regen, regenE, start
    local tip = ("T%d shield. Base stats: %d radius, %d power, %d regen/s at %d energy/s. Starts at 25%% charge.")
      :format(tier, radius, power, regen, regenE)
    name(u, nm, tip)
    UnitDefs[dst] = u
    if UnitDefNames ~= nil then UnitDefNames[dst] = u end
  elseif u.unitname ~= dst or not mountedShield(u) then
    return -- Do not teach a conflicting, unrelated definition.
  end

  local builders = tier == 2 and faction.builders or { faction.prefix .. "nanotct" .. tier }
  teach(builders, dst)
end
for _, faction in ipairs(SHIELD_FACTIONS) do
  for i, spec in ipairs(faction.tiers) do
    registerShield(faction, i + 1, spec, SHIELD_TIERS[i])
  end
end
end
