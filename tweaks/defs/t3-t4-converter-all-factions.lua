-- T3-T4 energy-to-metal converters for Armada, Cortex, Legion (tweakdefs, runnable with UnitDefs in scope).
-- Usage: !bset tweakdefs <b64(min(file))>  (single slot; comments stripped by minifier)
-- Baselines (T2 Moho makers, BAR master: cap 600 / eff 0.01724 ~= 10.3M @ 600E):
--   armmmkr: 380M / 21000E / BT35000 / HP445 | cormmkr, legadveconv: 370M / 21000E / BT31300 / HP560
-- Stats (clone of same-faction T2 maker, BAR model kept):
--   T3 Converter: cap 2400 / eff 0.015 (~36M @ 2400E, worse rate than T2), tech 3.
--       Arm 2600M / 90000E / BT60000 / HP2500; Cor/Leg 2800M / 95000E / BT65000 / HP2800.
--   T4 Converter: cap 6000 / eff 0.014 (~84M @ 6000E), tech 4.
--       Arm 9000M / 300000E / BT180000 / HP8000; Cor/Leg 10000M / 330000E / BT200000 / HP9000.
-- Balance: output 3.5x/8x vs T2 for ~7x/25x metal cost — late-game metal at a premium,
--   and efficiency per energy falls per tier (0.01724 > 0.015 > 0.014).
-- Blast: VERY explosive on purpose — 4 unique blast weapondefs, bigger than T4 energy storage.
--   convboom_t3 (+_selfd): 8000/960, 24000/1536. convboom_t4 (+_selfd): 20000/1200, 60000/1920.
-- Builders: T3 appended to same-faction T2 constructors (ack/acv/aca). T4 ideally belongs to
--   T3 constructors, but no baseline T3 builder keys exist, so T4 falls back to the same T2
--   constructors (see T4FALLBACK below); move T4 entries to real T3 builders when known.
-- Names: proper nouns shared across all 10 i18n langs (en,de,fr,es,it,ru,zh,cs,hr,lt).
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
local BLASTS = {
  convboom_t3 = { AreaOfEffect = 960, cameraShake = 480, impulsefactor = 0.123, soundhit = "xplonuk3", soundstart = "largegun", explosiongenerator = "custom:genericbuildingexplosion-huge", damage = { default = 8000 }, customparams = { unitexplosion = 1 } },
  convboom_t3_selfd = { AreaOfEffect = 1536, cameraShake = 768, impulsefactor = 0.123, soundhit = "xplonuk3", soundstart = "largegun", explosiongenerator = "custom:genericbuildingexplosion-gigantic", damage = { default = 24000 }, customparams = { unitexplosion = 1 } },
  convboom_t4 = { AreaOfEffect = 1200, cameraShake = 480, impulsefactor = 0.123, soundhit = "xplonuk3", soundstart = "largegun", explosiongenerator = "custom:genericbuildingexplosion-huge", damage = { default = 20000 }, customparams = { unitexplosion = 1 } },
  convboom_t4_selfd = { AreaOfEffect = 1920, cameraShake = 768, impulsefactor = 0.123, soundhit = "xplonuk3", soundstart = "largegun", explosiongenerator = "custom:genericbuildingexplosion-gigantic", damage = { default = 60000 }, customparams = { unitexplosion = 1 } },
}
local WIRE = { [3] = { "convboom_t3", "convboom_t3_selfd" }, [4] = { "convboom_t4", "convboom_t4_selfd" } }
local SPECS = {
  { dst = "armmmkr_t3", src = "armmmkr", tech = 3, cap = 2400, eff = 0.015,
    nm = "Armada T3 Converter", tip = "Converts 2400 energy into ~36 metal. Explodes violently.",
    m = 2600, e = 90000, bt = 60000, hp = 2500 },
  { dst = "cormmkr_t3", src = "cormmkr", tech = 3, cap = 2400, eff = 0.015,
    nm = "Cortex T3 Converter", tip = "Converts 2400 energy into ~36 metal. Explodes violently.",
    m = 2800, e = 95000, bt = 65000, hp = 2800 },
  { dst = "legadveconv_t3", src = "legadveconv", tech = 3, cap = 2400, eff = 0.015,
    nm = "Legion T3 Converter", tip = "Converts 2400 energy into ~36 metal. Explodes violently.",
    m = 2800, e = 95000, bt = 65000, hp = 2800 },
  { dst = "armmmkr_t4", src = "armmmkr", tech = 4, cap = 6000, eff = 0.014,
    nm = "Armada T4 Converter", tip = "Converts 6000 energy into ~84 metal. A small nuke when killed.",
    m = 9000, e = 300000, bt = 180000, hp = 8000 },
  { dst = "cormmkr_t4", src = "cormmkr", tech = 4, cap = 6000, eff = 0.014,
    nm = "Cortex T4 Converter", tip = "Converts 6000 energy into ~84 metal. A small nuke when killed.",
    m = 10000, e = 330000, bt = 200000, hp = 9000 },
  { dst = "legadveconv_t4", src = "legadveconv", tech = 4, cap = 6000, eff = 0.014,
    nm = "Legion T4 Converter", tip = "Converts 6000 energy into ~84 metal. A small nuke when killed.",
    m = 10000, e = 330000, bt = 200000, hp = 9000 },
}
for i = 1, #SPECS do
  local sp = SPECS[i]
  local s = UnitDefs[sp.src]
  if s ~= nil then
    local u = copy(s)
    u.unitname = sp.dst
    u.name = sp.nm
    u.metalcost = sp.m
    u.energycost = sp.e
    u.buildtime = sp.bt
    u.health = sp.hp
    u.activatewhenbuilt = true
    u.onoffable = true
    u.buildoptions = u.buildoptions or {}
    u.weapondefs = u.weapondefs or {}
    local bw = WIRE[sp.tech]
    if bw ~= nil then
      u.weapondefs[bw[1]] = copy(BLASTS[bw[1]])
      u.weapondefs[bw[2]] = copy(BLASTS[bw[2]])
      u.explodeas = bw[1]
      u.selfdestructas = bw[2]
    end
    u.weapons = u.weapons or {}
    u.customparams = u.customparams or {}
    u.customparams.techlevel = sp.tech
    u.customparams.energyconv_capacity = sp.cap
    u.customparams.energyconv_efficiency = sp.eff
    for j = 1, #LANGS do
      local L = LANGS[j]
      u.customparams["i18n_" .. L .. "_humanname"] = sp.nm
      u.customparams["i18n_" .. L .. "_tooltip"] = sp.tip
    end
    UnitDefs[sp.dst] = u
    if UnitDefNames ~= nil then UnitDefNames[sp.dst] = u end
    local fac = sp.src:sub(1, 3)
    local bl = B3[fac]
    -- T4FALLBACK: no baseline T3 builder keys exist; use same-faction T2 constructors until real T3 builders are known.
    if bl ~= nil then for j = 1, #bl do add(UnitDefs[bl[j]], sp.dst) end end
  end
end
end
