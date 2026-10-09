do
local function copy(t)
  if type(t) ~= "table" then return t end
  local r = {}
  for k, v in pairs(t) do r[copy(k)] = copy(v) end
  return r
end
local function add(b, u)
  if b == nil or b.buildoptions == nil then return end
  for k = 1, #b.buildoptions do if b.buildoptions[k] == u then return end end
  b.buildoptions[#b.buildoptions + 1] = u
end
local LANGS = { "en", "de", "fr", "es", "it", "ru", "zh", "cs", "hr", "lt" }
local B3 = { arm = { "armack", "armacv", "armaca" }, cor = { "corack", "coracv", "coraca" }, leg = { "legack", "legacv", "legaca" } }
local SUB = { armack = "armacsub", corack = "coracsub", legack = "legacsub" }
local SPECS = {
  { dst = "armmoho_t3", src = "armmoho", tech = 3, x = 0.008, mx = 8, up = 90, sto = 1200,
    nm = "Armada T3 Metal Extractor", tip = "Produces 8 metal, upkeep 60E, storage 1200. Explodes violently if destroyed.",
    m = 4500, e = 60000, bt = 52000, hp = 7500 },
  { dst = "cormoho_t3", src = "cormoho", tech = 3, x = 0.008, mx = 8, up = 90, sto = 1200,
    nm = "Cortex T3 Metal Extractor", tip = "Produces 8 metal, upkeep 60E, storage 1200. Explodes violently if destroyed.",
    m = 5200, e = 78000, bt = 58000, hp = 9500 },
  { dst = "legmoho_t3", src = "legmoho", tech = 3, x = 0.008, mx = 8, up = 90, sto = 1200,
    nm = "Legion T3 Metal Extractor", tip = "Produces 8 metal, upkeep 60E, storage 1200. Explodes violently if destroyed.",
    m = 5200, e = 78000, bt = 58000, hp = 9500 },
  { dst = "armmoho_t4", src = "armmoho", tech = 4, x = 0.016, mx = 16, up = 240, sto = 2000,
    nm = "Armada T4 Metal Extractor", tip = "Produces 16 metal, upkeep 150E, storage 2000. Explodes catastrophically if destroyed.",
    m = 16000, e = 270000, bt = 180000, hp = 17000 },
  { dst = "cormoho_t4", src = "cormoho", tech = 4, x = 0.016, mx = 16, up = 240, sto = 2000,
    nm = "Cortex T4 Metal Extractor", tip = "Produces 16 metal, upkeep 150E, storage 2000. Explodes catastrophically if destroyed.",
    m = 18500, e = 320000, bt = 200000, hp = 20000 },
  { dst = "legmoho_t4", src = "legmoho", tech = 4, x = 0.016, mx = 16, up = 240, sto = 2000,
    nm = "Legion T4 Metal Extractor", tip = "Produces 16 metal, upkeep 150E, storage 2000. Explodes catastrophically if destroyed.",
    m = 18500, e = 320000, bt = 200000, hp = 20000 },
}
local BLASTS = {
  mexboom_t3 = { AreaOfEffect = 600, cameraShake = 300, impulsefactor = 0.123, soundhit = "xplomed1", soundstart = "largegun", explosiongenerator = "custom:genericbuildingexplosion-large", damage = { default = 3000 }, customparams = { unitexplosion = 1 } },
  mexboom_t3_selfd = { AreaOfEffect = 900, cameraShake = 450, impulsefactor = 0.123, soundhit = "xplolrg3", soundstart = "largegun", explosiongenerator = "custom:genericbuildingexplosion-huge", damage = { default = 9000 }, customparams = { unitexplosion = 1 } },
  mexboom_t4 = { AreaOfEffect = 1200, cameraShake = 600, impulsefactor = 0.123, soundhit = "xplolrg3", soundstart = "largegun", explosiongenerator = "custom:genericbuildingexplosion-huge", damage = { default = 25000 }, customparams = { unitexplosion = 1 } },
  mexboom_t4_selfd = { AreaOfEffect = 2000, cameraShake = 1000, impulsefactor = 0.123, soundhit = "xplonuk3", soundstart = "largegun", explosiongenerator = "custom:genericbuildingexplosion-gigantic", damage = { default = 90000 }, customparams = { unitexplosion = 1 } },
}
for i = 1, #SPECS do
  local sp = SPECS[i]
  local s = UnitDefs[sp.src]
  if s ~= nil then
    local u = copy(s)
    u.unitname = sp.dst
    u.name = sp.nm
    u.extractsmetal = sp.x
    u.energyupkeep = sp.up
    u.metalstorage = sp.sto
    u.metalcost = sp.m
    u.energycost = sp.e
    u.buildtime = sp.bt
    u.health = sp.hp
    u.activatewhenbuilt = true
    u.onoffable = true
    u.buildoptions = u.buildoptions or {}
    u.weapondefs = u.weapondefs or {}
    u.weapons = u.weapons or {}
    local suffix = "_t" .. sp.tech
    local normal, selfd = "mexboom" .. suffix, "mexboom" .. suffix .. "_selfd"
    u.weapondefs[normal] = copy(BLASTS[normal])
    u.weapondefs[selfd] = copy(BLASTS[selfd])
    u.explodeas, u.selfdestructas = normal, selfd
    u.customparams = u.customparams or {}
    u.customparams.techlevel = sp.tech
    u.customparams.metal_extractor = sp.mx
    u.customparams.standardextractor = true
    for j = 1, #LANGS do
      local L = LANGS[j]
      u.customparams["i18n_" .. L .. "_humanname"] = sp.nm
      u.customparams["i18n_" .. L .. "_tooltip"] = sp.tip
    end
    UnitDefs[sp.dst] = u
    if UnitDefNames ~= nil then UnitDefNames[sp.dst] = u end
    local fac = sp.src:sub(1, 3)
    local bl = B3[fac]
    if sp.tech == 3 then
      if bl ~= nil then for j = 1, #bl do add(UnitDefs[bl[j]], sp.dst) end end
      local sub = SUB[fac .. "ack"]
      if sub ~= nil and u.maxwaterdepth ~= nil then add(UnitDefs[sub], sp.dst) end
    else
      -- T4FALLBACK: no baseline T3 builder keys exist; use same-faction T2 constructors until real T3 builders are known.
      if bl ~= nil then for j = 1, #bl do add(UnitDefs[bl[j]], sp.dst) end end
    end
  end
end
end
