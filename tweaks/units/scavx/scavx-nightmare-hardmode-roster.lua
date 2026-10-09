-- ScavX Nightmare hard-mode companion. Enable alongside both Nightmare files.
-- Verified against BAR's mobile bases: retain native models, scripts and mounts.
-- Weapon keys are native definitions, not new unsupported firing slots.
-- These patches also affect player copies of the same base units.
{
  -- Cloaking EMP hunters: expose them with detection or close-range screening.
  armspid = {
    health = 5200, speed = 82, sightdistance = 650,
    cancloak = true, cloakcost = 30, cloakcostmoving = 90,
    initcloaked = true, mincloakdistance = 160, decloakonfire = true,
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 550, scavsquadminanger = 18, scavsquadmaxanger = 105,
      scavsquadrarity = "special", scavsquadunitsamount = 12, scavsquadweight = 155,
    },
    weapondefs = {
      spider = {
        name = "Nightmare Lockdown Beam", range = 480, reloadtime = 1.4,
        paralyzer = true, paralyzetime = 7, damage = { default = 2400 },
        thickness = 3, rgbcolor = "0.45 0.2 1",
        explosiongenerator = "custom:laserhit-emp",
      },
    },
  },
  -- Mobile jammer, NOT a healer: hides approaching ground squads from radar.
  armjam = {
    health = 5000, speed = 82, radarjamdistance = 650,
    onoffable = true, activatewhenbuilt = true, stealth = true,
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 900, scavsquadminanger = 12, scavsquadmaxanger = 100,
      scavsquadrarity = "special", scavsquadunitsamount = 4, scavsquadweight = 100,
    },
  },
  -- Breach tank: six actual pellets per cannon shot plus physical knockback.
  correap = {
    health = 21000, speed = 72, autoheal = 60, sightdistance = 650,
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 700, scavsquadminanger = 35, scavsquadmaxanger = 150,
      scavsquadrarity = "basic", scavsquadunitsamount = 10, scavsquadweight = 180,
    },
    weapondefs = {
      cor_reap = {
        name = "Nightmare Breach Shotgun", range = 560, reloadtime = 2.4,
        projectilespershot = 6, sprayangle = 1700, weaponvelocity = 900,
        areaofeffect = 64, damage = { default = 300, vtol = 45 },
        impulsefactor = 1.2, noselfdamage = true,
        rgbcolor = "1 0.3 0.1", size = 4,
        explosiongenerator = "custom:genericshellexplosion-small-t2",
      },
    },
  },
  -- Native vertical rocket launcher: three rockets, same supported muzzle.
  corhrk = {
    health = 11000, speed = 60, sightdistance = 1500,
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "artillery", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1350, scavsquadminanger = 35, scavsquadmaxanger = 150,
      scavsquadrarity = "special", scavsquadunitsamount = 6, scavsquadweight = 165,
    },
    weapondefs = {
      corhrk_rocket = {
        name = "Nightmare Saturation Rockets", range = 1450, reloadtime = 6,
        burst = 3, burstrate = 0.25, areaofeffect = 140,
        damage = { default = 1250 },
        cegtag = "missiletrailmedium-starburst",
        explosiongenerator = "custom:genericshellexplosion-large-bomb",
        customparams = { overrange_distance = 1668 },
      },
    },
  },
  -- Close air support: rapid plasma volley instead of a fake kamikaze mechanic.
  armkam = {
    health = 5800, speed = 210, sightdistance = 650,
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 700, scavsquadminanger = 20, scavsquadmaxanger = 130,
      scavsquadrarity = "basic", scavsquadunitsamount = 14, scavsquadweight = 160,
    },
    weapondefs = {
      emg = {
        name = "Nightmare Plasma Rake", range = 480, reloadtime = 1,
        burst = 6, burstrate = 0.06, sprayangle = 700,
        areaofeffect = 70, damage = { default = 85, vtol = 15 },
        rgbcolor = "1 0.3 0.8", size = 3,
        explosiongenerator = "custom:plasmahit-small",
      },
    },
  },
  -- Actual repair support: native nanolathe, repair reach and workertime.
  armfark = {
    health = 7200, speed = 85, canrepair = true,
    builddistance = 300, workertime = 600, autoheal = 45,
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "healer", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 750, scavsquadminanger = 28, scavsquadmaxanger = 150,
      scavsquadrarity = "special", scavsquadunitsamount = 4, scavsquadweight = 125,
    },
  },

  -- Player Mega Units from player-mega-units.lua: mass mixed-role formations.
  -- Frequent basic-pool Mega squads: three of each type, available at 20% anger.
  player_riftcolossus = { customparams = { scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1, scavsquadbehaviordistance = 2200, scavsquadminanger = 20, scavsquadmaxanger = 150, scavsquadrarity = "basic", scavsquadunitsamount = 3, scavsquadweight = 900 } },
  player_riftjump = { customparams = { scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1, scavsquadbehaviordistance = 2200, scavsquadminanger = 20, scavsquadmaxanger = 150, scavsquadrarity = "basic", scavsquadunitsamount = 3, scavsquadweight = 875 } },
  player_vortexdominator = { customparams = { scavcustomsquad = "1", scavsquadbehavior = "artillery", scavsquadbehaviorchance = 1, scavsquadbehaviordistance = 2200, scavsquadminanger = 20, scavsquadmaxanger = 150, scavsquadrarity = "basic", scavsquadunitsamount = 3, scavsquadweight = 900 } },
  player_vortexwell = { customparams = { scavcustomsquad = "1", scavsquadbehavior = "healer", scavsquadbehaviorchance = 1, scavsquadbehaviordistance = 1800, scavsquadminanger = 20, scavsquadmaxanger = 150, scavsquadrarity = "basic", scavsquadunitsamount = 3, scavsquadweight = 850 } },
  player_aegisbreaker = { customparams = { scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1, scavsquadbehaviordistance = 1800, scavsquadminanger = 20, scavsquadmaxanger = 150, scavsquadrarity = "basic", scavsquadunitsamount = 3, scavsquadweight = 950 } },
  player_solardecimator = { customparams = { scavcustomsquad = "1", scavsquadbehavior = "artillery", scavsquadbehaviorchance = 1, scavsquadbehaviordistance = 2400, scavsquadminanger = 20, scavsquadmaxanger = 150, scavsquadrarity = "basic", scavsquadunitsamount = 3, scavsquadweight = 900 } },
  player_skyfurnace = { customparams = { scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1, scavsquadbehaviordistance = 2000, scavsquadminanger = 20, scavsquadmaxanger = 150, scavsquadrarity = "basic", scavsquadunitsamount = 3, scavsquadweight = 950 } },
  player_stormsovereign = { customparams = { scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1, scavsquadbehaviordistance = 2000, scavsquadminanger = 20, scavsquadmaxanger = 150, scavsquadrarity = "basic", scavsquadunitsamount = 3, scavsquadweight = 950 } },
  player_pyroclast = { customparams = { scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1, scavsquadbehaviordistance = 2000, scavsquadminanger = 20, scavsquadmaxanger = 150, scavsquadrarity = "basic", scavsquadunitsamount = 3, scavsquadweight = 950 } },
  player_worldbeam = { customparams = { scavcustomsquad = "1", scavsquadbehavior = "artillery", scavsquadbehaviorchance = 1, scavsquadbehaviordistance = 2400, scavsquadminanger = 20, scavsquadmaxanger = 150, scavsquadrarity = "basic", scavsquadunitsamount = 3, scavsquadweight = 900 } },
  player_singularity = { customparams = { scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1, scavsquadbehaviordistance = 2200, scavsquadminanger = 20, scavsquadmaxanger = 150, scavsquadrarity = "basic", scavsquadunitsamount = 3, scavsquadweight = 900 } },
  player_aethersiege = { customparams = { scavcustomsquad = "1", scavsquadbehavior = "artillery", scavsquadbehaviorchance = 1, scavsquadbehaviordistance = 2400, scavsquadminanger = 20, scavsquadmaxanger = 150, scavsquadrarity = "basic", scavsquadunitsamount = 3, scavsquadweight = 900 } },
  player_phantomleviathan = { customparams = { scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1, scavsquadbehaviordistance = 2200, scavsquadminanger = 20, scavsquadmaxanger = 150, scavsquadrarity = "basic", scavsquadunitsamount = 3, scavsquadweight = 1000 } },
  player_archangel = { customparams = { scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1, scavsquadbehaviordistance = 2000, scavsquadminanger = 20, scavsquadmaxanger = 150, scavsquadrarity = "basic", scavsquadunitsamount = 3, scavsquadweight = 1000 } },
}
