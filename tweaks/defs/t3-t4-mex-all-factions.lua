-- T3-T4 metal extractors for Armada, Cortex, Legion (tweakdefs, runnable with UnitDefs in scope).
-- Usage: !bset tweakdefs <b64(min(file))>  (single slot; comments stripped by minifier)
-- Stats (T2 baseline: x0.004/up20/st600/tech2 | Arm 620M/7700E/BT14900/HP2800, Cor/Leg 640M/8100E/BT14100/HP3900):
--   T3: x0.008 (8x, metal_extractor 8), upkeep 90, storage 1200, tech 3.
--       Arm 4500M/60kE/BT52000/HP7500; Cor/Leg 5200M/78kE/BT58000/HP9500.
--   T4: x0.016 (16x, metal_extractor 16), upkeep 240, storage 2000, tech 4, non-explosive.
--       Arm 16000M/270kE/BT180000/HP17000; Cor/Leg 18500M/320kE/BT200000/HP20000.
-- Balance v2: outputs fixed, costs ~1.6x vs v1 — cost per metal rises per tier (T2<T3<T4).
-- Balance: monotonic T2<T3<T4; Armada slightly cheaper/fragiler, Cor/Leg tougher (mirrors T2).
-- Builders: T3 appended to same-faction T2 constructors only (ack/acv/aca of its faction;
--   supports water, which it does not, so subs are skipped at runtime). T4 ideally belongs to
--   T3 constructors, but no baseline T3 builder keys exist, so T4 falls back to the same T2
--   constructors (see T4FALLBACK below); move T4 entries to real T3 builders when known.
--   Every builder key is nil-guarded; unknown/missing siblings are skipped silently.
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
local SUB = { armack = "armacsub", corack = "coracsub", legack = "legacsub" }
local SPECS = {
  { dst = "armmoho_t3", src = "armmoho", tech = 3, x = 0.008, mx = 8, up = 90, sto = 1200,
    nm = "Armada T3 Metal Extractor", tip = "Produces 8 metal, upkeep 60E, storage 1200.",
    m = 4500, e = 60000, bt = 52000, hp = 7500 },
  { dst = "cormoho_t3", src = "cormoho", tech = 3, x = 0.008, mx = 8, up = 90, sto = 1200,
    nm = "Cortex T3 Metal Extractor", tip = "Produces 8 metal, upkeep 60E, storage 1200.",
    m = 5200, e = 78000, bt = 58000, hp = 9500 },
  { dst = "legmoho_t3", src = "legmoho", tech = 3, x = 0.008, mx = 8, up = 90, sto = 1200,
    nm = "Legion T3 Metal Extractor", tip = "Produces 8 metal, upkeep 60E, storage 1200.",
    m = 5200, e = 78000, bt = 58000, hp = 9500 },
  { dst = "armmoho_t4", src = "armmoho", tech = 4, x = 0.016, mx = 16, up = 240, sto = 2000,
    nm = "Armada T4 Metal Extractor", tip = "Produces 16 metal, upkeep 150E, storage 2000. Non-explosive.",
    m = 16000, e = 270000, bt = 180000, hp = 17000 },
  { dst = "cormoho_t4", src = "cormoho", tech = 4, x = 0.016, mx = 16, up = 240, sto = 2000,
    nm = "Cortex T4 Metal Extractor", tip = "Produces 16 metal, upkeep 150E, storage 2000. Non-explosive.",
    m = 18500, e = 320000, bt = 200000, hp = 20000 },
  { dst = "legmoho_t4", src = "legmoho", tech = 4, x = 0.016, mx = 16, up = 240, sto = 2000,
    nm = "Legion T4 Metal Extractor", tip = "Produces 16 metal, upkeep 150E, storage 2000. Non-explosive.",
    m = 18500, e = 320000, bt = 200000, hp = 20000 },
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
    u.explodeas = ""
    u.selfdestructas = ""
    u.buildoptions = u.buildoptions or {}
    u.weapondefs = u.weapondefs or {}
    u.weapons = u.weapons or {}
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
