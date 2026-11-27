-- Player shield and non-flak AA pack.
-- Big shields have two tiers; AA uses missiles, EMP, and beam interception,
-- never flak. All units are buildable by T2 constructors only.
do
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
local ALL_BUILDERS = { "armack", "armacv", "armaca", "armacsub", "armcs", "armch", "armcsa", "corack", "coracv", "coraca", "coracsub", "corcs", "corch", "corgantuw", "legack", "legacv", "legaca", "legch", "legspcon", "leghack", "leghacv", "leghaca", "legnavyconship", "leganavyconsub" }
local AA = {
  missile = { name = "Spear Interceptor", weapontype = "MissileLauncher", accuracy = 35, areaofeffect = 200, burst = 6, burstrate = 0.1, range = 2000, reloadtime = 1.6, tracks = true, turnrate = 68000, dance = 3, wobble = 40, weaponacceleration = 800, weaponvelocity = 3200, flighttime = 7, cegtag = "missiletrailaa-large", texture1 = "null", texture2 = "smoketrailaa", explosiongenerator = "custom:genericshellexplosion-medium-aa", soundhit = "packohit", soundstart = "packolau", damage = { default = 900, vtol = 3800, shields = 1400 } },
  emp = { name = "Silence Ray", weapontype = "Cannon", canattackground = false, burnblow = true, predictboost = 1, accuracy = 60, areaofeffect = 420, burst = 4, burstrate = 0.12, sprayangle = 1000, range = 1800, reloadtime = 1.4, paralyzer = true, paralyzetime = 16, weaponvelocity = 2600, mygravity = 0.01, size = 8, stages = 16, rgbcolor = "0.3 0.75 1", cegtag = "lightning_stormbolt_small", explosiongenerator = "custom:lightning_storm_emp", soundhit = "mismed1emp", soundstart = "lghthvy1", edgeeffectiveness = 0.7, damage = { default = 800, vtol = 18000, commandertoo = 800 } },
  beam = { name = "Prism Interceptor", weapontype = "BeamLaser", beamtime = 0.06, largebeamlaser = true, corethickness = 0.5, laserflaresize = 7, scrollspeed = 8, pulsespeed = 8, explosiongenerator = "custom:laserhit-medium-aqua", range = 1900, reloadtime = 0.25, beamttl = 3, rgbcolor = "0.2 0.9 1.0", rgbcolor2 = "0.9 1 1", thickness = 4, soundstart = "beamershot", soundtrigger = 1, damage = { default = 1800, vtol = 8500, shields = 2500 } },
}
local SHIELDS = {
  { dst = "player_aegisdome", src = "armgate", nm = "Aegis Dome", tip = "T2 heavy shield. 9000 power, 520 radius, holds a forward line.", m = 45000, e = 900000, bt = 900000, hp = 190000, cap = 4, radius = 720, power = 42000, regen = 2600, regenE = 1600, start = 34000, col = "0.15 0.8 1 0.85" },
  { dst = "player_citadelumbrella", src = "armgatet3", nm = "Citadel Umbrella", tip = "T3 mega shield. 36000+ power, 950 radius, covers a whole base.", m = 190000, e = 3800000, bt = 3800000, hp = 620000, cap = 2, radius = 1400, power = 180000, regen = 9000, regenE = 5600, start = 155000, col = "0.45 0.65 1 0.9" },
}
for _, p in ipairs(SHIELDS) do
  local s = UnitDefs[p.src]
  if s ~= nil and UnitDefs[p.dst] == nil then
    local u = copy(s)
    -- Cheap construction does not weaken the shield or weapon: only the
    -- resource price and build time are reduced.
    p.m, p.e, p.bt = p.m * 0.20, p.e * 0.20, p.bt * 0.20
    u.unitname, u.name = p.dst, p.nm
    u.metalcost, u.energycost, u.buildtime, u.health, u.maxthisunit = p.m, p.e, p.bt, p.hp, p.cap
    u.customparams = u.customparams or {}
    u.customparams.shield_radius = p.radius
    u.customparams.shield_power = p.power
    u.customparams.shield_powerregen = p.regen
    u.customparams.shield_powerregenenergy = p.regenE
    u.customparams.shield_startingpower = p.start
    if u.weapondefs and u.weapondefs.repulsor then
      u.weapondefs.repulsor.shieldalpha = 0.34
      u.weapondefs.repulsor.shieldgoodcolor = p.col
      u.weapondefs.repulsor.shieldbadcolor = "1 0.25 0.2 0.9"
    end
    name(u, p.nm, p.tip)
    UnitDefs[p.dst] = u
    if UnitDefNames ~= nil then UnitDefNames[p.dst] = u end
    teach(ALL_BUILDERS, p.dst)
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
