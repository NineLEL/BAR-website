-- ScavX Nightmare companion: artillery, air and naval squads.
-- Enable alongside ScavXNightmare.lua. Split to keep each command below 16384 chars.
{
  -- ARTILLERY BARRAGES & FORWARD SPOTTERS
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
  armmerl = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "artillery", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1400, scavsquadminanger = 30, scavsquadmaxanger = 130,
      scavsquadrarity = "basic", scavsquadunitsamount = 16, scavsquadweight = 110,
    },
    stealth = true,
  },
  corvroc = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "artillery", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1400, scavsquadminanger = 30, scavsquadmaxanger = 130,
      scavsquadrarity = "basic", scavsquadunitsamount = 16, scavsquadweight = 110,
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

  -- AIR CORPS (RECON, INTERCEPTORS, GUNSHIPS, BOMBERS)
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
  armliche = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1600, scavsquadminanger = 55, scavsquadmaxanger = 150,
      scavsquadrarity = "special", scavsquadunitsamount = 8, scavsquadweight = 120,
    },
  },
  corhurc = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "raider", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1600, scavsquadminanger = 45, scavsquadmaxanger = 150,
      scavsquadrarity = "basic", scavsquadunitsamount = 14, scavsquadweight = 120,
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

  -- NAVAL DOMINANCE (AMPHIBIOUS, DESTROYERS, CRUISERS, SUBMARINES)
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
  armroy = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1400, scavsquadminanger = 30, scavsquadmaxanger = 110,
      scavsquadrarity = "basic", scavsquadunitsamount = 12, scavsquadweight = 120,
    },
    stealth = true,
  },
  corroy = {
    customparams = {
      scavcustomsquad = "1", scavsquadbehavior = "berserk", scavsquadbehaviorchance = 1,
      scavsquadbehaviordistance = 1400, scavsquadminanger = 30, scavsquadmaxanger = 110,
      scavsquadrarity = "basic", scavsquadunitsamount = 12, scavsquadweight = 120,
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
}
