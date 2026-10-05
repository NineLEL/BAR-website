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
  jump = {
    name = "Rift Singularity Cannon", weapontype = "Cannon", energypershot = 620e3,
    accuracy = 300, areaofeffect = 1600, range = 4600, reloadtime = 1.6, weaponvelocity = 2600,
    size = 34, stages = 48, alpha = 0.95, intensity = 3.5, rgbcolor = "0.0 0.95 1.0",
    cegtag = C_TAC, explosiongenerator = E_FN2, soundstart = S_CNH, soundhitdry = S_M1,
    craterboost = 18, cratermult = 14, impulsefactor = 60, impulseboost = 40, camerashake = 220,
    firestarter = 100, damage = { default = 240000, shields = 320000, commandertoo = 40000 }, onlytargetcategory = T_S,
  },

  vortex = {
    name = "Singularity Inversion Well", weapontype = "Cannon", energypershot = 620e3,
    accuracy = 240, areaofeffect = 2000, range = 4200, reloadtime = 1.8, weaponvelocity = 1600,
    size = 36, stages = 44, rgbcolor = "0.35 0.05 0.55", cegtag = "heatcloud-rot-purple",
    explosiongenerator = E_EMP, soundstart = S_CNH, soundhitdry = S_NU4,
    impulsefactor = -60, impulseboost = -40, craterboost = 0, cratermult = 0, camerashake = 200,
    damage = { default = 120000, shields = 480000, commandertoo = 20000 }, onlytargetcategory = T_S,
  },

  crack = {
    name = "Tungsten Sabot Shotgun", weapontype = "Cannon", energypershot = 420e3,
    projectilespershot = 16, sprayangle = 1400, accuracy = 300, areaofeffect = 700, range = 3200,
    reloadtime = 1.2, weaponvelocity = 3600, size = 20, stages = 36, rgbcolor = "1.0 0.5 0.1",
    cegtag = "volcano_rock_trail", explosiongenerator = "custom:genericshellexplosion-large",
    soundstart = S_CNH, soundhitdry = S_M1, craterboost = 9, cratermult = 7, edgeeffectiveness = 0.9, camerashake = 160,
    damage = { default = 96000, shields = 520000, commandertoo = 18000 }, onlytargetcategory = T_S,
  },

  sol = {
    name = "Supernova Cataclysm", weapontype = "Cannon", energypershot = 1200e3,
    accuracy = 160, areaofeffect = 2400, edgeeffectiveness = 0.9, burnblow = true, firestarter = 100,
    range = 4600, reloadtime = 2.0, weaponvelocity = 800, size = 70, stages = 64, intensity = 6, alpha = 1,
    rgbcolor = "1.0 0.45 0.02", cegtag = C_BRN, explosiongenerator = E_FN4, soundstart = S_CNH, soundhitdry = S_NU4,
    craterboost = 20, cratermult = 16, impulsefactor = 45, impulseboost = 32, camerashake = 500,
    damage = { default = 620000, shields = 1600000, commandertoo = 110000 }, onlytargetcategory = T_S,
  },

  flak = {
    name = "Thermite Flak Storm", weapontype = "Cannon", canattackground = false, burnblow = true,
    energypershot = 1400, burst = 60, burstrate = 0.012, sprayangle = 2600, range = 3400, reloadtime = 0.8,
    weaponvelocity = 4200, areaofeffect = 700, edgeeffectiveness = 0.95, size = 12, rgbcolor = "1.0 0.45 0.1",
    cegtag = C_FLK, explosiongenerator = "custom:flakshard", soundstart = S_FLK_F, soundhitdry = S_FLK_H,
    damage = { default = 2200, vtol = 46000, shields = 14000 }, onlytargetcategory = T_V,
  },

  tesla = {
    name = "Tesla Chain Battery", weapontype = "LightningCannon", energypershot = 900,
    projectilespershot = 8, burst = 20, burstrate = 0.02, sprayangle = 3000, range = 2400, reloadtime = 0.5,
    weaponvelocity = 5200, thickness = 20, rgbcolor = "0.2 0.85 1.0",
    explosiongenerator = "custom:genericshellexplosion-small-lightning", soundstart = "weapons/tecl_fire.wav",
    soundhitdry = "weapons/lashit.wav", areaofeffect = 260, edgeeffectiveness = 0.9,
    damage = { default = 6800, vtol = 24000, shields = 5200, commandertoo = 1600 },
    onlytargetcategory = T_SV,
  },

  pyro = {
    name = "Carpet Fire Mortar", weapontype = "Cannon", energypershot = 1100, burst = 60, burstrate = 0.02,
    sprayangle = 2400, accuracy = 600, range = 3000, reloadtime = 1.4, weaponvelocity = 1400, groundbounce = true,
    bouncerebound = 0.72, bounceminspeed = 260, numsubcatches = 4, firestarter = 100, size = 14, stages = 32,
    rgbcolor = "1.0 0.35 0.05", cegtag = C_BRN, explosiongenerator = "custom:napalm_fire", soundstart = S_CNH,
    soundhitdry = S_M2, areaofeffect = 620, edgeeffectiveness = 0.92, cratermult = 0.2, camerashake = 120,
    damage = { default = 28000, shields = 120000, commandertoo = 5000 }, onlytargetcategory = T_S,
  },

  beam = {
    name = "Annihilation Lance", weapontype = "BeamLaser", largebeamlaser = true,
    energypershot = 900e3, beamtime = 3.6, beamttl = 220, thickness = 70, corethickness = 2.6, laserflaresize = 40,
    pulsespeed = 8, scrollspeed = 8, rgbcolor = "0.75 0.05 1.0", rgbcolor2 = "0.45 0.0 0.85", range = 4000,
    reloadtime = 1.2, firestarter = 100, explosiongenerator = E_FN2, soundstart = "weapons/beam_heavy.wav", soundhitdry = "weapons/burn02.wav",
    damage = { default = 420000, shields = 900000, commandertoo = 70000 }, onlytargetcategory = T_S,
  },
}

