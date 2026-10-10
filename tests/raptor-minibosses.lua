-- Representative native miniqueen shapes, not a Spring simulation.
local pack = arg[1] or "tweaks/defs/raptorx/raptorx-miniboss-specialists.lua"
local function copy(v)
  if type(v) ~= "table" then return v end
  local out = {}
  for k, child in pairs(v) do out[k] = copy(child) end
  return out
end
local function equal(a, b)
  if type(a) ~= type(b) then return false end
  if type(a) ~= "table" then return a == b end
  for k, v in pairs(a) do if not equal(v, b[k]) then return false end end
  for k in pairs(b) do if a[k] == nil then return false end end
  return true
end
local kinds = {"basic", "acid", "electric", "fire", "spectre"}
local ids = {"ironhide", "miremaw", "stormlock", "cindermaw", "veilfang"}
local function fixture(kind)
  local function weapon()
    return { range = 400, reloadtime = 10, burst = 3, burstrate = 0.03333,
      damage = {default = 500}, customparams = {}, explosiongenerator = "custom:burnthermite" }
  end
  local defs, slots = {}, {}
  local names = kind == "fire" and {"flamethrowerspike", "flamethrowerspike", "flamethrowerspike", "flamethrowerspike", "flamethrowermain"}
    or kind == "acid" and {"melee", "spike_acid_blob", "spike_acid_blob", "spike_acid_blob", "acidgoo"}
    or kind == "electric" and {"melee", "melee", "melee", "melee", "goo"}
    or {"melee", "yellow_missile", "yellow_missile", "yellow_missile", "goo"}
  for slot, name in ipairs(names) do
    defs[name] = weapon()
    slots[slot] = {def = name, onlytargetcategory = (slot > 1 and slot < 5) and ((kind == "basic" or kind == "spectre") and "VTOL" or "NOTAIR") or nil}
  end
  return {health = 60000, speed = 67.5, builder = false,
    script = "Raptors/raptor_miniqueen.cob", objectname = "Raptors/raptor_miniqueen_" .. kind .. ".s3o",
    customparams = {israptor = true, paralyzemultiplier = kind == "electric" and 0 or 1},
    weapons = slots, weapondefs = defs}
end
UnitDefs = {}
for _, kind in ipairs(kinds) do UnitDefs["raptor_matriarch_" .. kind] = fixture(kind) end
local originals = copy(UnitDefs)
assert(loadfile(pack))()
for i, kind in ipairs(kinds) do
  local base = UnitDefs["raptor_matriarch_" .. kind]
  local u = assert(UnitDefs["raptorx_miniboss_" .. ids[i]])
  assert(equal(base, originals["raptor_matriarch_" .. kind]), "base mutated")
  assert(u.script == base.script and u.objectname == base.objectname)
  assert(u.weapondefs ~= base.weapondefs and u.weapons ~= base.weapons)
  assert(not u.builder and next(u.buildoptions) == nil)
  assert(u.customparams.raptorcustomsquad == "1" and u.customparams.raptorsquadunitsamount == 1)
  assert(u.customparams.raptorsquadminanger == 25 + i * 10 and u.customparams.raptorsquadweight == 2)
  assert(u.customparams.paralyzemultiplier == 1)
  assert(#u.weapons == 5)
  for _, slot in ipairs(u.weapons) do
    local w = assert(u.weapondefs[string.lower(slot.def)])
    assert(w.reloadtime >= ((w.burst or 1) - 1) * (w.burstrate or 0) + 0.05)
    assert(w.energypershot == 0 and w.metalpershot == 0)
  end
  assert(u.weapons[1].onlytargetcategory == "NOTAIR" and u.weapons[5].onlytargetcategory == "NOTAIR")
end
local iron = UnitDefs.raptorx_miniboss_ironhide
assert(iron.autoheal == 900 and iron.weapondefs.melee.impulsefactor == 4)
local acid = UnitDefs.raptorx_miniboss_miremaw.weapondefs.acidgoo.customparams
assert(acid.area_onhit_time == 18 and acid.area_onhit_range == 150 and acid.area_onhit_ceg == "acid-area-150-repeat")
local storm = UnitDefs.raptorx_miniboss_stormlock.weapondefs.goo
assert(storm.paralyzer and storm.paralyzetime == 8 and storm.reloadtime == 20)
local fire = UnitDefs.raptorx_miniboss_cindermaw
assert(fire.weapondefs.flamethrowermain.customparams.area_onhit_damageceg == "burnthermite")
for _, slot in ipairs(fire.weapons) do assert(slot.onlytargetcategory == "NOTAIR") end
local veil = UnitDefs.raptorx_miniboss_veilfang
assert(veil.cancloak and veil.initcloak and veil.stealth and veil.decloakonfire and veil.cloaktimeout == 180)
local before = copy(UnitDefs)
assert(loadfile(pack))()
assert(equal(before, UnitDefs), "repeat application changed definitions")
assert(loadfile("tweaks/defs/raptorx/raptorx-unit-hardening.lua"))()
for _, id in ipairs(ids) do
  local name = "raptorx_miniboss_" .. id
  assert(equal(before[name], UnitDefs[name]), "hardening changed specialist tuning")
end
-- Hardening before registration also must not taint base definitions or boss tuning.
UnitDefs = copy(originals)
assert(loadfile("tweaks/defs/raptorx/raptorx-unit-hardening.lua"))()
local hardened = copy(UnitDefs)
assert(loadfile(pack))()
for _, kind in ipairs(kinds) do assert(equal(hardened["raptor_matriarch_" .. kind], UnitDefs["raptor_matriarch_" .. kind])) end
for _, id in ipairs(ids) do
  local name = "raptorx_miniboss_" .. id
  assert(equal(before[name], UnitDefs[name]), "load order changed boss tuning")
end
UnitDefs = {}
assert(loadfile(pack))()
assert(next(UnitDefs) == nil, "missing bases were registered")
UnitDefs = {raptor_matriarch_basic = fixture("basic")}
UnitDefs.raptor_matriarch_basic.weapondefs.goo = nil
assert(loadfile(pack))()
assert(UnitDefs.raptorx_miniboss_ironhide == nil, "incompatible base was registered")
UnitDefs = {raptor_matriarch_basic = fixture("basic"), raptorx_miniboss_ironhide = {sentinel = true}}
assert(loadfile(pack))()
assert(UnitDefs.raptorx_miniboss_ironhide.sentinel, "existing definition overwritten")
print("mini-boss runtime checks passed")
