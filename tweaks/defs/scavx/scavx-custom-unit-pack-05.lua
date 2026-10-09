-- Imported from https://github.com/PixelAlien0/ScavX
-- Original module: tweakdefs5
-- Verified release source: ScavX_Commands_SunlessK (1).txt
-- Decoded and restored from the ScavX project payload.
-- Description: Patches Epic Sanctuary (126.5k shield, 8.65k regen), Epic
-- Wall (1.5M HP), Everything Experimental, Behemoth (535k HP), Fountain
-- (168k burst), King Chimera (1.575M HP), Multiplicable (2.003M HP),
-- Nukinator (24.5k nuke), Pulsinator (208k HP, 32k ATA damage), Quincy King
-- (2.228M HP, six-burst Vulcan), and King Ratte (183k HP).

do
	local editp_patches = {
		epicsanctuary = {
			buildpic = "scavengers/corgatet3.dds",
			buildtime = 575000,
			customparams = { shield_power = 126500, shield_radius = 1225, techlevel = 4 },
			energycost = 1075000,
			health = 62500,
			icontype = "leggatet3",
			metalcost = 80000,
			weapondefs = {
				repulsor = {
					shield = {
						force = 3.5,
						power = 126500,
						powerRegen = 8650,
						powerRegenEnergy = 5812.5,
						radius = 1225,
						startingPower = 70900,
					},
				},
			},
		},
	}
	local function editp_merge(target, patch)
		for key, value in pairs(patch) do
			if type(value) == "table" and type(target[key]) == "table" then
				editp_merge(target[key], value)
			else
				target[key] = value
			end
		end
	end
	for name, patch in pairs(editp_patches) do
		if UnitDefs[name] then
			editp_merge(UnitDefs[name], patch)
		end
	end
end
do
	local editp_patches = {
		epicwall = {
			autoheal = 200,
			buildtime = 3500,
			crushResistance = 100000,
			customparams = {
				i18n_cs_tooltip = "Good for funneling units (500 Max Units Per Player)",
				i18n_de_tooltip = "Good for funneling units (500 Max Units Per Player)",
				i18n_en_tooltip = "Good for funneling units (500 Max Units Per Player)",
				i18n_es_tooltip = "Good for funneling units (500 Max Units Per Player)",
				i18n_fr_tooltip = "Good for funneling units (500 Max Units Per Player)",
				i18n_hr_tooltip = "Good for funneling units (500 Max Units Per Player)",
				i18n_it_tooltip = "Good for funneling units (500 Max Units Per Player)",
				i18n_lt_tooltip = "Good for funneling units (500 Max Units Per Player)",
				i18n_ru_tooltip = "Good for funneling units (500 Max Units Per Player)",
				i18n_zh_tooltip = "Good for funneling units (500 Max Units Per Player)",
				techlevel = 3,
			},
			damageModifier = 0,
			description = "Good for funneling units (500 Max Units Per Player)",
			energycost = 5000,
			health = 1500000,
			icontype = "legforti",
			mass = 100000,
			maxthisunit = 500,
			metalcost = 500,
		},
	}
	local function editp_merge(target, patch)
		for key, value in pairs(patch) do
			if type(value) == "table" and type(target[key]) == "table" then
				editp_merge(target[key], value)
			else
				target[key] = value
			end
		end
	end
	for name, patch in pairs(editp_patches) do
		if UnitDefs[name] then
			editp_merge(UnitDefs[name], patch)
		end
	end
end
do
	local editp_patches = {
		everyexpe = {
			buildtime = 167300,
			energycost = 1006000,
			energymake = 3000,
			health = 90800,
			metalcost = 200900,
			metalmake = 50,
			workertime = 3000,
		},
	}
	local function editp_merge(target, patch)
		for key, value in pairs(patch) do
			if type(value) == "table" and type(target[key]) == "table" then
				editp_merge(target[key], value)
			else
				target[key] = value
			end
		end
	end
	for name, patch in pairs(editp_patches) do
		if UnitDefs[name] then
			editp_merge(UnitDefs[name], patch)
		end
	end
