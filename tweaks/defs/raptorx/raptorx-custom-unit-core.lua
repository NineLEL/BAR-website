-- RaptorX registration precedes siege and hardening packs alphabetically.
-- BAR applies tweakunits BEFORE these clones exist: register their squads here.
do
  local function copy(v)
    if type(v) ~= "table" then return v end
    local out = {}
    for k, child in pairs(v) do out[copy(k)] = copy(child) end
    return out
  end
  local specs = {
    {"raptor_land_assault_basic_t2_v1","raptorx_earlycrusher","Earlycrusher",1.10,.92,.75,1.02},
    {"raptor_allterrain_assault_basic_t2_v3","raptorx_midravager","Midravager",1.25,.92,.82,.96},
    {"raptor_land_assault_basic_t4_v1","raptorx_latebehemoth","Late Behemoth",1.40,.84,.86,.94},
    {"raptor_air_fighter_basic_t1_v1","raptorx_earlytalon","Early Talon",1.10,.98,.75,1.02},
    {"raptor_air_gunship_basic_t2_v1","raptorx_midfirewing","Mid Firewing",1.25,.96,.82,.96},
    {"raptor_air_bomber_basic_t4_v1","raptorx_lateskyreaper","Late Skyreaper",1.38,.90,.85,.94},
    {"raptor_land_assault_basic_t2_v3","raptorx_ironfang","Ironfang",1.10,.92,.75,1.02},
    {"raptor_allterrain_swarmer_basic_t2_v1","raptorx_dreadrunner","Dreadrunner",1.08,.96,.75,1.02},
    {"raptor_land_swarmer_fire_t2_v1","raptorx_burnmaw","Burnmaw",1.10,.95,.76,1.00},
    {"raptor_land_assault_basic_t2_v2","raptorx_razorclaw","Razorclaw",1.08,.95,.76,1.00},
    {"raptor_allterrain_assault_basic_t2_v2","raptorx_stormmaw","Stormmaw",1.12,.94,.78,.99},
    {"raptor_land_assault_basic_t2_v1","raptorx_bonecrusher","Bonecrusher",1.15,.90,.80,.98},
    {"raptor_land_assault_basic_t4_v2","raptorx_broodlord","Broodlord",1.12,.88,.80,.98},
    {"raptor_allterrain_arty_acid_t4_v1","raptorx_acidstorm","Acidstorm",1.10,.82,.80,.98},
    {"raptor_air_bomber_basic_t2_v1","raptorx_skyscourge","Skyscourge",1.12,.90,.80,.98},
    {"raptor_land_swarmer_heal_t3_v1","raptorx_nestguardian","Nest Guardian",1.20,.88,.60,1.05},
    {"raptor_matriarch_basic","raptorx_matriarch_prime","Matriarch Prime",1.12,.86,.82,.98},
    {"raptor_matriarch_electric","raptorx_overmatriarch","Overmatriarch",1.30,.84,.85,.96},
    {"raptor_queen_normal","raptorx_elderqueen","Elder Queen",1.45,.80,.88,.94},
    {"raptor_allterrain_assault_basic_t4_v2","raptorx_apex_colossus","Apex Colossus",1.65,.78,.90,.92},
    {"raptor_matriarch_spectre","raptorx_spectre_overlord","Spectre Overlord",1.50,.82,.90,.92},
    {"raptor_queen_veryhard","raptorx_queen_ascendant","Queen Ascendant",1.75,.72,.92,.90},
    {"raptor_allterrain_arty_basic_t2_v1","raptorx_siegehowler","Siege Howler",1.20,.78,.80,.98},
    {"raptor_land_spiker_basic_t2_v1","raptorx_clusterrain","Cluster Rain",1.15,.82,.80,.98},
    {"raptor_allterrain_arty_emp_t2_v1","raptorx_disruptionmortar","Disruption Mortar",1.18,.80,.80,.98},
  }
  -- behavior, min/max anger, amount, weight, distance, rarity. Kept in sync
  -- with units/raptorx rosters so each clone gets its OWN squad, not its base's.
  local squads = {
    raptorx_earlycrusher = {"berserk",22,75,3,28,1150,"basic"},
    raptorx_midravager = {"berserk",42,150,6,100,1600,"special"},
    raptorx_latebehemoth = {"berserk",55,150,5,95,2100,"special"},
    raptorx_earlytalon = {"raider",20,85,4,30,1500,"basic"},
    raptorx_midfirewing = {"raider",42,150,5,95,1900,"special"},
    raptorx_lateskyreaper = {"raider",55,150,3,85,2300,"special"},
    raptorx_ironfang = {"berserk",28,85,4,30,1050,"basic"},
    raptorx_dreadrunner = {"raider",25,95,5,32,1200,"basic"},
    raptorx_burnmaw = {"berserk",35,105,12,100,1100,"basic"},
    raptorx_razorclaw = {"raider",35,150,12,95,1250,"basic"},
    raptorx_stormmaw = {"raider",50,150,7,90,1500,"special"},
    raptorx_bonecrusher = {"berserk",55,150,6,70,1800,"special"},
    raptorx_broodlord = {"berserk",65,150,4,75,1900,"special"},
    raptorx_acidstorm = {"artillery",60,150,2,50,2300,"special"},
    raptorx_skyscourge = {"raider",55,150,3,55,2000,"special"},
    raptorx_nestguardian = {"healer",55,150,2,60,1400,"special"},
    raptorx_matriarch_prime = {"berserk",75,150,1,25,2400,"special"},
    raptorx_overmatriarch = {"berserk",75,150,2,40,2300,"special"},
    raptorx_elderqueen = {"berserk",85,150,1,25,2700,"special"},
    raptorx_apex_colossus = {"berserk",90,150,1,16,2800,"special"},
    raptorx_spectre_overlord = {"raider",100,150,1,12,3000,"special"},
    raptorx_queen_ascendant = {"berserk",100,150,1,8,3200,"special"},
    raptorx_siegehowler = {"artillery",55,150,2,65,7800,"special"},
    raptorx_clusterrain = {"artillery",60,150,3,70,6400,"special"},
    raptorx_disruptionmortar = {"artillery",65,150,2,60,5400,"special"},
  }
  local languages = { "en", "de", "fr", "es", "it", "ru", "zh", "cs", "hr", "lt" }
  for _, s in ipairs(specs) do
    local source = UnitDefs[s[1]]
    if source and not UnitDefs[s[2]] then
      local unit = copy(source)
      unit.unitname, unit.name = s[2], s[3]
      unit.description = "???"
      local hp = tonumber(unit.health) or tonumber(unit.maxdamage) or 1
      unit.health, unit.maxdamage = hp * s[4], hp * s[4]
      unit.speed = (unit.speed or 1) * s[5]
      unit.buildoptions = {}
      unit.weapondefs = unit.weapondefs or {}
      unit.weapons = unit.weapons or {}
      for _, w in pairs(unit.weapondefs) do
        for armor, damage in pairs(w.damage or {}) do
          if type(damage) == "number" then w.damage[armor] = damage * s[6] end
        end
        if type(w.reloadtime) == "number" and w.reloadtime > 0 then
          local volley = math.max(0, ((tonumber(w.burst) or 1) - 1) * (tonumber(w.burstrate) or 0))
          w.reloadtime = math.max(w.reloadtime * s[7], volley + 0.05)
        end
      end
      local q = squads[s[2]]
      unit.customparams = unit.customparams or {}
      local cp = unit.customparams
      for _, lang in ipairs(languages) do
        cp["i18n_" .. lang .. "_humanname"] = s[3]
        cp["i18n_" .. lang .. "_tooltip"] = unit.description
      end
      cp.raptorcustomsquad, cp.raptorsquadbehaviorchance = "1", 1
      cp.raptorsquadbehavior, cp.raptorsquadminanger, cp.raptorsquadmaxanger = q[1], q[2], q[3]
      cp.raptorsquadunitsamount, cp.raptorsquadweight = q[4], q[5]
      cp.raptorsquadbehaviordistance, cp.raptorsquadrarity = q[6], q[7]
      UnitDefs[s[2]] = unit
    end
  end
end
