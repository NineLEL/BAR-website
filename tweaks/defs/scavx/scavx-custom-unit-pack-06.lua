-- Imported from https://github.com/PixelAlien0/ScavX
-- Original module: tweakdefs6
-- Verified release source: ScavX_Commands_SunlessK (1).txt
-- Decoded and restored from the ScavX project payload.
-- Description: Patches Basic and Advanced Metal Generators, Epic Construction
-- Turret, Sanctuary of All Sanctuary (500.5k shield power), Queen Tyrannus
-- (1.907M HP, 119.4k shield), Titaniator (1M HP, 30-unit raid wave), Walking
-- Fortress (2M HP), and Floating Wall-nut (912k HP).

do
	local editp_patches = {
		t1metalgenerator = {
			buildpic = "scavengers/armuwes.dds",
			buildtime = 2110,
			customparams = {
				i18n_cs_tooltip = "Produces 4 Metal (Best Used for Non Metal Map)",
				i18n_de_tooltip = "Produces 4 Metal (Best Used for Non Metal Map)",
				i18n_en_tooltip = "Produces 4 Metal (Best Used for Non Metal Map)",
				i18n_es_tooltip = "Produces 4 Metal (Best Used for Non Metal Map)",
				i18n_fr_tooltip = "Produces 4 Metal (Best Used for Non Metal Map)",
				i18n_hr_tooltip = "Produces 4 Metal (Best Used for Non Metal Map)",
				i18n_it_tooltip = "Produces 4 Metal (Best Used for Non Metal Map)",
				i18n_lt_tooltip = "Produces 4 Metal (Best Used for Non Metal Map)",
				i18n_ru_tooltip = "Produces 4 Metal (Best Used for Non Metal Map)",
				i18n_zh_tooltip = "Produces 4 Metal (Best Used for Non Metal Map)",
			},
			description = "Produces 4 Metal (Best Used for Non Metal Map)",
			energycost = 1900,
			energystorage = 25,
			icontype = "armmex",
			maxwaterdepth = 0,
			metalmake = 4,
			metalstorage = 25,
			minwaterdepth = -10000000,
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
		t2metalgenerator = {
			buildpic = "scavengers/leguwestore.dds",
			buildtime = 9260,
			customparams = {
				i18n_cs_tooltip = "Produces 10 Metal (Best Used for Non Metal Map)",
				i18n_de_tooltip = "Produces 10 Metal (Best Used for Non Metal Map)",
				i18n_en_tooltip = "Produces 10 Metal (Best Used for Non Metal Map)",
				i18n_es_tooltip = "Produces 10 Metal (Best Used for Non Metal Map)",
				i18n_fr_tooltip = "Produces 10 Metal (Best Used for Non Metal Map)",
				i18n_hr_tooltip = "Produces 10 Metal (Best Used for Non Metal Map)",
				i18n_it_tooltip = "Produces 10 Metal (Best Used for Non Metal Map)",
				i18n_lt_tooltip = "Produces 10 Metal (Best Used for Non Metal Map)",
				i18n_ru_tooltip = "Produces 10 Metal (Best Used for Non Metal Map)",
				i18n_zh_tooltip = "Produces 10 Metal (Best Used for Non Metal Map)",
			},
			description = "Produces 10 Metal (Best Used for Non Metal Map)",
			energycost = 8800,
			energystorage = 150,
			health = 5000,
			icontype = "armmoho",
			maxwaterdepth = 0,
			metalcost = 800,
			metalmake = 10,
			metalstorage = 150,
			minwaterdepth = -10000000,
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
		t3builder = {
			builddistance = 800,
			buildpic = "scavengers/armnanotcplat.dds",
			buildtime = 50000,
			customparams = { techlevel = 4 },
			energycost = 650000,
			energymake = 1000,
			energystorage = 15000,
			health = 60000,
			icontype = "legnanotcbase",
			metalcost = 30000,
			metalmake = 50,
			metalstorage = 5000,
			minwaterdepth = -10000000,
			workertime = 5000,
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
		t5sanctuary = {
			buildpic = "scavengers/corgatet3.dds",
			buildtime = 775000,
			customparams = {
				i18n_cs_tooltip = "The Ultimate Shield",
				i18n_de_tooltip = "The Ultimate Shield",
				i18n_en_tooltip = "The Ultimate Shield",
				i18n_es_tooltip = "The Ultimate Shield",
				i18n_fr_tooltip = "The Ultimate Shield",
				i18n_hr_tooltip = "The Ultimate Shield",
				i18n_it_tooltip = "The Ultimate Shield",
				i18n_lt_tooltip = "The Ultimate Shield",
				i18n_ru_tooltip = "The Ultimate Shield",
				i18n_zh_tooltip = "The Ultimate Shield",
				shield_power = 500500,
				shield_radius = 2325,
				techlevel = 4,
			},
			description = "The Ultimate Shield",
			energycost = 7075000,
			energymake = 30000,
			energystorage = 100000,
			health = 202500,
			icontype = "leggatet3",
			maxthisunit = 6,
			metalcost = 400000,
			metalmake = 1000,
			metalstorage = 100000,
			weapondefs = {
				repulsor = {
					shield = {
						force = 5.5,
						power = 500500,
						powerRegen = 5650,
						powerRegenEnergy = 9812.5,
						radius = 2325,
						startingPower = 100900,
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
		thetyrannus = {
			buildpic = "scavengers/legfortt4.dds",
			buildtime = 9000000,
			cruiseAltitude = 500,
			cruisealtitude = 500,
			customparams = {
				cruisealtitude = 500,
				scavcustomsquad = true,
				scavsquadbehavior = "berserk",
				scavsquadbehaviorchance = 1,
				scavsquadbehaviordistance = 1000,
				scavsquadmaxanger = 120,
				scavsquadminanger = 90,
				scavsquadrarity = "basic",
				scavsquadunitsamount = 10,
				scavsquadweight = 130,
				shield_power = 119400,
				shield_radius = 450,
			},
			energycost = 5090000,
			energymake = 1000000,
			health = 1907000,
			icontype = "armcomboss",
			metalcost = 1006000,
			speed = 32,
			stealth = true,
			weapondefs = {
				aa_missiles = { damage = { default = 2000, vtol = 2000 }, range = 1540 },
				corlevlr_weapon = {
					cegtag = "blood_explode_xl",
					damage = { default = 25000 },
					range = 2500,
					reloadtime = 2.5,
					weaponvelocity = 1500,
				},
				repulsor = {
					shield = { force = 3.5, power = 119400, powerRegen = 1100, radius = 450, startingPower = 31438 },
				},
				t2heatray = { damage = { default = 3000 }, range = 2000, reloadtime = 1 },
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
		titaniator = {
			buildpic = "scavengers/armbanth.dds",
			customparams = {
				scavcustomsquad = true,
				scavsquadbehavior = "raider",
				scavsquadbehaviorchance = 1,
				scavsquadbehaviordistance = 2000,
				scavsquadmaxanger = 100,
				scavsquadminanger = 85,
				scavsquadrarity = "basic",
				scavsquadunitsamount = 30,
				scavsquadweight = 130,
			},
			energycost = 2086000,
			health = 1000000,
			icontype = "armbanth",
			mass = 135000,
			metalcost = 185000,
			speed = 60.6,
			stealth = true,
			weapondefs = {
				armbantha_fire = { damage = { default = 3000 }, range = 700, reloadtime = 1 },
				bantha_rocket = { damage = { default = 1500 }, reloadtime = 4.86667 },
				tehlazerofdewm = { damage = { default = 15000 }, reloadtime = 5.5 },
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
		walkingfort = {
			buildtime = 201000,
			customparams = {
				scavcustomsquad = true,
				scavsquadbehavior = "artillery",
				scavsquadbehaviorchance = 1,
				scavsquadbehaviordistance = 1100,
				scavsquadmaxanger = 120,
				scavsquadminanger = 80,
				scavsquadrarity = "basic",
				scavsquadunitsamount = 10,
				scavsquadweight = 150,
				techlevel = 4,
			},
			energycost = 1001000,
			health = 2000000,
			icontype = "armcomboss",
			metalcost = 103000,
			speed = 12,
			stealth = true,
			weapondefs = {
				weapon = {
					areaofeffect = 550,
					avoidfriendly = false,
					collidefriendly = false,
					damage = { default = 9000 },
					range = 2000,
					reloadtime = 1,
					rgbcolor = "0.91 0.45 0.32",
					rgbcolor2 = "0.91 0.45 0.32",
					soundstart = "BERTHA1",
					weaponvelocity = 2500,
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
		wallnut = {
			buildtime = 450000,
			energycost = 2250000,
			health = 912000,
			icontype = "armfgate",
			metalcost = 75000,
			speed = 23.9,
			turnRate = 500,
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
