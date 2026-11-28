-- Representative BAR definitions for the RaptorX combat and squad tuning.
local packDir = arg[1] or "tweaks/defs/raptorx"
local function fixture(health, canFly, minimumAnger, amount, weight)
  local params = {}
  if minimumAnger then
    params = {raptorcustomsquad = "1", raptorsquadminanger = minimumAnger,
      raptorsquadmaxanger = 150, raptorsquadunitsamount = tostring(amount), raptorsquadweight = tostring(weight)}
  end
  return {health = health, canfly = canFly, speed = 100, customparams = params,
    weapons = {{def = "WEAPON"}}, weapondefs = {weapon = {damage = {default = 100}, reloadtime = 5}}}
end

local function close(actual, expected)
  assert(math.abs(actual - expected) < 1e-6, ("expected %s, got %s"):format(expected, actual))
end

UnitDefs = {
  raptor_land_swarmer_basic_t1_v1 = fixture(167, false, 0, 5, 38),
  raptor_land_assault_basic_t2_v1 = fixture(5600, false, 32, 14, 90),
  raptor_air_bomber_basic_t2_v1 = fixture(1000, true, 42, 4, 70),
  raptor_allterrain_arty_basic_t4_v1 = fixture(8000, false, 50, 3, 65),
  raptor_air_bomber_basic_t4_v1 = fixture(1600, true),
  raptor_queen_epic = fixture(1875000, false, 90, 1, 10),
  raptor_allterrain_arty_basic_t2_v1 = fixture(2000, false),
  raptor_land_spiker_basic_t2_v1 = fixture(910, false),
  raptor_allterrain_arty_emp_t2_v1 = fixture(2000, false),
  raptor_allterrain_assault_basic_t4_v2 = fixture(12000, false),
  raptor_land_swarmer_heal_t3_v1 = {health = 750, speed = 150, builder = 1},
}

assert(loadfile(packDir .. "/raptorx-custom-unit-core.lua"))()
local earlyCustom = UnitDefs.raptorx_earlycrusher
assert(earlyCustom.customparams.raptorsquadweight == 56)
local guardian = UnitDefs.raptorx_nestguardian
assert(guardian.customparams.raptorsquadweight == 120 and guardian.customparams.raptorsquadunitsamount == 2)
assert(loadfile(packDir .. "/raptorx-siege-artillery.lua"))()
local harden = assert(loadfile(packDir .. "/raptorx-unit-hardening.lua"))
harden()

local early = UnitDefs.raptor_land_swarmer_basic_t1_v1
close(early.health, 167 * 1.40)
close(early.weapondefs.weapon.damage.default, 65)
close(early.weapondefs.weapon.reloadtime, 5.15)
assert(early.speed == 96 and early.autoheal == 0)
assert(early.customparams.raptorsquadunitsamount == 7 and early.customparams.raptorsquadweight == 38)
assert(earlyCustom.customparams.raptorsquadminanger == 24 and earlyCustom.customparams.raptorsquadweight == 50)
assert(guardian.customparams.raptorsquadweight == 120 and guardian.customparams.raptorsquadbehavior == "healer")

local mid = UnitDefs.raptor_land_assault_basic_t2_v1
close(mid.health, 5600 * 2.8)
close(mid.weapondefs.weapon.damage.default, 78)
assert(mid.customparams.raptorsquadunitsamount == 19 and mid.customparams.raptorsquadweight == 72)
local air = UnitDefs.raptor_air_bomber_basic_t2_v1
assert(air.health == 4800 and air.customparams.raptorsquadunitsamount == 5)
assert(UnitDefs.raptor_allterrain_arty_basic_t4_v1.health == 120000)
assert(UnitDefs.raptor_air_bomber_basic_t4_v1.health == 60000)
local queen = UnitDefs.raptor_queen_epic
assert(queen.health == 26250000 and queen.customparams.raptorsquadunitsamount == "1")
local apex = UnitDefs.raptorx_apex_colossus
close(apex.health, 5500000 * 1.06 * 1.07 ^ 9)
assert(apex.customparams.raptorsquadunitsamount == 1 and apex.customparams.raptorsquadminanger == 90)

local howler = UnitDefs.raptorx_siegehowler
local siege = howler.weapondefs.siege
assert(howler.weapons[1].def == "SIEGE" and siege.range == 7800)
close(siege.damage.default, 3600 * 0.94 * 0.95 * 1.02 ^ 5)
close(siege.reloadtime, 7.5 * 0.96)
assert(howler.customparams.raptorsquadunitsamount == 3 and howler.customparams.raptorsquadweight == 182)
local cluster = UnitDefs.raptorx_clusterrain.weapondefs.cluster
close(cluster.damage.default, 720 * 0.94 * 0.95 * 1.02 ^ 6)
close(cluster.reloadtime, 6.75 * 0.96)
assert(cluster.burst == 5 and cluster.reloadtime > (cluster.burst - 1) * cluster.burstrate)
local emp = UnitDefs.raptorx_disruptionmortar.weapondefs.empmortar
assert(emp.paralyzer and emp.paralyzetime == 6)

local health, damage = howler.health, siege.damage.default
harden()
assert(howler.health == health and siege.damage.default == damage)
assert(howler.customparams.raptorsquadunitsamount == 3 and howler.customparams.raptorsquadweight == 182)
print("RaptorX balance runtime checks passed")
