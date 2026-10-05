-- Mega pack, air half: aerial dreadnoughts. Split from player-mega-pack to fit one lobby slot.
do
local U, lower = UnitDefs, string.lower

local function copy(t)
  if type(t) ~= "table" then return t end
  local r = {}
  for k, v in pairs(t) do r[copy(k)] = copy(v) end
  return r
end

local function teach(bld, dst)
  for b in bld:gmatch("%S+") do
    local u = U[b]
    if u then
      u.buildoptions = u.buildoptions or {}
      local has = false
      for _, x in ipairs(u.buildoptions) do if x == dst then has = true break end end
      if not has then u.buildoptions[#u.buildoptions + 1] = dst end
    end
  end
end

local function install(u, key, wep, cat)
  key = key:lower()
  u.weapondefs, u.weapons = u.weapondefs or {}, u.weapons or {}
  local oldW, suite = u.weapons, wep.is_suite and wep.slots or { [1] = wep }
  u.weapons = {}

  for idx, w in pairs(suite) do
    local k = wep.is_suite and (key .. "_" .. idx) or key
    w.noselfdamage, w.turret = true, true
    u.weapondefs[k] = copy(w)
    local m = { def = k, onlytargetcategory = w.onlytargetcategory or cat }
    if oldW[idx] then
      for pk, pv in pairs(oldW[idx]) do
        if pk ~= "def" and m[pk] == nil and pk ~= "onlytargetcategory" and (wep.is_suite or (pk ~= "maindir" and pk ~= "maxangledif")) then
          m[pk] = copy(pv)
        end
      end
    end
    u.weapons[idx] = m
  end

  if #oldW > #u.weapons then
    local dKey = key .. "_dummy"
    u.weapondefs[dKey] = {
      name = "Dummy", weapontype = "Cannon", range = 1, reloadtime = 9999,
      damage = { default = 0 }, noselfdamage = true, turret = true,
      explosiongenerator = "custom:genericshellexplosion-tiny",
    }
    for sIdx = #u.weapons + 1, #oldW do
      local sSlot = oldW[sIdx]
      local dSlot = { def = dKey, onlytargetcategory = "NONE", badtargetcategory = "ALL" }
      if sSlot then
        dSlot.maindir, dSlot.maxangledif = sSlot.maindir, sSlot.maxangledif
      end
      u.weapons[sIdx] = dSlot
    end
  end
end

local function findSrc(c)
  for i = 1, #c do
    local s = U[c[i]] or U[lower(c[i])]
    if s then return s, c[i] end
  end
end

local LAND_GANTRIES = "armshltx corgant leggant"
local EXP_AIR = "armapt3 corapt3 legapt3"
local FB_AIR = "armaap coraap legaap"

local function getAir()
  for b in EXP_AIR:gmatch("%S+") do if U[b] then return EXP_AIR end end
  return FB_AIR
end

local S_CNH, S_NU4, S_M1, S_M2, S_FLK_F, S_FLK_H, S_RCK =
  "weapons/cannon_heavy.wav", "weapons/xplonuk4.wav", "weapons/xplomed1.wav",
  "weapons/xplomed2.wav", "weapons/flak_fire.wav", "weapons/flak_hit.wav", "weapons/rockhvy1.wav"

local C_TAC, C_FLK, C_BRN, E_FN4, E_FN2, E_EMP, E_SHL =
  "cruisemissiletrail-tacnuke", "flakshard", "burnflame",
  "custom:FLASHNUKE480", "custom:FLASHNUKE280", "custom:exp_emp_large", "custom:genericshellexplosion-huge"

local T_S, T_V, T_SV = "SURFACE", "VTOL", "SURFACE VTOL"

local WEAPONS = {
  emp = {
    name = "Atmospheric EMP", weapontype = "Cannon", energypershot = 820e3, paralyzer = true,
    paralyzetime = 180, accuracy = 320, areaofeffect = 2200, range = 3600, reloadtime = 2.2, weaponvelocity = 2400,
    size = 40, stages = 44, intensity = 3.2, rgbcolor = "0.6 0.1 0.95", cegtag = "heatcloud-rot-purple",
    explosiongenerator = E_EMP, soundstart = S_CNH, soundhitdry = S_M2,
    damage = { default = 1900000, commandertoo = 900000 }, onlytargetcategory = T_SV,
  },

  aether_main = {
    name = "Aether Siege Mortar", weapontype = "Cannon", energypershot = 520e3,
    accuracy = 340, sprayangle = 800, areaofeffect = 1600, range = 4200, reloadtime = 1.1,
    weaponvelocity = 3000, size = 30, stages = 40, rgbcolor = "0.9 0.8 0.2", cegtag = "arty-large",
    explosiongenerator = E_SHL, soundstart = S_CNH, soundhitdry = S_M1,
    craterboost = 15, cratermult = 11, impulsefactor = 45, impulseboost = 32, camerashake = 200,
    firestarter = 100, damage = { default = 210000, shields = 520000, commandertoo = 36000 }, onlytargetcategory = T_S,
  },

  aether_sec = {
    name = "Aether Deck Cannon", weapontype = "Cannon", energypershot = 1400,
    accuracy = 400, sprayangle = 900, areaofeffect = 520, range = 2800, reloadtime = 0.18,
    burst = 12, burstrate = 0.03, weaponvelocity = 4200, size = 10, rgbcolor = "1.0 0.85 0.3",
    explosiongenerator = "custom:genericshellexplosion-medium", soundstart = "weapons/cannhvy1.wav",
    soundhitdry = S_M2, damage = { default = 9800, shields = 26000, commandertoo = 1800 }, onlytargetcategory = T_S,
  },

aether_aa = {
    name = "Aether SAM", weapontype = "MissileLauncher", energypershot = 9000,
    range = 3200, reloadtime = 0.5,
    burst = 24,
    burstrate = 0.02,
    sprayangle = 900,
    weaponvelocity = 5200, startvelocity = 2200, weaponacceleration = 3200, flighttime = 8,
    tracks = true, turnrate = 150e3, dance = 4, wobble = 80, areaofeffect = 320, cegtag = "missiletrailaa",
    explosiongenerator = "custom:genericshellexplosion-medium-aa",
    soundstart = S_RCK, soundhitdry = S_M2,
    damage = { default = 3000, vtol = 38000, shields = 12000 },
    onlytargetcategory = T_V,
  },

  torpedo = {
    name = "Voidstrike Torpedoes", weapontype = "MissileLauncher", energypershot = 420e3,
    burst = 10, burstrate = 0.12, range = 3800, reloadtime = 1.6, weaponvelocity = 1600, weaponacceleration = 900,
    flighttime = 14, tracks = true, turnrate = 90e3, dance = 20, wobble = 1400, size = 24, rgbcolor = "0.0 1.0 0.55",
    cegtag = C_TAC, explosiongenerator = E_SHL, soundstart = S_RCK, soundhitdry = S_M1,
    firestarter = 100, damage = { default = 165000, shields = 620000, commandertoo = 26000 }, onlytargetcategory = T_S,
  },

  vulcan = {
    name = "Rotary Vulcan Array", weapontype = "Cannon", energypershot = 620, burst = 200,
    burstrate = 0.008, sprayangle = 1500, accuracy = 500, range = 2600, reloadtime = 1.2, weaponvelocity = 5200,
    size = 9, stages = 26, rgbcolor = "1.0 0.7 0.15", cegtag = C_FLK, explosiongenerator = "custom:genericshellexplosion-small",
    soundstart = S_FLK_F, soundhitdry = "weapons/xplosml2.wav", edgeeffectiveness = 0.85,
    damage = { default = 9200, vtol = 26000, shields = 6400, commandertoo = 2000 },
    onlytargetcategory = T_SV,
  },

}

-- { dst, srcs, key, weapon, name, tip, {m,e,hp,spd,cap,eu,emake,heal,jam,air,cat} }
local SPECS = {
{
    "player_singularity", { "corcrwt4", "corcrw" }, "player_singularityemp", WEAPONS.emp, "Singularity",
    "Aerial EMP dreadnought. Freezes frontlines.", { 1.5e6, 32e6, 3.1e6, 64, 2, 14000, 0, 560, 0, true }
  },
{
    "player_aethersiege",
    { "armfepocht4", "armepocht4", "armepoch_vtol", "armt4air", "armcybr", "legfortt4" },
    "player_aether",
    { is_suite = true, slots = { [1] = WEAPONS.aether_aa, [2] = WEAPONS.aether_main, [3] = WEAPONS.aether_sec } },
    "Aether Siege Fortress", "Aerial flagship. Siege mortars, cannons.",
    { 1.5e6, 31e6, 3.0e6, 56, 3, 12000, 0, 540, 0, true }
  },
{
    "player_phantomleviathan", { "corcrw", "corcrwt4" }, "player_phantomtorpedo", WEAPONS.torpedo, "Phantom Leviathan",
    "Stealth dreadnought. Radar jammer, torpedoes.", { 1.45e6, 30e6, 2.8e6, 70, 3, 12000, 0, 520, 1350, true }
  },
{
    "player_archangel", { "legfortt4", "corcrwt4", "corcrw" }, "player_archangelvulcan", WEAPONS.vulcan, "Archangel Gunship",
    "CAS dreadnought. 200-round rotary Vulcan.", { 1.45e6, 29e6, 3.0e6, 72, 3, 9000, 0, 520, 0, true }
  },
}

local airBld = getAir()

for i = 1, #SPECS do
  local p = SPECS[i]
  local s = findSrc(p[2])

  if s and not U[p[1]] then
    local u = copy(s)
    local st = p[7]
    local isAir = st[10]

    u.unitname, u.name, u.description = p[1], p[5], p[6]
    u.metalcost, u.energycost, u.buildtime = st[1], st[2], st[2]
    u.health, u.maxdamage = st[3], st[3]
    u.speed, u.maxthisunit, u.energyupkeep = st[4], st[5], st[6]

    u.energymake = st[7] or 0
    u.autoheal = st[8] or 120
    u.sightdistance = math.max(u.sightdistance or 0, 1100)
    u.radardistance = math.max(u.radardistance or 0, 2600)
    u.activatewhenbuilt = true

    u.builder, u.buildoptions, u.cantbetransported = false, nil, true
    u.transportcapacity, u.transportsize = nil, nil
    u.cancloak, u.cloakable, u.initcloaked = false, false, false
    u.radardistancejam = (st[9] and st[9] > 0) and st[9] or 0

    if isAir then
      u.canfly, u.hoverattack, u.airhoverfactor = true, true, 0.15
      u.cruisealt, u.turnrate, u.collide = 310, 480, true
      u.maxacc, u.maxdec = 0.08, 0.08
    else
      u.canfly, u.canhover, u.floater = false, false, false
      u.minwaterdepth, u.maxwaterdepth, u.upright = nil, 48, true
    end

    u.customparams = u.customparams or {}
    u.customparams.techlevel, u.customparams.unitgroup = 4, "weapon"
    for l in ("en de fr es it ru zh cs hr lt"):gmatch("%S+") do
      u.customparams["i18n_" .. l .. "_humanname"] = p[5]
      u.customparams["i18n_" .. l .. "_tooltip"] = p[6]
    end

    install(u, p[3], p[4], st[11])

    U[p[1]] = u
    if UnitDefNames then UnitDefNames[p[1]] = u end

    teach(isAir and airBld or LAND_GANTRIES, p[1])
  end
end
end
