-- Compact RaptorX custom unit registration. Weapon overlays are applied by
-- the specialist weapon/artillery packs after these clones are created.
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
  for _, s in ipairs(specs) do
    local source = UnitDefs[s[1]]
    if source and not UnitDefs[s[2]] then
      local unit = copy(source)
      unit.unitname, unit.name = s[2], s[3]
      unit.description = "RaptorX custom combat variant"
      unit.maxdamage = (unit.maxdamage or 1) * s[4]
      unit.speed = (unit.speed or 1) * s[5]
      unit.buildoptions = {}
      unit.weapondefs = unit.weapondefs or {}
      unit.weapons = unit.weapons or {}
      for _, w in pairs(unit.weapondefs) do
        if w.damage and w.damage.default then w.damage.default = w.damage.default * s[6] end
        w.reloadtime = (w.reloadtime or 1) * s[7]
      end
      UnitDefs[s[2]] = unit
    end
  end
end
