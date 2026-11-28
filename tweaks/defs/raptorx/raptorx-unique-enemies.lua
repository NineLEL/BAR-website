-- Unique RaptorX enemy squads: standalone tweakdefs with BAR gadget mechanics.
-- Uses overpenetration, chain lightning, cluster munitions, mid-air split-spawns,
-- sector-fire saturation, and persistent death/hit hazard areas.
do
  local function copy(v)
    if type(v) ~= "table" then return v end
    local out = {}
    for k, child in pairs(v) do out[k] = copy(child) end
    return out
  end
  local langs = { "en", "de", "fr", "es", "it", "ru", "zh", "cs", "hr", "lt" }
  local function wdef(t)
    t.avoidfeature, t.avoidfriendly, t.collidefriendly, t.noselfdamage = false, false, false, true
    if t.turret == nil then t.turret = true end
    return t
  end
  local function areaHit(kind, dur, dmg, rad)
    return {
      area_onhit_ceg = kind .. "-area-" .. rad .. "-repeat",
      area_onhit_damageceg = kind == "acid" and "acid-damage-gen" or "burnthermite",
      area_onhit_time = dur, area_onhit_damage = dmg, area_onhit_range = rad,
      area_onhit_resistance = kind == "acid" and "_RAPTORACID_" or "_RAPTORFIRE_",
      nofire = kind == "acid" or nil, water_splash = 0,
    }
  end
  local function areaDeath(cp, kind, dur, dmg, rad)
    cp.area_ondeath_ceg = kind .. "-area-" .. rad .. "-repeat"
    cp.area_ondeath_damageceg = kind == "acid" and "acid-damage-gen" or "burnthermite"
    cp.area_ondeath_time, cp.area_ondeath_damage, cp.area_ondeath_range = dur, dmg, rad
    cp.area_ondeath_resistance = kind == "acid" and "_RAPTORACID_" or "_RAPTORFIRE_"
  end
  local function register(base, id, name, desc, hp, spd, squad, setup)
    local src = UnitDefs[base]
    if not src or UnitDefs[id] or type(src.weapondefs) ~= "table" or type(src.weapons) ~= "table" then return end
    local u = copy(src)
    u.unitname, u.name, u.description = id, name, desc
    u.health, u.maxdamage, u.speed = hp, hp, spd
    u.builder, u.buildoptions, u.maxthisunit = false, {}, nil
    u.canrepair, u.canreclaim, u.workertime = false, false, 0
    u.autoheal = math.max(tonumber(u.autoheal) or 0, math.floor(hp * 0.002))
    u.sightdistance = math.max(tonumber(u.sightdistance) or 0, 900)
    local cp = u.customparams or {}
    u.customparams = cp
    cp.israptor, cp.raptorx_unique = true, 1
    cp.raptorx_ultra_hardened, cp.raptorx_squadweight_adjusted = nil, nil
    cp.raptorcustomsquad, cp.raptorsquadrarity = "1", squad[6] or "special"
    cp.raptorsquadbehavior, cp.raptorsquadbehaviorchance = squad[1], 1
    cp.raptorsquadbehaviordistance, cp.raptorsquadminanger = squad[2], squad[3]
    cp.raptorsquadmaxanger = 150
    cp.raptorsquadunitsamount, cp.raptorsquadweight = squad[4], squad[5]
    cp.raptorsquadforceair, cp.raptorsquadforcesurface = nil, nil
    for _, l in ipairs(langs) do
      cp["i18n_" .. l .. "_humanname"] = name
      cp["i18n_" .. l .. "_tooltip"] = desc
    end
    setup(u, cp)
    UnitDefs[id] = u
  end

  -- 1. Voidlance Piercer: cloaked sniper firing overpenetrating rail beams through walls/frontlines.
  register("raptor_land_spiker_spectre_t4_v1", "raptorx_voidlance_piercer", "Voidlance Piercer",
    "Cloaked rail-spitter whose overpenetrating beam punches through slain frontliners and walls.",
    2800, 145, { "skirmisher", 580, 45, 2, 16 },
    function(u)
      u.cancloak, u.initcloak, u.stealth = true, true, true
      u.cloakcost, u.cloakcostmoving, u.mincloakdistance = 0, 0, 200
      u.decloakonfire, u.cloaktimeout = true, 150
      u.weapondefs = {
        voidlance = wdef({
          name = "Overpenetrating Voidlance", weapontype = "LaserCannon",
          range = 980, reloadtime = 5.8, weaponvelocity = 3200, duration = 0.11,
          areaofeffect = 16, impactonly = true, noexplode = true, hardstop = true,
          intensity = 0.9, thickness = 3.2, rgbcolor = "0.75 0.25 1.0",
          cegtag = "railgun", explosiongenerator = "custom:plasmahit-sparkonly",
          soundstart = "heavyrailgun", soundhit = "mavgun3",
          customparams = { overpenetrate = true, overpenetrate_penalty = 0.05 },
          damage = { default = 620, commanders = 320, shields = 1050 },
        }),
      }
      u.weapons = { { def = "VOIDLANCE", maindir = "0 0 1", maxangledif = 180, onlytargetcategory = "NOTAIR" } }
    end)

  -- 2. Arcweaver Conduit: lethal chain-lightning bruiser with anti-air EMP spores.
  register("raptor_land_assault_emp_t2_v1", "raptorx_arcweaver_conduit", "Arcweaver Conduit",
    "Chain-lightning stalker that arcs across up to 5 nearby units and fires AA EMP spores.",
    10500, 46, { "berserk", 1200, 50, 2, 15 },
    function(u, cp)
      cp.paralyzemultiplier = 0.1
      u.explodeas, u.selfdestructas = "raptor_empdeath_big", "raptor_empdeath_big"
      u.airsightdistance = 1200
      u.weapondefs = {
        arclance = wdef({
          name = "Lethal Chain Lightning", weapontype = "LightningCannon",
          range = 440, reloadtime = 3.4, weaponvelocity = 450, duration = 1.2, beamttl = 1,
          burst = 8, burstrate = 0.03333, areaofeffect = 16, impactonly = 1,
          intensity = 26, thickness = 1.8, rgbcolor = "0.45 0.7 1.0",
          explosiongenerator = "custom:genericshellexplosion-medium-lightning2",
          soundstart = "electric2", soundhit = "lashit", soundtrigger = true,
          customparams = {
            spark_ceg = "genericshellexplosion-splash-large-lightning",
            spark_forkdamage = "0.55", spark_maxunits = "5", spark_range = "145",
          },
          damage = { default = 55, shields = 125 },
        }),
        aa_emp = wdef({
          name = "Static Spore Pod", weapontype = "MissileLauncher",
          range = 900, reloadtime = 5.5, weaponvelocity = 1800, startvelocity = 900,
          weaponacceleration = 60, flighttime = 4, turnrate = 55000, tracks = true,
          areaofeffect = 160, paralyzer = true, paralyzetime = 5, burnblow = true,
          model = "SimpleFlareXL.s3o", texture1 = "orangenovaexplo", texture2 = "sporetrail_xl",
          explosiongenerator = "custom:genericshellexplosion-medium-lightning2",
          soundstart = "spore_xl", soundhit = "empbomb",
          damage = { default = 1, vtol = 1100 },
        }),
      }
      u.weapons = {
        { def = "ARCLANCE", maindir = "0 0 1", maxangledif = 135, onlytargetcategory = "NOTAIR" },
        { def = "AA_EMP", onlytargetcategory = "VTOL" },
      }
    end)

  -- 3. Broodscatter Mortar: high-arc shell splits mid-air into 4 live swarmer hatch-pods.
  register("raptor_allterrain_arty_brood_t4_v1", "raptorx_broodscatter_mortar", "Broodscatter Mortar",
    "All-terrain mortar whose shells split mid-air, raining live EMP and Acid swarmers behind walls.",
    9500, 54, { "artillery", 1800, 55, 1, 13 },
    function(u)
      u.sightdistance = 1400
      u.weapondefs = {
        splitpod = wdef({
          name = "Broodscatter Egg Pod", weapontype = "Cannon", hightrajectory = 1,
          range = 1850, reloadtime = 14.0, weaponvelocity = 560, accuracy = 850, sprayangle = 650,
          areaofeffect = 96, model = "Raptors/SGreyRock1.S3O", cegtag = "arty-heavy-purple",
          explosiongenerator = "custom:dirt", soundstart = "bugarty", soundhit = "smallraptorattack",
          customparams = {
            speceffect = "split", speceffect_def = "raptorx_broodscatter_mortar_hatchpod",
            number = "4", splitexplosionceg = "genericshellexplosion-medium",
            cegtag = "arty-heavy-purple", model = "Raptors/s_raptor_white.s3o",
          },
          damage = { default = 90, shields = 210 },
        }),
        hatchpod = wdef({
          name = "Hatchling Pod", weapontype = "Cannon", turret = false,
          range = 1850, reloadtime = 10, weaponvelocity = 420,
          areaofeffect = 96, model = "Raptors/s_raptor_white.s3o", cegtag = "arty-heavy-purple",
          explosiongenerator = "custom:blood_explode", soundhit = "smallraptorattack",
          customparams = {
            spawns_name = "raptor_land_swarmer_emp_t2_v1 raptor_land_swarmer_acids_t2_v1",
            spawns_mode = "random", spawns_surface = "LAND SEA", spawns_expire = 45, spawns_stun = 0.5,
          },
          damage = { default = 65, shields = 175 },
        }),
      }
      u.weapons = { { def = "SPLITPOD", badtargetcategory = "MOBILE", maindir = "0 0 1", maxangledif = 65, onlytargetcategory = "NOTAIR" } }
    end)

  -- 4. Pyreburst Lobber: cluster artillery blanketing target zones in 7 bouncing thermite bomblets.
  register("raptor_allterrain_arty_basic_t4_v1", "raptorx_pyreburst_lobber", "Pyreburst Lobber",
    "All-terrain artillery firing cluster shells that scatter 7 thermite fire-pool bomblets on impact.",
    10500, 50, { "artillery", 1900, 60, 1, 12 },
    function(u, cp)
      cp.areadamageresistance = "LuaAreaDamage__RAPTORACID_ LuaAreaDamage__RAPTORFIRE_"
      u.sightdistance = 1400
      u.weapondefs = {
        pyreshell = wdef({
          name = "Pyreburst Cluster Shell", weapontype = "Cannon",
          range = 1950, reloadtime = 12.0, weaponvelocity = 540, accuracy = 750,
          areaofeffect = 150, cegtag = "blob_trail_red",
          explosiongenerator = "custom:genericshellexplosion-large",
          soundstart = "bugarty", soundhit = "xplomed4",
          customparams = { cluster_def = "pyre_bomblet", cluster_number = 7 },
          damage = { default = 360, shields = 700 },
        }),
        pyre_bomblet = wdef({
          name = "Thermite Spore Bomblet", weapontype = "Cannon", turret = false,
          range = 140, areaofeffect = 100, cegtag = "burnflamexm",
          explosiongenerator = "custom:burnthermite", soundhit = "flamhit1", soundhitwet = "sizzle",
          customparams = areaHit("fire", 7, 45, 75),
          damage = { default = 115, shields = 230 },
        }),
      }
      u.weapons = { { def = "PYRESHELL", badtargetcategory = "MOBILE", maindir = "0 0 1", maxangledif = 65, onlytargetcategory = "NOTAIR" } }
    end)

  -- 5. Tempest Swooper: armored hover-gunship with shield-melting chain EMP lightning.
  register("raptor_air_gunship_emp_t2_v1", "raptorx_tempest_swooper", "Tempest Swooper",
    "Heavy hover-gunship that strips shields and chain-paralyzes clustered defenses.",
    2600, 225, { "raider", 1600, 65, 2, 14 },
    function(u, cp)
      cp.paralyzemultiplier = 0.25
      u.explodeas, u.selfdestructas = "raptor_empdeath_small", "raptor_empdeath_small"
      u.weapondefs = {
        skyarc = wdef({
          name = "Tempest Arc Cannon", weapontype = "LightningCannon",
          range = 460, reloadtime = 3.6, weaponvelocity = 450, duration = 1, beamttl = 1,
          burst = 10, burstrate = 0.03333, areaofeffect = 48, paralyzer = true, paralyzetime = 5,
          intensity = 22, thickness = 1.6, rgbcolor = "0.35 0.85 1.0",
          explosiongenerator = "custom:genericshellexplosion-medium-lightning2",
          soundstart = "alien_electric_xl", soundtrigger = true,
          customparams = {
            spark_ceg = "genericshellexplosion-splash-lightning",
            spark_forkdamage = "0.50", spark_maxunits = "3", spark_range = "100",
          },
          damage = { default = 850, shields = 2100 },
        }),
      }
      u.weapons = { { def = "SKYARC", maindir = "0 0 1", maxangledif = 140, onlytargetcategory = "NOTAIR" } }
    end)

  -- 6. Miasma Sector-Crawler: 3-weapon brawler (acid sector barrage + heavy flamer + AA + fire death pool).
  register("raptor_land_swarmer_fire_t4_v1", "raptorx_miasma_crawler", "Miasma Sector-Crawler",
    "Three-weapon crawler: carpets sectors in acid, scorches blockers, and leaves a fire pool on death.",
    13000, 84, { "berserk", 1350, 70, 1, 12 },
    function(u, cp)
      cp.areadamageresistance = "LuaAreaDamage__RAPTORACID_ LuaAreaDamage__RAPTORFIRE_"
      areaDeath(cp, "fire", 8, 70, 150)
      u.airsightdistance = 1100
      local acidCp = areaHit("acid", 10, 55, 100)
      acidCp.speceffect, acidCp.max_range_reduction, acidCp.spread_angle = "sector_fire", "0.45", "40"
      u.weapondefs = {
        acid_sector = wdef({
          name = "Acid Sector Salvo", weapontype = "Cannon",
          range = 720, reloadtime = 6.5, weaponvelocity = 440, burst = 4, burstrate = 0.08,
          areaofeffect = 130, cegtag = "blob_trail_green", rgbcolor = "0.8 0.99 0.11",
          explosiongenerator = "custom:acid-explosion-xl",
          soundstart = "alien_bombrel", soundhit = "bloodsplash3",
          customparams = acidCp,
          damage = { default = 60, shields = 240 },
        }),
        thermite_maw = wdef({
          name = "Thermite Maw", weapontype = "Flame",
          range = 360, reloadtime = 2.2, weaponvelocity = 285, burst = 10, burstrate = 0.03333,
          areaofeffect = 72, sizegrowth = 1.6, sprayangle = 120,
          cegtag = "burnflamethermite", explosiongenerator = "custom:burnthermite",
          soundstart = "cflamhvy1", soundhitwet = "sizzle",
          customparams = areaHit("fire", 5, 45, 75),
          damage = { default = 48 },
        }),
        aa_spores = wdef({
          name = "Spore Interceptor", weapontype = "MissileLauncher",
          range = 850, reloadtime = 3.8, weaponvelocity = 1900, startvelocity = 950,
          weaponacceleration = 50, flighttime = 4, turnrate = 58000, tracks = true,
          areaofeffect = 150, burnblow = true, model = "SimpleFlareXL.s3o",
          texture1 = "orangenovaexplo", texture2 = "sporetrail_xl",
          explosiongenerator = "custom:genericshellexplosion-medium",
          soundstart = "spore_xl", soundhit = "spore_explo",
          damage = { default = 1, vtol = 500 },
        }),
      }
      u.weapons = {
        { def = "ACID_SECTOR", maindir = "0 0 1", maxangledif = 120, onlytargetcategory = "NOTAIR" },
        { def = "THERMITE_MAW", maindir = "0 0 1", maxangledif = 120, onlytargetcategory = "SURFACE" },
        { def = "AA_SPORES", onlytargetcategory = "VTOL" },
      }
    end)

  -- 7. Abyssal Sky-Nest: armored brood bomber dropping sequential acid/EMP-dodo/kamikaze pods.
  register("raptor_air_bomber_brood_t4_v2", "raptorx_abyssal_skynest", "Abyssal Sky-Nest",
    "Armored brood bomber dropping sequential pods of acid swarmers and EMP or blast dodos.",
    8000, 185, { "raider", 2200, 75, 1, 8 },
    function(u)
      u.weapondefs = {
        vanguard_pods = wdef({
          name = "Vanguard Drop Pods", weapontype = "AircraftBomb", turret = false,
          range = 1500, reloadtime = 0.6, burst = 4, burstrate = 0.14, mygravity = 0.45,
          accuracy = 12000, sprayangle = 16000, areaofeffect = 130,
          model = "Raptors/raptoregg_l_darkgreen.s3o", explosiongenerator = "custom:blood_explode_xl",
          soundstart = "alien_bombrel", soundhit = "bloodsplash3",
          customparams = {
            spawns_name = "raptor_land_swarmer_acids_t2_v1 raptor_land_kamikaze_emp_t2_v1 raptor_land_kamikaze_basic_t2_v1",
            spawns_mode = "sequential", spawns_surface = "LAND SEA", spawns_expire = 40, spawns_stun = 1.5,
          },
          damage = { default = 420, shields = 800 },
        }),
      }
      u.weapons = { { def = "VANGUARD_PODS" } }
    end)

  -- 8. Chronovore Apex: all-terrain EMP shell that shatters into 8 kinetic cluster shards + acid death pool.
  register("raptor_allterrain_arty_emp_t4_v1", "raptorx_chronovore_apex", "Chronovore Apex",
    "Endgame siege leviathan: EMP shells disable shields before 8 cluster shards detonate beneath.",
    36000, 58, { "artillery", 2200, 85, 1, 5 },
    function(u, cp)
      cp.paralyzemultiplier = 0.2
      cp.areadamageresistance = "LuaAreaDamage__RAPTORACID_"
      areaDeath(cp, "acid", 12, 90, 200)
      u.sightdistance = 1600
      u.explodeas, u.selfdestructas = "raptor_empdeath_big", "raptor_empdeath_big"
      u.weapondefs = {
        chrono_shell = wdef({
          name = "Chronovore EMP Cluster Shell", weapontype = "Cannon",
          range = 2150, reloadtime = 13.0, weaponvelocity = 580, accuracy = 700,
          burst = 2, burstrate = 0.35, areaofeffect = 210,
          paralyzer = true, paralyzetime = 8, cegtag = "blob_trail_blue",
          explosiongenerator = "custom:genericshellexplosion-large-lightning",
          soundstart = "bugarty", soundhit = "empbomb",
          customparams = { cluster_def = "chrono_shard", cluster_number = 8 },
          damage = { default = 3100, shields = 4200 },
        }),
        chrono_shard = wdef({
          name = "Chronovore Kinetic Shard", weapontype = "Cannon", turret = false,
          range = 160, areaofeffect = 120, cegtag = "ministarfire",
          explosiongenerator = "custom:ministarfire-explosion", soundhit = "xplomed2", soundhitwet = "splsmed",
          damage = { default = 450, shields = 700 },
        }),
      }
      u.weapons = { { def = "CHRONO_SHELL", badtargetcategory = "MOBILE", maindir = "0 0 1", maxangledif = 65, onlytargetcategory = "NOTAIR" } }
    end)
end
