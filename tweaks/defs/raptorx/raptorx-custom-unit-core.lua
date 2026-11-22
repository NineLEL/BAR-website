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
    {"raptor_land_assault_basic_t2_v1","raptorx_earlycrusher","Earlycrusher",1.25,.95,1.05,.96},
    {"raptor_allterrain_assault_basic_t2_v3","raptorx_midravager","Midravager",1.45,.94,1.15,.92},
    {"raptor_land_assault_basic_t4_v1","raptorx_latebehemoth","Late Behemoth",1.65,.84,1.20,.90},
    {"raptor_air_fighter_basic_t1_v1","raptorx_earlytalon","Early Talon",1.20,1.06,1.04,.95},
    {"raptor_air_gunship_basic_t2_v1","raptorx_midfirewing","Mid Firewing",1.45,1.00,1.12,.92},
    {"raptor_air_bomber_basic_t4_v1","raptorx_lateskyreaper","Late Skyreaper",1.60,.92,1.18,.88},
    {"raptor_land_assault_basic_t2_v3","raptorx_ironfang","Ironfang",1.22,.94,1.05,.97},
    {"raptor_allterrain_swarmer_basic_t2_v1","raptorx_dreadrunner","Dreadrunner",1.16,1.04,1.04,.96},
    {"raptor_land_swarmer_fire_t2_v1","raptorx_burnmaw","Burnmaw",1.20,.98,1.05,.95},
    {"raptor_land_assault_basic_t2_v2","raptorx_razorclaw","Razorclaw",1.14,.98,1.03,.98},
    {"raptor_allterrain_assault_basic_t2_v2","raptorx_stormmaw","Stormmaw",1.20,.96,1.04,.97},
    {"raptor_land_assault_basic_t2_v1","raptorx_bonecrusher","Bonecrusher",1.25,.90,1.05,.96},
    {"raptor_land_assault_basic_t4_v2","raptorx_broodlord","Broodlord",1.18,.88,1.05,.96},
    {"raptor_allterrain_arty_acid_t4_v1","raptorx_acidstorm","Acidstorm",1.15,.82,1.06,.95},
    {"raptor_air_bomber_basic_t2_v1","raptorx_skyscourge","Skyscourge",1.18,.92,1.06,.96},
    {"raptor_land_swarmer_heal_t3_v1","raptorx_nestguardian","Nest Guardian",1.35,.88,.75,1.05},
    {"raptor_matriarch_basic","raptorx_matriarch_prime","Matriarch Prime",1.20,.86,1.08,.95},
    {"raptor_matriarch_electric","raptorx_overmatriarch","Overmatriarch",1.50,.84,1.15,.92},
    {"raptor_queen_normal","raptorx_elderqueen","Elder Queen",1.70,.80,1.20,.90},
    {"raptor_allterrain_assault_basic_t4_v2","raptorx_apex_colossus","Apex Colossus",2.10,.78,1.22,.88},
    {"raptor_matriarch_spectre","raptorx_spectre_overlord","Spectre Overlord",1.90,.82,1.22,.88},
    {"raptor_queen_veryhard","raptorx_queen_ascendant","Queen Ascendant",2.30,.72,1.25,.86},
    {"raptor_allterrain_arty_basic_t2_v1","raptorx_siegehowler","Siege Howler",1.35,.78,1.05,.96},
    {"raptor_land_spiker_basic_t2_v1","raptorx_clusterrain","Cluster Rain",1.25,.82,1.04,.96},
    {"raptor_allterrain_arty_emp_t2_v1","raptorx_disruptionmortar","Disruption Mortar",1.30,.80,1.05,.96},
  }
  -- behavior, min/max anger, amount, weight, distance, rarity. Kept in sync
  -- with units/raptorx rosters so each clone gets its OWN squad, not its base's.
  local squads = {
    raptorx_earlycrusher = {"berserk",10,75,6,45,1150,"basic"},
    raptorx_midravager = {"berserk",30,150,12,150,1600,"special"},
    raptorx_latebehemoth = {"berserk",40,150,8,130,2100,"special"},
    raptorx_earlytalon = {"raider",10,85,6,45,1500,"basic"},
    raptorx_midfirewing = {"raider",30,150,10,140,1900,"special"},
    raptorx_lateskyreaper = {"raider",40,150,5,115,2300,"special"},
    raptorx_ironfang = {"berserk",20,85,6,45,1050,"basic"},
    raptorx_dreadrunner = {"raider",20,95,7,48,1200,"basic"},
    raptorx_burnmaw = {"berserk",30,105,24,160,1100,"basic"},
    raptorx_razorclaw = {"raider",30,150,24,145,1250,"basic"},
    raptorx_stormmaw = {"raider",40,150,12,130,1500,"special"},
    raptorx_bonecrusher = {"berserk",50,150,10,85,1800,"special"},
    raptorx_broodlord = {"berserk",60,150,6,95,1900,"special"},
    raptorx_acidstorm = {"artillery",50,150,3,60,2300,"special"},
    raptorx_skyscourge = {"raider",50,150,4,70,2000,"special"},
    raptorx_nestguardian = {"healer",50,150,3,75,1400,"special"},
    raptorx_matriarch_prime = {"berserk",70,150,1,30,2400,"special"},
    raptorx_overmatriarch = {"berserk",70,150,3,55,2300,"special"},
    raptorx_elderqueen = {"berserk",80,150,2,35,2700,"special"},
    raptorx_apex_colossus = {"berserk",90,150,1,20,2800,"special"},
    raptorx_spectre_overlord = {"raider",100,150,1,15,3000,"special"},
    raptorx_queen_ascendant = {"berserk",100,150,1,10,3200,"special"},
    raptorx_siegehowler = {"artillery",40,150,4,95,9200,"special"},
    raptorx_clusterrain = {"artillery",50,150,5,100,7600,"special"},
    raptorx_disruptionmortar = {"artillery",60,150,3,80,6000,"special"},
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
