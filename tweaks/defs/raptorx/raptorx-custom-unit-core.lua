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
    {"raptor_land_assault_basic_t2_v1","raptorx_earlycrusher","Earlycrusher",1.55,.96,1.35,.82},
    {"raptor_allterrain_assault_basic_t2_v3","raptorx_midravager","Midravager",1.75,.94,1.55,.76},
    {"raptor_land_assault_basic_t4_v1","raptorx_latebehemoth","Late Behemoth",2.10,.84,1.80,.68},
    {"raptor_air_fighter_basic_t1_v1","raptorx_earlytalon","Early Talon",1.45,1.12,1.30,.78},
    {"raptor_air_gunship_basic_t2_v1","raptorx_midfirewing","Mid Firewing",1.70,1.02,1.50,.72},
    {"raptor_air_bomber_basic_t4_v1","raptorx_lateskyreaper","Late Skyreaper",2.00,.92,1.85,.64},
    {"raptor_land_assault_basic_t2_v3","raptorx_ironfang","Ironfang",1.32,.94,1.18,.92},
    {"raptor_allterrain_swarmer_basic_t2_v1","raptorx_dreadrunner","Dreadrunner",1.22,1.06,1.12,.90},
    {"raptor_land_swarmer_fire_t2_v1","raptorx_burnmaw","Burnmaw",1.28,.98,1.20,.88},
    {"raptor_land_assault_basic_t2_v2","raptorx_razorclaw","Razorclaw",1.18,.98,1.08,.96},
    {"raptor_allterrain_assault_basic_t2_v2","raptorx_stormmaw","Stormmaw",1.28,.96,1.12,.94},
    {"raptor_land_assault_basic_t2_v1","raptorx_bonecrusher","Bonecrusher",1.35,.90,1.15,.92},
    {"raptor_land_assault_basic_t4_v2","raptorx_broodlord","Broodlord",1.24,.88,1.16,.93},
    {"raptor_allterrain_arty_acid_t4_v1","raptorx_acidstorm","Acidstorm",1.20,.82,1.18,.90},
    {"raptor_air_bomber_basic_t2_v1","raptorx_skyscourge","Skyscourge",1.25,.92,1.20,.94},
    {"raptor_land_swarmer_heal_t3_v1","raptorx_nestguardian","Nest Guardian",1.50,.88,.80,1.05},
    {"raptor_matriarch_basic","raptorx_matriarch_prime","Matriarch Prime",1.30,.86,1.25,.90},
    {"raptor_matriarch_electric","raptorx_overmatriarch","Overmatriarch",1.90,.84,1.65,.72},
    {"raptor_queen_normal","raptorx_elderqueen","Elder Queen",2.35,.80,1.95,.66},
    {"raptor_allterrain_assault_basic_t4_v2","raptorx_apex_colossus","Apex Colossus",3.20,.78,2.10,.62},
    {"raptor_matriarch_spectre","raptorx_spectre_overlord","Spectre Overlord",2.80,.82,2.35,.58},
    {"raptor_queen_veryhard","raptorx_queen_ascendant","Queen Ascendant",3.80,.72,2.60,.52},
    {"raptor_allterrain_arty_basic_t2_v1","raptorx_siegehowler","Siege Howler",1.55,.78,1.25,.88},
    {"raptor_land_spiker_basic_t2_v1","raptorx_clusterrain","Cluster Rain",1.40,.82,1.15,.90},
    {"raptor_allterrain_arty_emp_t2_v1","raptorx_disruptionmortar","Disruption Mortar",1.48,.80,1.18,.92},
  }
  -- behavior, min/max anger, amount, weight, distance, rarity. Kept in sync
  -- with units/raptorx rosters so each clone gets its OWN squad, not its base's.
  local squads = {
    raptorx_earlycrusher = {"berserk",10,75,48,230,1150,"basic"},
    raptorx_midravager = {"berserk",30,150,20,190,1600,"special"},
    raptorx_latebehemoth = {"berserk",40,150,12,160,2100,"special"},
    raptorx_earlytalon = {"raider",10,85,36,200,1500,"basic"},
    raptorx_midfirewing = {"raider",30,150,16,175,1900,"special"},
    raptorx_lateskyreaper = {"raider",40,150,8,140,2300,"special"},
    raptorx_ironfang = {"berserk",20,85,36,220,1050,"basic"},
    raptorx_dreadrunner = {"raider",20,95,54,225,1200,"basic"},
    raptorx_burnmaw = {"berserk",30,105,42,200,1100,"basic"},
    raptorx_razorclaw = {"raider",30,150,42,180,1250,"basic"},
    raptorx_stormmaw = {"raider",40,150,20,160,1500,"special"},
    raptorx_bonecrusher = {"berserk",50,150,16,100,1800,"special"},
    raptorx_broodlord = {"berserk",60,150,10,120,1900,"special"},
    raptorx_acidstorm = {"artillery",50,150,4,70,2300,"special"},
    raptorx_skyscourge = {"raider",50,150,6,85,2000,"special"},
    raptorx_nestguardian = {"healer",50,150,4,90,1400,"special"},
    raptorx_matriarch_prime = {"berserk",70,150,2,35,2400,"special"},
    raptorx_overmatriarch = {"berserk",70,150,6,65,2300,"special"},
    raptorx_elderqueen = {"berserk",80,150,4,45,2700,"special"},
    raptorx_apex_colossus = {"berserk",90,150,1,25,2800,"special"},
    raptorx_spectre_overlord = {"raider",100,150,1,18,3000,"special"},
    raptorx_queen_ascendant = {"berserk",100,150,1,12,3200,"special"},
    raptorx_siegehowler = {"artillery",40,150,8,130,10200,"special"},
    raptorx_clusterrain = {"artillery",50,150,10,135,7600,"special"},
    raptorx_disruptionmortar = {"artillery",60,150,6,100,6000,"special"},
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
