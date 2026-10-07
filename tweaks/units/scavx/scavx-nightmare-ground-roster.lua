-- ScavX Nightmare Overhaul: Unified High-Intensity Squad Roster & Unit Patches
-- Merges scav-ai-smarts and scavx-tweakunits into an extreme difficulty package.
-- Custom ScavX units below require their matching tweaks/defs/scavx clone packs.
-- Only mobile combat clones join squads; economy, builders and static defenses stay out.
-- Enable ScavXNightmare-support.lua too for artillery, air and naval squads.
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

  armstump = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 850, scavsquadminanger = 5, scavsquadmaxanger = 45,
      scavsquadrarity = "basic", scavsquadunitsamount = 65, scavsquadweight = 140,
    },
    stealth = true,
  },
  corraid = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 850, scavsquadminanger = 5, scavsquadmaxanger = 45,
      scavsquadrarity = "basic", scavsquadunitsamount = 65, scavsquadweight = 140,
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

  armrock = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1000, scavsquadminanger = 15, scavsquadmaxanger = 65,
      scavsquadrarity = "basic", scavsquadunitsamount = 45, scavsquadweight = 120,
    },
    stealth = true,
  },
  corstorm = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1000, scavsquadminanger = 15, scavsquadmaxanger = 65,
      scavsquadrarity = "basic", scavsquadunitsamount = 45, scavsquadweight = 120,
    },
    stealth = true,
  },
  armzeus = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1300, scavsquadminanger = 25, scavsquadmaxanger = 100,
      scavsquadrarity = "basic", scavsquadunitsamount = 35, scavsquadweight = 130,
    },
    stealth = true,
  },
  corsumo = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1500, scavsquadminanger = 35, scavsquadmaxanger = 130,
      scavsquadrarity = "basic", scavsquadunitsamount = 20, scavsquadweight = 130,
    },
    stealth = true,
  },

  -- =========================================================================
  -- PHASE 3: LATE-GAME EXPERIMENTAL TITANS & SIEGE ARMS (Anger 35 - 150)
  -- All T3/T4 late-game entries begin at 35% anger for earlier escalation.
  -- =========================================================================
  armbanth = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
        scavsquadbehaviordistance = 2000, scavsquadminanger = 35, scavsquadmaxanger = 100,
       scavsquadrarity = "basic", scavsquadunitsamount = 110, scavsquadweight = 160,
    },
    mass = 145000,
    speed = 55,
    stealth = true,
  },
  armpwt4 = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
        scavsquadbehaviordistance = 2000, scavsquadminanger = 35, scavsquadmaxanger = 110,
       scavsquadrarity = "basic", scavsquadunitsamount = 90, scavsquadweight = 175,
    },
    stealth = true,
  },
  armrattet4 = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
        scavsquadbehaviordistance = 900, scavsquadminanger = 35, scavsquadmaxanger = 80,
       scavsquadrarity = "basic", scavsquadunitsamount = 70, scavsquadweight = 130,
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
        scavsquadbehaviordistance = 1200, scavsquadminanger = 35, scavsquadmaxanger = 110,
       scavsquadrarity = "basic", scavsquadunitsamount = 65, scavsquadweight = 185,
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
       scavsquadbehaviordistance = 2000, scavsquadminanger = 35, scavsquadmaxanger = 150,
       scavsquadrarity = "special", scavsquadunitsamount = 65, scavsquadweight = 180,
    },
    mass = 220000,
    speed = 32,
    stealth = true,
  },

  -- =========================================================================
  -- CUSTOM SCAVX HEAVIES (requires scavx-tweakdefs through scavx-tweakdefs6)
  -- Keep boss-sized squads small; their health and weapons come from the defs packs.
  -- =========================================================================
  busters = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
       scavsquadbehaviordistance = 2000, scavsquadminanger = 35, scavsquadmaxanger = 150,
       scavsquadrarity = "basic", scavsquadunitsamount = 60, scavsquadweight = 210,
    },
    stealth = true,
  },
  fatherbehe = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
       scavsquadbehaviordistance = 2000, scavsquadminanger = 35, scavsquadmaxanger = 150,
       scavsquadrarity = "basic", scavsquadunitsamount = 42, scavsquadweight = 210,
    },
    stealth = true,
  },
  kingchimera = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
       scavsquadbehaviordistance = 2000, scavsquadminanger = 35, scavsquadmaxanger = 150,
       scavsquadrarity = "special", scavsquadunitsamount = 8, scavsquadweight = 220,
    },
    stealth = true,
  },
  ratteking = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
       scavsquadbehaviordistance = 900, scavsquadminanger = 35, scavsquadmaxanger = 150,
       scavsquadrarity = "special", scavsquadunitsamount = 9, scavsquadweight = 200,
    },
    stealth = true,
  },
  thetyrannus = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
       scavsquadbehaviordistance = 1200, scavsquadminanger = 35, scavsquadmaxanger = 150,
       scavsquadrarity = "special", scavsquadunitsamount = 27, scavsquadweight = 220,
    },
    stealth = true,
  },
  titaniator = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
       scavsquadbehaviordistance = 2000, scavsquadminanger = 35, scavsquadmaxanger = 150,
       scavsquadrarity = "basic", scavsquadunitsamount = 75, scavsquadweight = 220,
    },
    stealth = true,
  },
  quincy = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "artillery", scavsquadbehaviorchance = 1,
       scavsquadbehaviordistance = 1300, scavsquadminanger = 35, scavsquadmaxanger = 150,
       scavsquadrarity = "special", scavsquadunitsamount = 54, scavsquadweight = 230,
    },
    stealth = true,
  },
  walkingfort = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "artillery", scavsquadbehaviorchance = 1,
       scavsquadbehaviordistance = 1300, scavsquadminanger = 35, scavsquadmaxanger = 150,
       scavsquadrarity = "special", scavsquadunitsamount = 27, scavsquadweight = 230,
    },
    stealth = true,
  },
  wallnut = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
       scavsquadbehaviordistance = 1200, scavsquadminanger = 35, scavsquadmaxanger = 150,
       scavsquadrarity = "special", scavsquadunitsamount = 15, scavsquadweight = 190,
    },
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
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "artillery", scavsquadbehaviorchance = 1,
       scavsquadbehaviordistance = 1400, scavsquadminanger = 35, scavsquadmaxanger = 150,
       scavsquadrarity = "special", scavsquadunitsamount = 26, scavsquadweight = 140,
    },
    stealth = true,
    weapondefs = {
      adv_rocket = { reloadtime = 3 },
    },
  },

  -- Base structure footprint locks
  armmmkrt3 = { footprintx = 6, footprintz = 6 },
  cormmkrt3 = { footprintx = 6, footprintz = 6 },
  legadveconvt3 = { footprintx = 6, footprintz = 6 },
}