end
do
	local editp_patches = {
		fatherbehe = {
			collide = false,
			customparams = {
				scavcustomsquad = true,
				scavsquadbehavior = "berserk",
				scavsquadbehaviorchance = 1,
				scavsquadbehaviordistance = 2000,
				scavsquadmaxanger = 150,
				scavsquadminanger = 60,
				scavsquadrarity = "basic",
				scavsquadunitsamount = 15,
				scavsquadweight = 100,
			},
			health = 535000,
			icontype = "armafust3",
			mass = 500000,
			speed = 32.5,
			stealth = true,
			weapondefs = {
				ata = {
					corethickness = 0.7,
					damage = { default = 19000 },
					laserflaresize = 4,
					range = 1200,
					reloadtime = 2,
					rgbcolor = "0.22 0.58 0.29",
					thickness = 14,
				},
			},
		},
	}
	local function editp_merge(target, patch)
		for key, value in pairs(patch) do
			if type(value) == "table" and type(target[key]) == "table" then
				editp_merge(target[key], value)
			else
				target[key] = value
			end
		end
	end
	for name, patch in pairs(editp_patches) do
		if UnitDefs[name] then
			editp_merge(UnitDefs[name], patch)
		end
	end
end
do
	local editp_patches = {
		fountain = {
			buildpic = "scavengers/legcluster.dds",
			buildtime = 300400,
			customparams = {
				i18n_cs_tooltip = "Long Range Concentrated Cannon (Max Units 4 Per Player)",
				i18n_de_tooltip = "Long Range Concentrated Cannon (Max Units 4 Per Player)",
				i18n_en_tooltip = "Long Range Concentrated Cannon (Max Units 4 Per Player)",
				i18n_es_tooltip = "Long Range Concentrated Cannon (Max Units 4 Per Player)",
				i18n_fr_tooltip = "Long Range Concentrated Cannon (Max Units 4 Per Player)",
				i18n_hr_tooltip = "Long Range Concentrated Cannon (Max Units 4 Per Player)",
				i18n_it_tooltip = "Long Range Concentrated Cannon (Max Units 4 Per Player)",
				i18n_lt_tooltip = "Long Range Concentrated Cannon (Max Units 4 Per Player)",
				i18n_ru_tooltip = "Long Range Concentrated Cannon (Max Units 4 Per Player)",
				i18n_zh_tooltip = "Long Range Concentrated Cannon (Max Units 4 Per Player)",
				techlevel = 4,
			},
			description = "Long Range Concentrated Cannon (Max Units 4 Per Player)",
			energycost = 1000000,
			footprintx = 6,
			footprintz = 6,
			health = 150000,
			icontype = "armdecadet3",
			maxthisunit = 4,
			metalcost = 100000,
			weapondefs = {
				corlevlr_weapon = {
					accuracy = 0,
					avoidfriendly = false,
					burst = 6,
					cegtag = "burnblackbig",
					collidefriendly = false,
					customparams = { max_range_reduction = 0.1, speceffect = "sector_fire", spread_angle = 40 },
					damage = { default = 28000 },
					hightrajectory = 1,
					range = 2500,
					reloadtime = 3,
					weaponvelocity = 1200,
				},
			},
		},
	}
	local function editp_merge(target, patch)
		for key, value in pairs(patch) do
			if type(value) == "table" and type(target[key]) == "table" then
				editp_merge(target[key], value)
			else
				target[key] = value
			end
		end
	end
	for name, patch in pairs(editp_patches) do
		if UnitDefs[name] then
			editp_merge(UnitDefs[name], patch)
		end
	end
