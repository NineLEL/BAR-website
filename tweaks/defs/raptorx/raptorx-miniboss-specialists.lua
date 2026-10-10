-- Standalone mini-boss squads; no core pack or tweakunits dependency.
-- Native miniqueen script supports slots 1 (claws), 2-4 (spikes), 5 (breath).
-- Skills use engine fields and BAR's unit_area_timed_damage gadget, not fake AI keys.
do
  local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do result[key] = copy(child) end
    return result
  end
  local specs = {
    {"raptor_matriarch_basic", "raptorx_miniboss_ironhide", "Ironhide Juggernaut", 35, "berserk", 180000, 52, "Knockback claws and shockwave volleys; regenerates 900 HP/s. Focus fire to overcome regeneration."},
    {"raptor_matriarch_acid", "raptorx_miniboss_miremaw", "Miremaw Plague Matriarch", 45, "artillery", 200000, 48, "Five-shot acid siege leaves 18-second pools. Keep moving and use shields to contain the corrosion."},
    {"raptor_matriarch_electric", "raptorx_miniboss_stormlock", "Stormlock Tyrant", 55, "berserk", 240000, 56, "Short lightning bursts and an EMP bombardment disable clustered armies. Spread out and attack between volleys."},
    {"raptor_matriarch_fire", "raptorx_miniboss_cindermaw", "Cindermaw Incinerator", 65, "berserk", 280000, 60, "Flame volleys leave 8-second burning ground. Kite beyond its breath range; aircraft avoid the ground fire."},
    {"raptor_matriarch_spectre", "raptorx_miniboss_veilfang", "Veilfang Stalker", 75, "raider", 160000, 95, "Cloaked, radar-stealth ambusher with a heavy claw strike. Proximity reveals it; firing breaks cloak before it can recloak."},
  }
  local function tune(weapon, name, range, reload, burst, rate, damage, aoe)
    weapon.name, weapon.range, weapon.reloadtime = name, range, reload
    weapon.burst, weapon.burstrate, weapon.areaofeffect = burst, rate, aoe
    weapon.damage = { default = damage, shields = damage * 2 }
    weapon.energypershot, weapon.metalpershot = 0, 0
    weapon.avoidfriendly, weapon.collidefriendly, weapon.noselfdamage = true, false, true
  end
  local function area(weapon, kind, duration, damage, radius)
    weapon.customparams = weapon.customparams or {}
    local cp = weapon.customparams
    cp.area_onhit_ceg = kind .. "-area-" .. radius .. "-repeat"
    cp.area_onhit_damageceg = kind == "acid" and "acid-damage-gen" or "burnthermite"
    cp.area_onhit_time, cp.area_onhit_damage, cp.area_onhit_range = duration, damage, radius
    cp.area_onhit_resistance = kind == "acid" and "_RAPTORACID_" or "_RAPTORFIRE_"
  end
  for _, spec in ipairs(specs) do
    local source = UnitDefs[spec[1]]
    local required = spec[1] == "raptor_matriarch_fire" and {"flamethrowerspike", "flamethrowermain"}
      or spec[1] == "raptor_matriarch_acid" and {"melee", "acidgoo", "spike_acid_blob"}
      or spec[1] == "raptor_matriarch_electric" and {"melee", "goo"}
      or {"melee", "goo", "yellow_missile"}
    local compatible = source and type(source.weapondefs) == "table" and type(source.weapons) == "table"
    if compatible then
      for _, key in ipairs(required) do
        if type(source.weapondefs[key]) ~= "table" then compatible = false end
      end
      for slot = 1, 5 do
        if type(source.weapons[slot]) ~= "table" then compatible = false end
      end
    end
    -- Skip absent/incompatible bases rather than register an unarmed boss.
    if compatible and not UnitDefs[spec[2]] then
      local unit = copy(source)
      unit.unitname, unit.name, unit.description = spec[2], spec[3], spec[8]
      unit.health, unit.maxdamage, unit.speed = spec[6], spec[6], spec[7]
      unit.builder, unit.buildoptions, unit.maxthisunit = false, {}, nil
      unit.canrepair, unit.canreclaim, unit.workertime = false, false, 0
      unit.autoheal, unit.idleautoheal, unit.sightdistance = 5, 0, 1800
      local cp = unit.customparams or {}
      unit.customparams = cp
      cp.raptorx_miniboss, cp.israptor = 1, true
      -- Do not inherit hardening guards, EMP immunity or a base's forced squad pool.
      cp.raptorx_ultra_hardened, cp.raptorx_squadweight_adjusted = nil, nil
      cp.paralyzemultiplier = 1
      cp.raptorcustomsquad, cp.raptorsquadrarity = "1", "special"
      cp.raptorsquadunitsamount, cp.raptorsquadweight = 1, 2
      cp.raptorsquadminanger, cp.raptorsquadmaxanger = spec[4], 150
      cp.raptorsquadbehavior, cp.raptorsquadbehaviorchance = spec[5], 1
      cp.raptorsquadbehaviordistance = spec[5] == "artillery" and 1100 or 700
      cp.raptorsquadforceair, cp.raptorsquadforcesurface = nil, nil
      for _, lang in ipairs({"en", "de", "fr", "es", "it", "ru", "zh", "cs", "hr", "lt"}) do
        cp["i18n_" .. lang .. "_humanname"] = unit.name
        cp["i18n_" .. lang .. "_tooltip"] = unit.description
      end
      local weapons = unit.weapondefs
      unit.weapons[1].onlytargetcategory, unit.weapons[5].onlytargetcategory = "NOTAIR", "NOTAIR"
      if spec[1] == "raptor_matriarch_basic" then
        tune(weapons.melee, "Ironhide Repulsor Claws", 400, 2.4, 1, 0, 2400, 160)
        weapons.melee.impulsefactor = 4
        tune(weapons.goo, "Seismic Shockwave Volley", 1200, 12, 3, 0.4, 1200, 260)
        weapons.goo.impulsefactor, weapons.goo.weaponvelocity = 3, 600
        unit.autoheal = 900
        tune(weapons.yellow_missile, "Ironhide Air Spores", 900, 6, 1, 0, 1, 128)
        weapons.yellow_missile.damage.vtol = 1200
      elseif spec[1] == "raptor_matriarch_acid" then
        tune(weapons.melee, "Miremaw Claws", 400, 2, 1, 0, 1400, 60)
        tune(weapons.acidgoo, "Plague Pool Bombardment", 1800, 16, 5, 0.3, 300, 180)
        weapons.acidgoo.weaponvelocity, weapons.acidgoo.sprayangle = 750, 900
        weapons.acidgoo.damage.shields = 9000
        area(weapons.acidgoo, "acid", 18, 220, 150)
        tune(weapons.spike_acid_blob, "Corrosive Defensive Spikes", 750, 9, 1, 0, 100, 100)
        weapons.spike_acid_blob.damage.shields = 3000
        area(weapons.spike_acid_blob, "acid", 6, 80, 75)
        cp.areadamageresistance = "LuaAreaDamage__RAPTORACID_"
      elseif spec[1] == "raptor_matriarch_electric" then
        tune(weapons.melee, "Stormlock Lightning Burst", 500, 8, 6, 0.12, 700, 50)
        weapons.melee.paralyzer, weapons.melee.paralyzetime = true, 5
        tune(weapons.goo, "Lockdown EMP Volley", 1400, 20, 3, 0.5, 6000, 280)
        weapons.goo.paralyzer, weapons.goo.paralyzetime = true, 8
        weapons.goo.weaponvelocity, weapons.goo.sprayangle = 650, 600
        unit.explodeas, unit.selfdestructas = "raptor_empdeath_big", "raptor_empdeath_big"
      elseif spec[1] == "raptor_matriarch_fire" then
        tune(weapons.flamethrowerspike, "Cindermaw Flame Jets", 350, 3, 8, 0.1, 90, 64)
        tune(weapons.flamethrowermain, "Scorched Earth Breath", 700, 9, 10, 0.12, 160, 100)
        weapons.flamethrowermain.weaponvelocity = 500
        area(weapons.flamethrowermain, "fire", 8, 140, 100)
        cp.areadamageresistance = "LuaAreaDamage__RAPTORFIRE_"
        for _, slot in ipairs(unit.weapons) do slot.onlytargetcategory = "NOTAIR" end
      else
        tune(weapons.melee, "Veilfang Ambush Claws", 350, 5, 1, 0, 8000, 60)
        tune(weapons.goo, "Veilfang Precision Spit", 1000, 14, 1, 0, 2200, 80)
        weapons.goo.sprayangle, weapons.goo.weaponvelocity = 0, 650
        tune(weapons.yellow_missile, "Veilfang Air Spores", 900, 8, 1, 0, 1, 128)
        weapons.yellow_missile.damage.vtol = 1800
        unit.cancloak, unit.initcloak, unit.stealth = true, true, true
        unit.cloakcost, unit.cloakcostmoving, unit.mincloakdistance = 0, 0, 250
        unit.decloakonfire, unit.cloaktimeout = true, 180
      end
      UnitDefs[spec[2]] = unit
    end
  end
end
