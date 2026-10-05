-- ScavX Nightmare Overhaul: Unified High-Intensity Squad Roster & Unit Patches
-- Merges scav-ai-smarts and scavx-tweakunits into an extreme difficulty package.
{
  -- =========================================================================
  -- PHASE 1: EARLY-GAME SWARM HARASSMENT (Anger 0 - 35)
  -- =========================================================================
  armpw = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 700, scavsquadminanger = 0, scavsquadmaxanger = 35,
      scavsquadrarity = "basic", scavsquadunitsamount = 140, scavsquadweight = 200,
    },
    stealth = true,
  },
  corak = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 700, scavsquadminanger = 0, scavsquadmaxanger = 35,
      scavsquadrarity = "basic", scavsquadunitsamount = 130, scavsquadweight = 190,
    },
    stealth = true,
  },
  armflea = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 650, scavsquadminanger = 0, scavsquadmaxanger = 25,
      scavsquadrarity = "basic", scavsquadunitsamount = 120, scavsquadweight = 150,
    },
    stealth = true,
  },
  legscout = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 700, scavsquadminanger = 0, scavsquadmaxanger = 30,
      scavsquadrarity = "basic", scavsquadunitsamount = 90, scavsquadweight = 150,
    },
    stealth = true,
  },
  armfast = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1100, scavsquadminanger = 5, scavsquadmaxanger = 40,
      scavsquadrarity = "basic", scavsquadunitsamount = 95, scavsquadweight = 160,
    },
    stealth = true,
  },
  corroach = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 900, scavsquadminanger = 5, scavsquadmaxanger = 45,
      scavsquadrarity = "basic", scavsquadunitsamount = 65, scavsquadweight = 150,
    },
    stealth = true,
  },

  -- =========================================================================
  -- PHASE 2: MID-GAME MECH PUSHES & COMBINED ARMS (Anger 15 - 90)
  -- =========================================================================
  leginc = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 750, scavsquadminanger = 15, scavsquadmaxanger = 55,
      scavsquadrarity = "basic", scavsquadunitsamount = 80, scavsquadweight = 120,
    },
    stealth = true,
  },
  legstr = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 750, scavsquadminanger = 15, scavsquadmaxanger = 55,
      scavsquadrarity = "basic", scavsquadunitsamount = 55, scavsquadweight = 190,
    },
    stealth = true,
  },
  legafigdef = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1200, scavsquadminanger = 25, scavsquadmaxanger = 70,
      scavsquadrarity = "basic", scavsquadunitsamount = 35, scavsquadweight = 160,
    },
    stealth = true,
  },
  cordemon = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 2000, scavsquadminanger = 25, scavsquadmaxanger = 70,
      scavsquadrarity = "basic", scavsquadunitsamount = 30, scavsquadweight = 170,
    },
    mass = 65000,
    stealth = true,
  },
  armfido = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1300, scavsquadminanger = 20, scavsquadmaxanger = 100,
      scavsquadrarity = "basic", scavsquadunitsamount = 20, scavsquadweight = 120,
    },
    stealth = true,
  },
  corpyro = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1300, scavsquadminanger = 20, scavsquadmaxanger = 100,
      scavsquadrarity = "basic", scavsquadunitsamount = 20, scavsquadweight = 120,
    },
    stealth = true,
  },
  legerailtank = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 2000, scavsquadminanger = 20, scavsquadmaxanger = 70,
      scavsquadrarity = "basic", scavsquadunitsamount = 25, scavsquadweight = 120,
    },
    mass = 70000,
    stealth = true,
  },
  legeheatraymech_old = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 2000, scavsquadminanger = 50, scavsquadmaxanger = 130,
      scavsquadrarity = "basic", scavsquadunitsamount = 24, scavsquadweight = 120,
    },
    stealth = true,
  },
  legehovertank = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "kamikaze", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1100, scavsquadminanger = 20, scavsquadmaxanger = 70,
      scavsquadrarity = "basic", scavsquadunitsamount = 35, scavsquadweight = 120,
    },
    stealth = true,
    explodeas = "scav_hoverboom",
    selfdestructas = "scav_hoverboom_selfd",
    weapondefs = {
      scav_hoverboom = {
        areaofeffect = 280, camerashake = 260, impulsefactor = 0.4,
        soundhit = "xplomed1", soundstart = "largegun",
        explosiongenerator = "custom:genericbuildingexplosion-large",
        damage = { default = 2800 },
      },
      scav_hoverboom_selfd = {
        areaofeffect = 380, camerashake = 360, impulsefactor = 0.6,
        soundhit = "xplomed1", soundstart = "largegun",
        explosiongenerator = "custom:genericbuildingexplosion-large",
        damage = { default = 5500 },
      },
    },
  },

  -- =========================================================================
  -- PHASE 3: LATE-GAME EXPERIMENTAL TITANS & SIEGE ARMS (Anger 40 - 150)
  -- =========================================================================
  armbanth = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 2000, scavsquadminanger = 35, scavsquadmaxanger = 100,
      scavsquadrarity = "basic", scavsquadunitsamount = 85, scavsquadweight = 160,
    },
    mass = 145000,
    speed = 55,
    stealth = true,
  },
  armpwt4 = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 2000, scavsquadminanger = 45, scavsquadmaxanger = 110,
      scavsquadrarity = "basic", scavsquadunitsamount = 65, scavsquadweight = 175,
    },
    stealth = true,
  },
  armrattet4 = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 900, scavsquadminanger = 35, scavsquadmaxanger = 80,
      scavsquadrarity = "basic", scavsquadunitsamount = 50, scavsquadweight = 130,
    },
    speed = 36,
    stealth = true,
  },
  legfort = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1200, scavsquadminanger = 35, scavsquadmaxanger = 140,
      scavsquadrarity = "basic", scavsquadunitsamount = 75, scavsquadweight = 130,
    },
    mass = 65000,
    stealth = true,
  },
  legfortt4 = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1200, scavsquadminanger = 50, scavsquadmaxanger = 110,
      scavsquadrarity = "basic", scavsquadunitsamount = 45, scavsquadweight = 185,
    },
    speed = 44,
    stealth = true,
  },
  legmost3 = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 2000, scavsquadminanger = 35, scavsquadmaxanger = 140,
      scavsquadrarity = "basic", scavsquadunitsamount = 40, scavsquadweight = 130,
    },
    health = 18500,
    stealth = true,
  },
  corjugg = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 2000, scavsquadminanger = 60, scavsquadmaxanger = 150,
      scavsquadrarity = "special", scavsquadunitsamount = 50, scavsquadweight = 180,
    },
    mass = 220000,
    speed = 32,
    stealth = true,
  },

  -- =========================================================================
  -- ARTILLERY BARRAGES & FORWARD SPOTTERS
  -- =========================================================================
  armmart = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "artillery", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1250, scavsquadminanger = 15, scavsquadmaxanger = 80,
      scavsquadrarity = "basic", scavsquadunitsamount = 18, scavsquadweight = 100,
    },
    stealth = true,
  },
  cormart = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "artillery", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1250, scavsquadminanger = 15, scavsquadmaxanger = 80,
      scavsquadrarity = "basic", scavsquadunitsamount = 18, scavsquadweight = 100,
    },
    stealth = true,
  },
  armvang = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "artillery", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1300, scavsquadminanger = 20, scavsquadmaxanger = 70,
      scavsquadrarity = "basic", scavsquadunitsamount = 26, scavsquadweight = 175,
    },
    mass = 35000,
    sightdistance = 3600,
    stealth = true,
    weapondefs = {
      shocker_low = { weaponvelocity = 1050 },
    },
  },
  armseer = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "artillery", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1400, scavsquadminanger = 25, scavsquadmaxanger = 120,
      scavsquadrarity = "basic", scavsquadunitsamount = 12, scavsquadweight = 110,
    },
    stealth = true,
  },
  cornecro = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "healer", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 850, scavsquadminanger = 30, scavsquadmaxanger = 150,
      scavsquadrarity = "special", scavsquadunitsamount = 8, scavsquadweight = 120,
    },
    speed = 42,
    stealth = true,
  },

  -- =========================================================================
  -- AIR CORPS (RECON, INTERCEPTORS, GUNSHIPS, BOMBERS)
  -- =========================================================================
  armpeep = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1800, scavsquadminanger = 5, scavsquadmaxanger = 130,
      scavsquadrarity = "basic", scavsquadunitsamount = 14, scavsquadweight = 130,
    },
  },
  corfink = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1800, scavsquadminanger = 5, scavsquadmaxanger = 130,
      scavsquadrarity = "basic", scavsquadunitsamount = 14, scavsquadweight = 130,
    },
  },
  armbrawl = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1100, scavsquadminanger = 10, scavsquadmaxanger = 70,
      scavsquadrarity = "basic", scavsquadunitsamount = 20, scavsquadweight = 120,
    },
  },
  corbw = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1100, scavsquadminanger = 10, scavsquadmaxanger = 70,
      scavsquadrarity = "basic", scavsquadunitsamount = 20, scavsquadweight = 120,
    },
  },
  armhawk = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 900, scavsquadminanger = 5, scavsquadmaxanger = 60,
      scavsquadrarity = "basic", scavsquadunitsamount = 22, scavsquadweight = 110,
    },
  },
  corvamp = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 900, scavsquadminanger = 5, scavsquadmaxanger = 60,
      scavsquadrarity = "basic", scavsquadunitsamount = 22, scavsquadweight = 110,
    },
  },
  armthund = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 900, scavsquadminanger = 10, scavsquadmaxanger = 65,
      scavsquadrarity = "basic", scavsquadunitsamount = 16, scavsquadweight = 90,
    },
  },
  corshad = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 900, scavsquadminanger = 10, scavsquadmaxanger = 65,
      scavsquadrarity = "basic", scavsquadunitsamount = 16, scavsquadweight = 90,
    },
  },
  armjeth = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1100, scavsquadminanger = 15, scavsquadmaxanger = 110,
      scavsquadrarity = "basic", scavsquadunitsamount = 18, scavsquadweight = 110,
    },
    stealth = true,
  },
  coraak = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1100, scavsquadminanger = 15, scavsquadmaxanger = 110,
      scavsquadrarity = "basic", scavsquadunitsamount = 18, scavsquadweight = 110,
    },
    stealth = true,
  },

  -- =========================================================================
  -- NAVAL DOMINANCE (AMPHIBIOUS, CRUISERS, SUBMARINES)
  -- =========================================================================
  armcroc = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 950, scavsquadminanger = 30, scavsquadmaxanger = 130,
      scavsquadrarity = "basic", scavsquadunitsamount = 16, scavsquadweight = 120,
    },
    stealth = true,
  },
  corgarp = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 950, scavsquadminanger = 30, scavsquadmaxanger = 130,
      scavsquadrarity = "basic", scavsquadunitsamount = 16, scavsquadweight = 120,
    },
    stealth = true,
  },
  armcrus = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "artillery", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1700, scavsquadminanger = 65, scavsquadmaxanger = 150,
      scavsquadrarity = "special", scavsquadunitsamount = 8, scavsquadweight = 110,
    },
    stealth = true,
  },
  corcrus = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "artillery", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1700, scavsquadminanger = 65, scavsquadmaxanger = 150,
      scavsquadrarity = "special", scavsquadunitsamount = 8, scavsquadweight = 110,
    },
    stealth = true,
  },
  armsub = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1100, scavsquadminanger = 50, scavsquadmaxanger = 150,
      scavsquadrarity = "special", scavsquadunitsamount = 10, scavsquadweight = 95,
    },
    stealth = true,
  },
  corsub = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1100, scavsquadminanger = 50, scavsquadmaxanger = 150,
      scavsquadrarity = "special", scavsquadunitsamount = 10, scavsquadweight = 95,
    },
    stealth = true,
  },

  -- =========================================================================
  -- REINFORCED BASE DEFENSES & REBALANCED WEAPONS
  -- =========================================================================
  armflak = {
    health = 10750,
    weapondefs = {
      armflak_gun = { damage = { vtol = 3000 }, range = 1550, reloadtime = 0.3 },
    },
  },
  corflak = {
    health = 10750,
    weapondefs = {
      armflak_gun = { damage = { vtol = 3000 }, range = 1550, reloadtime = 0.3 },
    },
  },
  legflak = {
    health = 10750,
    weapondefs = {
      leg_t2_microflak = { accuracy = 500, damage = { vtol = 300 }, range = 1500 },
    },
  },
  armsptkt4 = {
    weapondefs = {
      adv_rocket = { reloadtime = 3 },
    },
  },

  -- Base structure footprint locks
  armmmkrt3 = { footprintx = 6, footprintz = 6 },
  cormmkrt3 = { footprintx = 6, footprintz = 6 },
  legadveconvt3 = { footprintx = 6, footprintz = 6 },
}