local pack = arg[1] or "tweaks/defs/player/defenses/player-defense-anti-air.lua"
local applyPack = assert(loadfile(pack))
local unpack = table.unpack or unpack
UnitDefs, UnitDefNames = {}, {}

-- Relevant raw fields from BAR 2bb57ff528f95c8cdbe9a4be04009db783e6c6c3.
-- Retain the stock cost/stockpile fields, case of slot names, LOS and Legion out-of-arc behavior.
local function chassis(id, key, kind, sight, range, reload, damage, burst, delay, outOfArc)
  local filename = "Units/" .. id:upper()
  local stockpile = kind == "MissileLauncher"
  local w = {
    weapontype = kind, canattackground = false, range = range, reloadtime = reload, damage = { vtol = damage },
    burst = burst, burstrate = delay, stockpile = stockpile or nil, stockpiletime = stockpile and 14 or nil,
    energypershot = stockpile and 1800 or nil, metalpershot = stockpile and 0 or nil,
    customparams = stockpile and { stockpilelimit = 5 } or {}, model = stockpile and "corscreamermissile.s3o" or nil,
  }
  local unit = {
    objectname = filename .. ".s3o", script = filename .. ".cob", airsightdistance = sight,
    sfxtypes = not stockpile and { explosiongenerators = { "custom:barrelshot-flak" } } or nil,
    customparams = { unitgroup = "aa", techlevel = id ~= "leglupara" and 2 or nil },
    weapons = {{ def = key, onlytargetcategory = "VTOL", burstcontrolwhenoutofarc = outOfArc }},
    weapondefs = { [key:lower()] = w },
  }
  UnitDefs[id] = unit
  return w
end
chassis("armflak", "ARMFLAK_GUN", "Cannon", 1000, 850, 0.5, 250)
local mercury = chassis("armmercury", "ARM_ADVSAM", "MissileLauncher", 2400, 2400, 1.8, 750)
chassis("corflak", "ARMFLAK_GUN", "Cannon", 1000, 850, 0.5, 250)
local screamer = chassis("corscreamer", "COR_ADVSAM", "MissileLauncher", 2400, 2400, 1.8, 750)
chassis("legflak", "leg_t2_microflak", "Cannon", 1000, 875, 0.166, 58, 3, 0.02, 2)
chassis("leglupara", "LEGFLAK_GUN", "Cannon", 1200, 1200, 1.8, 255, 2, 0.01)

-- Inject synthetic hazards to catch accidental inheritance, even for fields not in those stock sources.
local lupara = UnitDefs.leglupara
lupara.weapondefs.legflak_gun.paralyzer = true
lupara.weapondefs.legflak_gun.canattackground = true
lupara.weapondefs.extra = { paralyzer = true }
lupara.weapons[1].onlytargetcategory = "SURFACE"
lupara.weapons[1].maindir = "0 0 1"
lupara.weapons[1].maxangledif = 30
lupara.weapons[1].slaveto = 2
lupara.weapons[2] = { def = "extra" }

-- Keep both stock AA choices on the nine advanced constructors and check the turret routes separately.
local menus = {
  armack = {"armfus", "armafus", "armflak", "armmercury", "armalab"},
  armacv = {"armfus", "armckfus", "armflak", "armmercury", "armshltx"},
  armaca = {"armfus", "armafus", "armflak", "armmercury", "armshltx"},
  corack = {"corfus", "corafus", "corflak", "corscreamer", "coralab"},
  coracv = {"corfus", "corafus", "corflak", "corscreamer", "corgant"},
  coraca = {"corfus", "corafus", "corflak", "corscreamer", "corgant"},
  legack = {"legfus", "legafus", "legflak", "leglraa", "legalab"},
  legacv = {"legfus", "legafus", "legflak", "leglraa", "legavp"},
  legaca = {"legfus", "legafus", "legflak", "leglraa", "leggant"},
  armck = {"armsolar"}, corcv = {"corsolar"}, legca = {"legsolar"},
  armacsub = {"armfrad"}, cornanotc3 = {"corflak"}, leghack = {"legflak"},
  armnanotct2 = {"armfus"}, armnanotct3 = {"armflak"}, armnanotct4 = {"armmercury"},
  cornanotct2 = {"corfus"}, cornanotct3 = {"corflak"}, cornanotct4 = {"corscreamer"},
  legnanotct2 = {"legfus"}, legnanotct3 = {"legflak"}, legnanotct4 = {"leglraa"},
}
local eligible = { nanotct3 = true, nanotct4 = true }
for builder, options in pairs(menus) do
  UnitDefs[builder] = { buildoptions = { unpack(options) } }
