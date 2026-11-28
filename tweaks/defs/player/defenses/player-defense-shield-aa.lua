-- Player shield and non-flak AA pack.
-- Shields use faction-specific T2 constructors and T3/T4 construction turrets.
-- Non-flak AA remains on the existing T2 builder menus.
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
local function weapon(u, key, def)
  local w = copy(def)
  w.turret = true
  w.noselfdamage = true
  if w.collidefriendly == nil then w.collidefriendly = false end
  if w.avoidfriendly == nil then w.avoidfriendly = false end
  if w.tolerance == nil then w.tolerance = 10000 end
  u.weapondefs = { [key] = w }
  u.weapons = { { def = key, onlytargetcategory = "VTOL" } }
end
local ARM_BUILDERS = { "armack", "armacv", "armaca", "armacsub", "armcs", "armch", "armcsa" }
local COR_BUILDERS = { "corack", "coracv", "coraca", "coracsub", "corcs", "corch", "corgantuw" }
local LEG_BUILDERS = { "legack", "legacv", "legaca", "legch", "legspcon", "leghack", "leghacv", "leghaca", "legnavyconship", "leganavyconsub" }
local AA = {
  missile = { name = "Spear Interceptor", weapontype = "MissileLauncher", accuracy = 35, areaofeffect = 200, burst = 6, burstrate = 0.1, range = 2000, reloadtime = 1.6, tracks = true, turnrate = 68000, dance = 3, wobble = 40, weaponacceleration = 800, weaponvelocity = 3200, flighttime = 7, cegtag = "missiletrailaa-large", texture1 = "null", texture2 = "smoketrailaa", explosiongenerator = "custom:genericshellexplosion-medium-aa", soundhit = "packohit", soundstart = "packolau", damage = { default = 900, vtol = 3800, shields = 1400 } },
  emp = { name = "Silence Ray", weapontype = "Cannon", canattackground = false, burnblow = true, predictboost = 1, accuracy = 60, areaofeffect = 420, burst = 4, burstrate = 0.12, sprayangle = 1000, range = 1800, reloadtime = 1.4, paralyzer = true, paralyzetime = 16, weaponvelocity = 2600, mygravity = 0.01, size = 8, stages = 16, rgbcolor = "0.3 0.75 1", cegtag = "lightning_stormbolt_small", explosiongenerator = "custom:lightning_storm_emp", soundhit = "mismed1emp", soundstart = "lghthvy1", edgeeffectiveness = 0.7, damage = { default = 800, vtol = 18000, commandertoo = 800 } },
  beam = { name = "Prism Interceptor", weapontype = "BeamLaser", beamtime = 0.06, largebeamlaser = true, corethickness = 0.5, laserflaresize = 7, scrollspeed = 8, pulsespeed = 8, explosiongenerator = "custom:laserhit-medium-aqua", range = 1900, reloadtime = 0.25, beamttl = 3, rgbcolor = "0.2 0.9 1.0", rgbcolor2 = "0.9 1 1", thickness = 4, soundstart = "beamershot", soundtrigger = 1, damage = { default = 1800, vtol = 8500, shields = 2500 } },
}
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
local AA_SPECS = {
  { dst = "player_silencearray", src = "armflak", builders = ARM_BUILDERS, key = "player_silenceray", def = AA.emp, nm = "Silence Array", tip = "Arm T2 EMP AA monument. 16-second air paralysis, 420 area, zero flak.", m = 12000, e = 220000, bt = 220000, hp = 90000, cap = 6, upkeep = 900 },
  { dst = "player_prismwall", src = "corflak", builders = COR_BUILDERS, key = "player_prisminterceptor", def = AA.beam, nm = "Prism Wall", tip = "Core T2 beam AA monument. Sustained cyan lance, 34k VTOL DPS.", m = 13000, e = 240000, bt = 240000, hp = 95000, cap = 6, upkeep = 1000 },
  { dst = "player_legionstormguard", src = "legflak", builders = LEG_BUILDERS, key = "player_legionstormguard", def = { name = "Legion Storm Guard", weapontype = "Cannon", canattackground = false, burnblow = true, predictboost = 1, accuracy = 40, areaofeffect = 300, edgeeffectiveness = 0.85, burst = 8, burstrate = 0.05, range = 1800, reloadtime = 0.8, weaponvelocity = 3200, mygravity = 0.01, size = 7, stages = 16, rgbcolor = "0.4 0.88 1", paralyzer = true, paralyzetime = 14, cegtag = "railgun", explosiongenerator = "custom:genericshellexplosion-small-lightning", soundstart = "electric2", soundhit = "xploelc1", soundtrigger = 1, damage = { default = 1000, vtol = 6500, shields = 1500 } }, nm = "Storm Guard", tip = "Legion T2 rapid EMP needle monument. Eight-round bursts, 14-second stun.", m = 12500, e = 230000, bt = 230000, hp = 90000, cap = 6, upkeep = 950 },
}
for _, p in ipairs(AA_SPECS) do
  local s = UnitDefs[p.src]
  if s ~= nil and UnitDefs[p.dst] == nil then
    local u = copy(s)
    u.unitname, u.name = p.dst, p.nm
    u.metalcost, u.energycost, u.buildtime, u.health, u.maxdamage, u.maxthisunit = p.m, p.e, p.bt, p.hp, p.hp, p.cap
    u.energyupkeep = p.upkeep
    u.canattack, u.canstop, u.activatewhenbuilt, u.onoffable = true, true, true, true
    u.nochasecategory = "NOTVTOL"
    name(u, p.nm, p.tip)
    weapon(u, p.key, p.def)
    UnitDefs[p.dst] = u
    if UnitDefNames ~= nil then UnitDefNames[p.dst] = u end
    teach(p.builders, p.dst)
  end
end
end
