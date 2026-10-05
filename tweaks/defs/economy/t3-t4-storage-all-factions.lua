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
local SUB = { arm = "armacsub", cor = "coracsub", leg = "legacsub" }
local BLASTS = {
  storagemetalboom_t3 = { AreaOfEffect = 390, cameraShake = 260, impulsefactor = 0.123, soundhit = "xplomed1", soundstart = "largegun", explosiongenerator = "custom:genericbuildingexplosion-medium", damage = { default = 440 }, customparams = { unitexplosion = 1 } },
  storagemetalboom_t3_selfd = { AreaOfEffect = 540, cameraShake = 360, impulsefactor = 0.123, soundhit = "xplomed1", soundstart = "largegun", explosiongenerator = "custom:genericbuildingexplosion-large", damage = { default = 3120 }, customparams = { unitexplosion = 1 } },
  storagemetalboom_t4 = { AreaOfEffect = 680, cameraShake = 340, impulsefactor = 0.123, soundhit = "xplolrg3", soundstart = "largegun", explosiongenerator = "custom:genericbuildingexplosion-large", damage = { default = 2680 }, customparams = { unitexplosion = 1 } },
  storagemetalboom_t4_selfd = { AreaOfEffect = 960, cameraShake = 480, impulsefactor = 0.123, soundhit = "xplolrg3", soundstart = "largegun", explosiongenerator = "custom:genericbuildingexplosion-huge", damage = { default = 8000 }, customparams = { unitexplosion = 1 } },
  storageenergyboom_t3 = { AreaOfEffect = 960, cameraShake = 480, impulsefactor = 0.123, soundhit = "xplonuk3", soundstart = "largegun", explosiongenerator = "custom:genericbuildingexplosion-huge", damage = { commanders = 4680, default = 7950 }, customparams = { unitexplosion = 1 } },
  storageenergyboom_t3_selfd = { AreaOfEffect = 1536, cameraShake = 768, impulsefactor = 0.123, soundhit = "xplonuk3", soundstart = "largegun", explosiongenerator = "custom:genericbuildingexplosion-gigantic", damage = { commanders = 7350, default = 24900 }, customparams = { unitexplosion = 1 } },
  storageenergyboom_t4 = { AreaOfEffect = 1200, cameraShake = 480, impulsefactor = 0.123, soundhit = "xplonuk3", soundstart = "largegun", explosiongenerator = "custom:genericbuildingexplosion-huge", damage = { commanders = 9360, default = 15900 }, customparams = { unitexplosion = 1 } },
  storageenergyboom_t4_selfd = { AreaOfEffect = 1920, cameraShake = 768, impulsefactor = 0.123, soundhit = "xplonuk3", soundstart = "largegun", explosiongenerator = "custom:genericbuildingexplosion-gigantic", damage = { commanders = 14700, default = 49800 }, customparams = { unitexplosion = 1 } },
}
local WIRE = {
  m3 = { "storagemetalboom_t3", "storagemetalboom_t3_selfd" },
  m4 = { "storagemetalboom_t4", "storagemetalboom_t4_selfd" },
  e3 = { "storageenergyboom_t3", "storageenergyboom_t3_selfd" },
  e4 = { "storageenergyboom_t4", "storageenergyboom_t4_selfd" },
}
local SPECS = {
  -- T3 Metal Storage
  { dst = "armuwadvmst3", src = "armuwadvms", fac = "arm", res = "m", tech = 3, sto = 40000,
    nm = "Armada T3 Metal Storage", tip = "Increases metal storage capacity by 40000.",
    m = 4800, e = 80000, bt = 120000, hp = 52000 },
  { dst = "coruwadvmst3", src = "coruwadvms", fac = "cor", res = "m", tech = 3, sto = 40000,
    nm = "Cortex T3 Metal Storage", tip = "Increases metal storage capacity by 40000.",
    m = 5300, e = 90000, bt = 128000, hp = 56000 },
  { dst = "legamstort3", src = "legamstor", fac = "leg", res = "m", tech = 3, sto = 40000,
    nm = "Legion T3 Metal Storage", tip = "Increases metal storage capacity by 40000.",
    m = 5300, e = 90000, bt = 128000, hp = 56000 },

  -- T4 Metal Storage
  { dst = "armuwadvmst4", src = "armuwadvms", fac = "arm", res = "m", tech = 4, sto = 160000,
    nm = "Armada T4 Metal Storage", tip = "Increases metal storage capacity by 160000.",
    m = 19000, e = 340000, bt = 480000, hp = 195000 },
  { dst = "coruwadvmst4", src = "coruwadvms", fac = "cor", res = "m", tech = 4, sto = 160000,
    nm = "Cortex T4 Metal Storage", tip = "Increases metal storage capacity by 160000.",
    m = 21500, e = 390000, bt = 520000, hp = 225000 },
  { dst = "legamstort4", src = "legamstor", fac = "leg", res = "m", tech = 4, sto = 160000,
    nm = "Legion T4 Metal Storage", tip = "Increases metal storage capacity by 160000.",
    m = 21500, e = 390000, bt = 520000, hp = 225000 },

  -- T3 Energy Storage
  { dst = "armuwadvest3", src = "armuwadves", fac = "arm", res = "e", tech = 3, sto = 250000,
    nm = "Armada T3 Energy Storage", tip = "Increases energy storage capacity by 250000. Dangerous if destroyed.",
    m = 5200, e = 95000, bt = 120000, hp = 52000 },
  { dst = "coruwadvest3", src = "coruwadves", fac = "cor", res = "e", tech = 3, sto = 250000,
    nm = "Cortex T3 Energy Storage", tip = "Increases energy storage capacity by 250000. Dangerous if destroyed.",
    m = 5700, e = 105000, bt = 128000, hp = 56000 },
  { dst = "legadvestoret3", src = "legadvestore", fac = "leg", res = "e", tech = 3, sto = 250000,
    nm = "Legion T3 Energy Storage", tip = "Increases energy storage capacity by 250000. Dangerous if destroyed.",
    m = 5700, e = 105000, bt = 128000, hp = 56000 },

  -- T4 Energy Storage
  { dst = "armuwadvest4", src = "armuwadves", fac = "arm", res = "e", tech = 4, sto = 1500000,
    nm = "Armada T4 Energy Storage", tip = "Increases energy storage capacity by 1500000. Dangerous if destroyed.",
    m = 20500, e = 470000, bt = 480000, hp = 195000 },
  { dst = "coruwadvest4", src = "coruwadves", fac = "cor", res = "e", tech = 4, sto = 1500000,
    nm = "Cortex T4 Energy Storage", tip = "Increases energy storage capacity by 1500000. Dangerous if destroyed.",
    m = 23000, e = 530000, bt = 520000, hp = 225000 },
  { dst = "legadvestoret4", src = "legadvestore", fac = "leg", res = "e", tech = 4, sto = 1500000,
    nm = "Legion T4 Energy Storage", tip = "Increases energy storage capacity by 1500000. Dangerous if destroyed.",
    m = 23000, e = 530000, bt = 520000, hp = 225000 },
}
for i = 1, #SPECS do
  local sp = SPECS[i]
  local s = UnitDefs[sp.src]
  if s ~= nil then
    local u = copy(s)
    u.unitname = sp.dst
    u.name = sp.nm
    if sp.res == "m" then
      u.metalstorage = sp.sto
      u.energystorage = 0
    else
      u.energystorage = sp.sto
      u.metalstorage = 0
    end
    u.metalcost = sp.m
    u.energycost = sp.e
    u.buildtime = sp.bt
    u.health = sp.hp
    u.techlevel = sp.tech
    u.buildoptions = u.buildoptions or {}
    u.weapondefs = u.weapondefs or {}
    local bw = WIRE[sp.res .. sp.tech]
    if bw ~= nil then
      u.weapondefs[bw[1]] = copy(BLASTS[bw[1]])
      u.weapondefs[bw[2]] = copy(BLASTS[bw[2]])
      u.explodeas = bw[1]
      u.selfdestructas = bw[2]
    end
    u.weapons = u.weapons or {}
    u.customparams = u.customparams or {}
    u.customparams.techlevel = sp.tech
    for j = 1, #LANGS do
      local L = LANGS[j]
      u.customparams["i18n_" .. L .. "_humanname"] = sp.nm
      u.customparams["i18n_" .. L .. "_tooltip"] = sp.tip
    end
    UnitDefs[sp.dst] = u
    if UnitDefNames ~= nil then UnitDefNames[sp.dst] = u end
    local bl = B3[sp.fac]
    if sp.tech == 3 then
      if bl ~= nil then for j = 1, #bl do add(UnitDefs[bl[j]], sp.dst) end end
      local sub = SUB[sp.fac]
      if sub ~= nil and u.maxwaterdepth ~= nil then add(UnitDefs[sub], sp.dst) end
    else
      -- T4FALLBACK: no baseline T3 builder keys exist; use same-faction T2 constructors until real T3 builders are known.
      if bl ~= nil then for j = 1, #bl do add(UnitDefs[bl[j]], sp.dst) end end
      local sub = SUB[sp.fac]
      if sub ~= nil and u.maxwaterdepth ~= nil then add(UnitDefs[sub], sp.dst) end
    end
  end
end
end