end

local expected = {
  -- id, name, chassis, weapon type, range, HP, M, E, damage, DPS, reload frames, shot count, gap frames, AoE diameter
  {"player_arm_silencearray", "Silence Array", "armmercury", "LaserCannon", 1750, 11500, 7200, 125000, 7200, 2400, 90, 1, 0, 0},
  {"player_arm_skywardlance", "Skyward Lance", "armflak", "BeamLaser", 1400, 10000, 6800, 115000, 540, 1800, 9, 1, 0, 0},
  {"player_cor_thunderscreen", "Thunder Screen", "corflak", "Cannon", 1250, 15000, 8200, 150000, 3600, 2400, 45, 1, 0, 320},
  {"player_cor_dreadlance", "Dreadlance", "corscreamer", "MissileLauncher", 2550, 13500, 10500, 205000, 4000, 2000, 60, 1, 0, 64},
  {"player_leg_stormguard", "Storm Guard", "legflak", "Cannon", 1350, 12500, 7900, 145000, 840, 2800, 27, 3, 3, 104},
  {"player_leg_skyspearbattery", "Skyspear Battery", "leglupara", "MissileLauncher", 2250, 11500, 9300, 175000, 900, 2250, 48, 4, 6, 48},
}

-- Recoil WeaponLoader.cpp truncates seconds * GAME_SPEED. Weapon.cpp runs UpdateFire
-- before UpdateSalvo and gates a new salvo on both reloadStatus and nextSalvo.
-- BeamLaser::Init sets salvo count to max(1, floor(beamtime * GAME_SPEED)), delay 0.
local function cadence(w, duration)
  local speed = 30
  -- BAR alldefs_post.lua first sanitizes reloadtime and burstrate to whole frames.
  local function sanitizedFrames(seconds)
    return math.max(1, math.floor((seconds + 0.001) * speed))
  end
  local reload = sanitizedFrames(w.reloadtime)
  local size = w.burst or 1
  local delay = w.burstrate and sanitizedFrames(w.burstrate) or 3
  if w.weapontype == "BeamLaser" and not w.beamburst then
    size, delay = math.max(1, math.floor(w.beamtime * speed)), 0
  end
  local starts, shots = {}, {}
  local nextSalvo, reloadStatus, left = 0, 0, 0
  for frame = 0, duration do
    if left == 0 and frame >= nextSalvo and frame >= reloadStatus then
      starts[#starts + 1] = frame
      left, nextSalvo, reloadStatus = size, frame + math.floor((w.windup or 0) * speed), frame + reload
    end
    if left > 0 and frame >= nextSalvo then
      shots[#shots + 1] = frame
      left, nextSalvo = left - 1, frame + delay
    end
  end
  return starts, shots
end

applyPack()
local installed, byFaction = {}, { arm = {}, cor = {}, leg = {} }
for _, spec in ipairs(expected) do
  local id, name, source, kind, range, hp, metal, energy, damage, dps, period, count, gap, aoe = unpack(spec)
  local u = assert(UnitDefs[id], id .. " missing")
  installed[id] = u
  local factionUnits = byFaction[source:sub(1, 3)]
  factionUnits[#factionUnits + 1] = id
  assert(UnitDefNames[id] == u and u.unitname == id and u.name == name, id)
  assert(u.script == UnitDefs[source].script and u.objectname == UnitDefs[source].objectname, id)
  assert(u.metalcost == metal and u.energycost == energy and u.health == hp and u.maxdamage == hp and u.buildtime > 0, id)
  assert(math.floor(u.airsightdistance / 128) * 128 >= range, id .. " quantized air LOS too short")
  assert(u.customparams.techlevel == 3 and u.customparams.unitgroup == "aa", id)
  assert(u.customparams.i18n_en_humanname == name and u.customparams.i18n_en_tooltip:match("^T3 anti%-air"), id)

  local mount = assert(u.weapons[1], id)
  assert(next(u.weapons, 1) == nil and mount.onlytargetcategory == "VTOL", id)
  assert(mount.maindir == nil and mount.maxangledif == nil and mount.slaveto == nil, id)
  if count > 1 then assert(mount.burstcontrolwhenoutofarc == 1, id) end
  local key = mount.def:lower()
  local w = assert(u.weapondefs[key], id .. " unresolved mount")
  for def in pairs(u.weapondefs) do assert(def == key, id .. " has an unmounted definition") end
  assert(w.weapontype == kind and w.range == range and w.areaofeffect == aoe, id)
  assert(w.damage.vtol == damage and w.damage.default == 0, id)
  assert(w.paralyzer == false and not w.paralyzetime and w.turret and w.canattackground == false, id)
  assert(w.stockpile == false and not w.stockpiletime and w.energypershot == 0 and w.metalpershot == 0, id)
  assert(not (w.customparams and w.customparams.stockpilelimit) and not w.commandfire and not w.interceptor, id)
  assert(w.noselfdamage and w.collidefriendly == false and w.collidefeature == false, id)
  if aoe == 0 then assert(w.impactonly, id) end
  if kind == "LaserCannon" then
    local perFrame = w.weaponvelocity / 30
    assert(not w.model and perFrame == 70 and math.floor(range / perFrame) * perFrame == range, id)
  elseif kind == "BeamLaser" then
    assert(not w.model and w.minintensity == 1 and not w.sweepfire, id)
  elseif kind == "Cannon" then
    assert(w.burnblow and w.cylindertargeting == 1 and not w.model, id)
  else
    assert(w.tracks and w.turnrate > 0 and w.flighttime * w.weaponvelocity > w.range, id)
    assert(w.model == (count == 1 and "corscreamermissile.s3o" or "legsmallrocket.s3o"), id)
    assert(w.cegtag == (count == 1 and "missiletrailaa-large" or "missiletrailaa"), id)
  end

  local starts, shots = cadence(w, period * 2)
  assert(#starts == 3 and starts[1] == 0 and starts[2] == period and starts[3] == period * 2, id)
  assert(#shots == count * 2 + 1 and (w.projectiles or 1) == 1, id)
  for i = 1, count do
    assert(shots[i] == (i - 1) * gap and shots[count + i] == period + (i - 1) * gap, id)
  end
  assert(w.damage.vtol * count * 30 / period == dps, id)
end

applyPack()
for id, u in pairs(UnitDefs) do
  if id:match("^player_") then assert(installed[id] == u, id .. " unexpected definition") end
end
for id, u in pairs(installed) do
  assert(UnitDefs[id] == u and UnitDefNames[id] == u, id .. " changed on repeat loading")
end
for builder, stock in pairs(menus) do
  local options = UnitDefs[builder].buildoptions
  local added = eligible[builder:sub(4)] and byFaction[builder:sub(1, 3)] or {}
  assert(#options == #stock + #added, builder .. " menu size")
  for i, option in ipairs(stock) do assert(options[i] == option, builder .. " changed a stock choice") end
  for i, option in ipairs(added) do assert(options[#stock + i] == option, builder .. " wrong added choice") end
end
assert(mercury.stockpile and mercury.energypershot == 1800 and mercury.customparams.stockpilelimit == 5)
assert(screamer.stockpile and screamer.energypershot == 1800 and screamer.customparams.stockpilelimit == 5)
assert(lupara.weapons[2].def == "extra" and lupara.weapondefs.legflak_gun.paralyzer)
assert(lupara.sfxtypes.explosiongenerators[1] == "custom:barrelshot-flak")
assert(installed.player_leg_skyspearbattery.sfxtypes.explosiongenerators[1] == "custom:barrelshot-medium-aa")

-- Missing chassis or unrelated collisions never add a dangling/unrelated menu entry.
local blocker = { name = "Unrelated" }
local stockMercury = UnitDefs.armmercury
UnitDefs, UnitDefNames = { armack = {}, armnanotct3 = {}, player_arm_skywardlance = blocker }, nil
applyPack()
assert(UnitDefs.player_arm_silencearray == nil and UnitDefs.player_arm_skywardlance == blocker)
assert(UnitDefs.armnanotct3.buildoptions == nil)
-- BAR's defs preprocessing does not require the optional name lookup table.
UnitDefs.armmercury = stockMercury
applyPack()
assert(UnitDefs.player_arm_silencearray and #UnitDefs.armnanotct3.buildoptions == 1)
assert(UnitDefs.armnanotct3.buildoptions[1] == "player_arm_silencearray")
assert(UnitDefs.armack.buildoptions == nil)

print("standalone T3 anti-air runtime checks passed")
