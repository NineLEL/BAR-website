-- RaptorX custom mobile units. These clones are not exposed to player builders.
do
  local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do result[copy(key)] = copy(child) end
    return result
  end
  local function name(unit, humanName, tooltip)
    unit.customparams = unit.customparams or {}
    for _, language in ipairs({ "en", "de", "fr", "es", "it", "ru", "zh", "cs", "hr", "lt" }) do
      unit.customparams["i18n_" .. language .. "_humanname"] = humanName
      unit.customparams["i18n_" .. language .. "_tooltip"] = tooltip
    end
  end
  local function clean(unit)
    unit.maxthisunit = nil
    unit.buildoptions = {}
    if unit.customparams then
      unit.customparams.raptorbuildmeta = nil
      unit.customparams.raptorbuild = nil
    end
  end
  local function tuneWeapons(unit, damageMultiplier, reloadMultiplier)
    if type(unit.weapondefs) ~= "table" then return end
    for _, weapon in pairs(unit.weapondefs) do
      if type(weapon) == "table" then
        if type(weapon.damage) == "table" then
          for target, damage in pairs(weapon.damage) do
            if type(damage) == "number" then weapon.damage[target] = damage * damageMultiplier end
          end
        end
        if type(weapon.reloadtime) == "number" then weapon.reloadtime = weapon.reloadtime * reloadMultiplier end
      end
    end
  end
  local specs = {
    { src = "raptor_land_assault_basic_t2_v3", dst = "raptorx_ironfang", nm = "Ironfang", tip = "Hard-hitting early assault Raptor with reinforced armor.", hp = 1.32, speed = 0.94, damage = 1.18, reload = 0.92 },
    { src = "raptor_allterrain_swarmer_basic_t2_v1", dst = "raptorx_dreadrunner", nm = "Dreadrunner", tip = "Fast early all-terrain pressure unit built for repeated attacks.", hp = 1.22, speed = 1.06, damage = 1.12, reload = 0.90 },
    { src = "raptor_land_swarmer_fire_t2_v1", dst = "raptorx_burnmaw", nm = "Burnmaw", tip = "Early fire assault Raptor that punishes clustered defenses.", hp = 1.28, speed = 0.98, damage = 1.20, reload = 0.88 },
    { src = "raptor_land_assault_basic_t2_v2", dst = "raptorx_razorclaw", nm = "Razorclaw", tip = "Reliable mid-tier assault Raptor bred for repeated waves.", hp = 1.18, speed = 0.98, damage = 1.08, reload = 0.96 },
    { src = "raptor_allterrain_assault_basic_t2_v2", dst = "raptorx_stormmaw", nm = "Stormmaw", tip = "Fast all-terrain elite for sustained pressure and flanking.", hp = 1.28, speed = 0.96, damage = 1.12, reload = 0.94 },
    { src = "raptor_land_assault_basic_t2_v1", dst = "raptorx_bonecrusher", nm = "Bonecrusher", tip = "Heavy Raptor assault beast with reinforced plating.", hp = 1.35, speed = 0.90, damage = 1.15, reload = 0.92 },
    { src = "raptor_land_assault_basic_t4_v2", dst = "raptorx_broodlord", nm = "Broodlord", tip = "Powerful but fieldable T4 assault leader below Matriarch class.", hp = 1.24, speed = 0.88, damage = 1.16, reload = 0.93 },
    { src = "raptor_allterrain_arty_acid_t4_v1", dst = "raptorx_acidstorm", nm = "Acidstorm", tip = "Late-game all-terrain acid artillery Raptor.", hp = 1.20, speed = 0.82, damage = 1.18, reload = 0.90 },
    { src = "raptor_air_bomber_basic_t2_v1", dst = "raptorx_skyscourge", nm = "Skyscourge", tip = "Armored precision bomber with a heavier strike payload.", hp = 1.25, speed = 0.92, damage = 1.20, reload = 0.94 },
    { src = "raptor_land_swarmer_heal_t3_v1", dst = "raptorx_nestguardian", nm = "Nest Guardian", tip = "Durable mobile healer that follows assault waves.", hp = 1.50, speed = 0.88, damage = 0.80, reload = 1.05 },
    { src = "raptor_matriarch_basic", dst = "raptorx_matriarch_prime", nm = "Matriarch Prime", tip = "Extremely rare late-game Raptor command beast.", hp = 1.30, speed = 0.86, damage = 1.25, reload = 0.90 },
    { src = "raptor_matriarch_electric", dst = "raptorx_overmatriarch", nm = "Overmatriarch", tip = "Elite Raptor commander stronger than a Matriarch, but fieldable in mid-game waves.", hp = 1.90, speed = 0.84, damage = 1.65, reload = 0.72 },
    { src = "raptor_queen_normal", dst = "raptorx_elderqueen", nm = "Elder Queen", tip = "Late-game Raptor super-elite. Stronger than the Overmatriarch, but not a boss event.", hp = 2.35, speed = 0.80, damage = 1.95, reload = 0.66 },
    { src = "raptor_allterrain_assault_basic_t4_v2", dst = "raptorx_apex_colossus", nm = "Apex Colossus", tip = "Overwhelming apex assault Raptor. Spawned alone as a rare boss.", hp = 3.20, speed = 0.78, damage = 2.10, reload = 0.62 },
    { src = "raptor_matriarch_spectre", dst = "raptorx_spectre_overlord", nm = "Spectre Overlord", tip = "Invisible apex command beast with devastating weapons.", hp = 2.80, speed = 0.82, damage = 2.35, reload = 0.58 },
    { src = "raptor_queen_veryhard", dst = "raptorx_queen_ascendant", nm = "Queen Ascendant", tip = "The ultimate Raptor boss. Spawned as a single rare event.", hp = 3.80, speed = 0.72, damage = 2.60, reload = 0.52 },
  }
  for _, spec in ipairs(specs) do
    local source = UnitDefs[spec.src]
    if source and not UnitDefs[spec.dst] then
      local unit = copy(source)
      unit.unitname, unit.name = spec.dst, spec.nm
      unit.health = (unit.health or 1) * spec.hp
      unit.speed = (unit.speed or 1) * spec.speed
      clean(unit)
      tuneWeapons(unit, spec.damage, spec.reload)
      name(unit, spec.nm, spec.tip)
      unit.customparams = unit.customparams or {}
      unit.customparams.raptorxcustom = "1"
      UnitDefs[spec.dst] = unit
      if UnitDefNames then UnitDefNames[spec.dst] = unit end
    end
  end
end