end
do
	local editp_patches = {
		kingchimera = {
			customparams = {
				i18n_cs_tooltip = "!!!",
				i18n_de_tooltip = "!!!",
				i18n_en_tooltip = "!!!",
				i18n_es_tooltip = "!!!",
				i18n_fr_tooltip = "!!!",
				i18n_hr_tooltip = "!!!",
				i18n_it_tooltip = "!!!",
				i18n_lt_tooltip = "!!!",
				i18n_ru_tooltip = "!!!",
				i18n_zh_tooltip = "!!!",
				scavcustomsquad = true,
				scavsquadbehavior = "berserk",
				scavsquadbehaviorchance = 1,
				scavsquadbehaviordistance = 1500,
				scavsquadmaxanger = 100,
				scavsquadminanger = 90,
				scavsquadrarity = "basic",
				scavsquadunitsamount = 2,
				scavsquadweight = 150,
				techlevel = 4,
			},
			description = "!!!",
			energycost = 8000000,
			health = 1575000,
			icontype = "raptor_queen_epic",
			metalcost = 5000000,
			stealth = true,
			weapondefs = {
				arm_bosscannon = {
					avoidfriendly = false,
					collidefriendly = false,
					customparams = { max_range_reduction = 0.25, speceffect = "sector_fire", spread_angle = 12 },
					damage = { default = 10200 },
					projectiles = 10,
					range = 2000,
					reloadtime = 0.7,
					rgbcolor = "0.79 0.63 0.86",
					rgbcolor2 = "0.79 0.63 0.86",
					weaponvelocity = 1250,
				},
				kmaw = {
					colormap = "0.95 1.0 1.0 0.032   0.45 0.88 0.95 0.028   0.20 0.50 0.75 0.024   0.08 0.12 0.16 0.035   0.0 0.0 0.0 0.01",
					damage = { default = 70 },
					range = 1000,
					rgbcolor = "0.79 0.63 0.86",
					rgbcolor2 = "0.79 0.63 0.86",
				},
				laser = {
					areaofeffect = 120,
					damage = { default = 8000 },
					range = 2000,
					reloadtime = 1,
					rgbcolor = "0.79 0.63 0.86",
					rgbcolor2 = "0.79 0.63 0.86",
				},
			},
		},
	}
	local function editp_merge(target, patch)
		for key, value in pairs(patch) do
			if type(value) == "table" and type(target[key]) == "table" then
				editp_merge(target[key], value)
			else
				target[key] = value
			end
		end
	end
	for name, patch in pairs(editp_patches) do
		if UnitDefs[name] then
			editp_merge(UnitDefs[name], patch)
		end
	end
end
do
	local editp_patches = {
		multiplicable = {
			buildpic = "scavengers/corgolt4.dds",
			buildtime = 1550000,
			customparams = {
				scavcustomsquad = true,
				scavsquadbehavior = "berserk",
				scavsquadbehaviorchance = 1,
				scavsquadbehaviordistance = 2000,
				scavsquadmaxanger = 100,
				scavsquadminanger = 80,
				scavsquadrarity = "basic",
				scavsquadunitsamount = 3,
				scavsquadweight = 80,
				techlevel = 4,
			},
			energycost = 2050000,
			health = 2003000,
			icontype = "armscavengerbossv2_hard",
			metalcost = 550000,
			sightdistance = 6000,
			speed = 12,
			stealth = true,
			weapondefs = {
				corgol_sidelaser = { damage = { default = 7250 }, range = 1075 },
				corlevlr_weapon = {
					avoidfriendly = false,
					cegtag = "cruisemissiletrail-tacnuke",
					collidefriendly = false,
					customparams = {
						carried_unit = "corves",
						carrierdeaththroe = "death",
						controlradius = 1000,
						dockingpieces = " ",
						docktohealthreshold = 25,
						droneammo = "0",
						droneminimumidleradius = 160,
						dronetype = "default",
						enabledocking = 0,
						energycost = "0",
						engagementrange = 1500,
						manualdrones = 1,
						maxunits = "10",
						metalcost = "0",
						spawnrate = 5,
						spawns_surface = "LAND",
						startingdronecount = "5",
					},
					damage = { default = 50000 },
					range = 1900,
					reloadtime = 3.5,
					weaponvelocity = 2250,
				},
			},
		},
	}
	local function editp_merge(target, patch)
		for key, value in pairs(patch) do
			if type(value) == "table" and type(target[key]) == "table" then
				editp_merge(target[key], value)
			else
				target[key] = value
			end
		end
	end
	for name, patch in pairs(editp_patches) do
		if UnitDefs[name] then
			editp_merge(UnitDefs[name], patch)
		end
	end
end
do
	local editp_patches = {
		nukinator = {
			buildpic = "scavengers/legsrailt4.dds",
			buildtime = 500000,
			customparams = {
				scavcustomsquad = true,
				scavsquadbehavior = "raider",
				scavsquadbehaviorchance = 1,
				scavsquadbehaviordistance = 2000,
				scavsquadmaxanger = 100,
				scavsquadminanger = 90,
				scavsquadrarity = "special",
				scavsquadunitsamount = 2,
				scavsquadweight = 150,
			},
			energycost = 5000000,
			health = 200000,
			icontype = "legsrailt4",
			metalcost = 505000,
			sightdistance = 7000,
			stealth = true,
			weapondefs = {
				legicbm = {
					areaofeffect = 320,
					avoidfriendly = false,
					cegtag = "heatcloud-rot-purple",
					collidefriendly = false,
					damage = { default = 24500 },
					fixedlauncher = true,
					range = 3000,
					reloadtime = 5,
					soundstart = "cannhvy3",
					stockpile = false,
					weaponacceleration = 1000,
					weapontimer = 0,
					weaponvelocity = 4600,
				},
			},
		},
	}
	local function editp_merge(target, patch)
		for key, value in pairs(patch) do
			if type(value) == "table" and type(target[key]) == "table" then
				editp_merge(target[key], value)
			else
				target[key] = value
			end
		end
	end
	for name, patch in pairs(editp_patches) do
		if UnitDefs[name] then
			editp_merge(UnitDefs[name], patch)
		end
	end
