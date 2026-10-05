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
  u.weapondefs = u.weapondefs or {}
  u.weapons = u.weapons or {}
  u.weapondefs[key] = copy(def)
  if u.weapons[1] ~= nil then
    -- Replacing the inherited filters is essential: donor turrets such as EMP
    -- structures can exclude MOBILE/VTOL and otherwise never acquire aircraft.
    u.weapons[1] = { def = key:upper(), onlytargetcategory = "VTOL" }
  end
end
local ARM_BUILDERS = { "armack", "armacv", "armaca", "armacsub", "armcs", "armch", "armcsa" }
local COR_BUILDERS = { "corack", "coracv", "coraca", "coracsub", "corcs", "corch", "corgantuw" }
local LEG_BUILDERS = { "legack", "legacv", "legaca", "legch", "legspcon", "legnavyconship", "leganavyconsub" }
local ALL_BUILDERS = { "armack", "armacv", "armaca", "armacsub", "armcs", "armch", "armcsa", "corack", "coracv", "coraca", "coracsub", "corcs", "corch", "corgantuw", "legack", "legacv", "legaca", "legch", "legspcon", "legnavyconship", "leganavyconsub" }
local AA = {
  missile = { name = "Spear Interceptor", weapontype = "MissileLauncher", accuracy = 35, areaofeffect = 200, burst = 6, burstrate = 0.1, range = 2000, reloadtime = 1.6, tracks = true, turnrate = 68000, dance = 3, wobble = 40, weaponacceleration = 800, weaponvelocity = 3200, flighttime = 7, cegtag = "missiletrailaa", texture1 = "null", texture2 = "smoketrailaa", explosiongenerator = "custom:genericshellexplosion-medium-aa", soundhit = "packaahit", soundstart = "packaamissiles", damage = { default = 900, vtol = 3800, shields = 1400 } },
  emp = { name = "Silence Ray", weapontype = "Cannon", accuracy = 60, areaofeffect = 420, burst = 4, burstrate = 0.12, sprayangle = 1000, range = 1600, reloadtime = 1.4, paralyzetime = 30, weaponvelocity = 2600, cegtag = "railguntrail", customparams = { speceffect = "sector_fire", spread_angle = 24 }, explosiongenerator = "custom:emp_m_preventable", soundhit = "emparm", edgeeffectiveness = 0.7, damage = { default = 500, vtol = 3000, commandertoo = 500 } },
  beam = { name = "Prism Interceptor", weapontype = "LaserCannon", beamtime = 0.12, largebeamlaser = true, corethickness = 1.6, laserflaresize = 9, explosiongenerator = "custom:laserhit-large-blue", range = 1900, reloadtime = 0.3, beamttl = 6, rgbcolor = "0.2 0.9 1.0", thickness = 14, soundstart = "beamlaserfire", soundtrigger = 1, damage = { default = 1400, vtol = 4200, shields = 1500 } },
}
local SHIELDS = {
  { dst = "player_aegisdome", src = "armgate", nm = "Aegis Dome", tip = "T2 heavy shield. 9000 power, 520 radius, holds a forward line.", m = 45000, e = 900000, bt = 900000, hp = 190000, cap = 4, radius = 720, power = 42000, regen = 2600, regenE = 1600, start = 34000 },
  { dst = "player_citadelumbrella", src = "armgatet3", nm = "Citadel Umbrella", tip = "T3 mega shield. 36000+ power, 950 radius, covers a whole base.", m = 190000, e = 3800000, bt = 3800000, hp = 620000, cap = 2, radius = 1400, power = 180000, regen = 9000, regenE = 5600, start = 155000 },
}
for _, p in ipairs(SHIELDS) do
  local s = UnitDefs[p.src]
  if s ~= nil and UnitDefs[p.dst] == nil then
    local u = copy(s)
    u.unitname, u.name = p.dst, p.nm
    u.metalcost, u.energycost, u.buildtime, u.health, u.maxthisunit = p.m, p.e, p.bt, p.hp, p.cap
    u.customparams = u.customparams or {}
    u.customparams.shield_radius = p.radius
    u.customparams.shield_power = p.power
    u.customparams.shield_powerregen = p.regen
    u.customparams.shield_powerregenenergy = p.regenE
    u.customparams.shield_startingpower = p.start
    name(u, p.nm, p.tip)
    UnitDefs[p.dst] = u
    if UnitDefNames ~= nil then UnitDefNames[p.dst] = u end
    teach(ALL_BUILDERS, p.dst)
  end
end
local AA_SPECS = {
  { dst = "player_silencearray", src = "armemp", builders = ARM_BUILDERS, key = "player_silenceray", def = AA.emp, nm = "Silence Array", tip = "Arm T2 EMP AA monument. 30-second paralysis, 420 area, zero flak.", m = 32000, e = 560000, bt = 560000, hp = 150000, cap = 6, upkeep = 1400 },
  { dst = "player_prismwall", src = "corflak", builders = COR_BUILDERS, key = "player_prisminterceptor", def = AA.beam, nm = "Prism Wall", tip = "Core T2 beam AA monument. Sustained cyan lance, 4200 VTOL damage.", m = 34000, e = 600000, bt = 600000, hp = 155000, cap = 6, upkeep = 1550 },
  { dst = "player_legionstormguard", src = "legflak", builders = LEG_BUILDERS, key = "player_legionstormguard", def = { name = "Legion Storm Guard", weapontype = "Cannon", accuracy = 40, areaofeffect = 300, burst = 10, burstrate = 0.05, range = 1800, reloadtime = 0.4, weaponvelocity = 3200, paralyzetime = 18, cegtag = "railguntrail", explosiongenerator = "custom:laserhit-large-sparks", soundstart = "beamlaserfire", soundtrigger = 1, customparams = { speceffect = "sector_fire", spread_angle = 20 }, damage = { default = 1000, vtol = 3600, shields = 1200 } }, nm = "Storm Guard", tip = "Legion T2 rapid EMP needle monument. Ten-round bursts, 18-second stun.", m = 32000, e = 580000, bt = 580000, hp = 150000, cap = 6, upkeep = 1500 },
}
for _, p in ipairs(AA_SPECS) do
  local s = UnitDefs[p.src]
  if s ~= nil and UnitDefs[p.dst] == nil then
    local u = copy(s)
    u.unitname, u.name = p.dst, p.nm
    u.metalcost, u.energycost, u.buildtime, u.health, u.maxthisunit = p.m, p.e, p.bt, p.hp, p.cap
    u.energyupkeep = p.upkeep
    name(u, p.nm, p.tip)
    weapon(u, p.key, p.def)
    UnitDefs[p.dst] = u
    if UnitDefNames ~= nil then UnitDefNames[p.dst] = u end
    teach(p.builders, p.dst)
  end
end
end