-- { dst, srcs, key, weapon, name, tip, {m,e,hp,spd,cap,eu,emake,heal,jam,air,cat} }
local SPECS = {
  {
    "player_riftcolossus", { "armbanth" }, "player_riftjump", WEAPONS.jump, "Rift Colossus",
    "Kinetic titan. Shockwaves and knockback.", { 1.4e6, 28e6, 3.2e6, 62, 3, 9000, 0, 600 }
  },
{
    "player_vortexdominator", { "corjugg" }, "player_vortexwell", WEAPONS.vortex, "Vortex Dominator",
    "Gravitational titan. Negative impulse wells.", { 1.4e6, 27e6, 3.1e6, 52, 3, 10000, 0, 560 }
  },
{
    "player_aegisbreaker", { "armrattet4", "corjugg", "armbanth" }, "player_aegisbreaker", WEAPONS.crack, "Aegis Breaker",
    "Siege shotgun titan. Sabot shield penetrators.", { 1.3e6, 26e6, 2.9e6, 56, 3, 8200, 0, 520 }
  },
{
    "player_solardecimator", { "corjugg", "corkrog", "armbanth" }, "player_solardecimator", WEAPONS.sol, "Sol Decimator",
    "Solar titan. Net +24000 E/s, supernovas.", { 1.7e6, 40e6, 4.0e6, 42, 2, 13000, 24000, 900 }
  },
{
    "player_skyfurnace", { "corkarganetht4", "corkarg", "corkrog" }, "player_skyfurnace", WEAPONS.flak, "Sky Furnace",
    "AA fortress. Thermite flak storm.", { 1.2e6, 24e6, 2.7e6, 58, 4, 7200, 0, 480, 0, false, T_V }
  },
{
    "player_stormsovereign", { "armraz", "armbanth" }, "player_stormtesla", WEAPONS.tesla, "Storm Sovereign",
    "Anti-swarm walker. Chaining tesla.", { 1.25e6, 25e6, 2.8e6, 68, 4, 7600, 0, 500 }
  },
{
    "player_pyroclast", { "armmar", "armbanth" }, "player_pyrocarpet", WEAPONS.pyro, "Pyroclast Dreadnought",
    "Fire titan. Bouncing thermite mortars.", { 1.3e6, 26e6, 2.9e6, 54, 4, 8000, 0, 520 }
  },
{
    "player_worldbeam", { "corkarg", "corkrog" }, "player_worldbeam", WEAPONS.beam, "World Beam",
    "Beam titan. UV annihilation lance.", { 1.4e6, 28e6, 3.0e6, 58, 3, 11000, 0, 560 }
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