end
do
	local editp_patches = {
		pulsinator = {
			buildpic = "scavengers/armannit3.dds",
			buildtime = 230000,
			energycost = 950000,
			health = 208000,
			icontype = "armannit3",
			metalcost = 53500,
			weapondefs = {
				ata = {
					avoidfriendly = false,
					beamtime = 0.8,
					collidefriendly = false,
					corethickness = 0.6,
					damage = { default = 32000 },
					laserflaresize = 2,
					range = 2100,
					reloadtime = 0.2,
					rgbcolor = "0.82 0.35 0.50",
					rgbcolor2 = "0.35 0.82 0.67",
					soundstart = "bimpact3",
					texture1 = "railguntrail",
					texture3 = "railguntrail",
					thickness = 8,
					tilelength = 90,
				},
			},
			weapons = { [1] = { fastautoretargeting = true } },
		},
	}
	local function editp_merge(target, patch)
		for key, value in pairs(patch) do
			if type(value) == "table" and type(target[key]) == "table" then
				editp_merge(target[key], value)
			else
				target[key] = value
			end
		end
	end
	for name, patch in pairs(editp_patches) do
		if UnitDefs[name] then
			editp_merge(UnitDefs[name], patch)
		end
	end
end
do
	local editp_patches = {
		quincy = {
			customparams = {
				scavcustomsquad = true,
				scavsquadbehavior = "artillery",
				scavsquadbehaviorchance = 1,
				scavsquadbehaviordistance = 1100,
				scavsquadmaxanger = 100,
				scavsquadminanger = 80,
				scavsquadrarity = "basic",
				scavsquadunitsamount = 20,
				scavsquadweight = 150,
			},
			energycost = 4005000,
			health = 2228000,
			icontype = "corafus",
			mass = 500000,
			metalcost = 750000,
			speed = 46,
			stealth = true,
			weapondefs = {
				armminivulc_weapon = {
					avoidfriendly = false,
					burst = 6,
					burstrate = 0,
					cegtag = "juno-damage",
					collidefriendly = false,
					customparams = { max_range_reduction = 0.1, speceffect = "sector_fire", spread_angle = 50 },
					damage = { default = 3000 },
					range = 2100,
					reloadtime = 3,
					stockpile = false,
					weaponvelocity = 1160,
				},
			},
		},
	}
	local function editp_merge(target, patch)
		for key, value in pairs(patch) do
			if type(value) == "table" and type(target[key]) == "table" then
				editp_merge(target[key], value)
			else
				target[key] = value
			end
		end
	end
	for name, patch in pairs(editp_patches) do
		if UnitDefs[name] then
			editp_merge(UnitDefs[name], patch)
		end
	end
end
do
	local editp_patches = {
		ratteking = {
			customparams = {
				scavcustomsquad = true,
				scavsquadbehavior = "berserk",
				scavsquadbehaviorchance = 1,
				scavsquadbehaviordistance = 800,
				scavsquadmaxanger = 100,
				scavsquadminanger = 80,
				scavsquadrarity = "basic",
				scavsquadunitsamount = 2,
				scavsquadweight = 100,
			},
			energycost = 2100000,
			health = 183000,
			icontype = "armrattet4",
			metalcost = 500000,
			speed = 21,
			stealth = true,
			weapondefs = {
				arm_bosscannon = {
					areaofeffect = 392,
					avoidfriendly = false,
					cegtag = "genericbuildingexplosion-wind-purple",
					collidefriendly = false,
					damage = { default = 5200 },
					projectiles = 9,
					range = 1500,
					reloadtime = 0.8,
					weaponvelocity = 850,
				},
			},
		},
	}
	local function editp_merge(target, patch)
		for key, value in pairs(patch) do
			if type(value) == "table" and type(target[key]) == "table" then
				editp_merge(target[key], value)
			else
				target[key] = value
			end
		end
	end
	for name, patch in pairs(editp_patches) do
		if UnitDefs[name] then
			editp_merge(UnitDefs[name], patch)
		end
	end
end
