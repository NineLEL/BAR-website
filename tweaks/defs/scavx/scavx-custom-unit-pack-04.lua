-- Imported from https://github.com/PixelAlien0/ScavX
-- Original module: tweakdefs4
-- Verified release source: ScavX_Commands_SunlessK (1).txt
-- Decoded and restored from the ScavX project payload.
-- Description: Installs high-tier nano-turret death profiles and patches
-- Buster (150k HP, cloak), Decimator (32 max cap, 60k LRPC), Epic Xyston,
-- Epic Bastion (550-damage heatray), Epic Basilica, Basiliscia F3, Epic
-- Beamer, Epic Mini Ragnarok, Epic Olympus, and Epic Pluto.

-- EDITP_DEATH_PROFILES_BEGIN
local editp_profiles = {
	advmetalmaker = {
		areaofeffect = 320,
		camerashake = 320,
		customparams = { unitexplosion = 1 },
		damage = { commanders = 1000, default = 1220 },
		explosiongenerator = "custom:genericbuildingexplosion-advmetalmaker",
		impulsefactor = 0.123,
		soundhit = "xplolrg4",
		soundstart = "largegun",
	},
}
local function editp_copy_table(value)
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, child in pairs(value) do
		copy[key] = editp_copy_table(child)
	end
	return copy
end
local function editp_death_profile(unit_name, kind, source, patch)
	local unit = UnitDefs and UnitDefs[unit_name]
	if not unit or type(source) ~= "table" then
		return
	end
	local profile_name = "editp_" .. kind
	local profile = editp_copy_table(source)
	if patch.damage ~= nil then
		profile.damage = profile.damage or {}
		profile.damage.default = patch.damage
	end
	if patch.aoe ~= nil then
		profile.areaofeffect = patch.aoe
	end
	if patch.camerashake ~= nil then
		profile.camerashake = patch.camerashake
	end
	if patch.impulsefactor ~= nil then
		profile.impulsefactor = patch.impulsefactor
	end
	unit.weapondefs = unit.weapondefs or {}
	unit.weapondefs[profile_name] = profile
	unit[kind == "death" and "explodeas" or "selfdestructas"] = profile_name
end
editp_death_profile(
	"armnanotct2",
	"death",
	editp_profiles["advmetalmaker"],
	{ damage = 0, aoe = 0, camerashake = 0, impulsefactor = 0 }
)
editp_death_profile(
	"cornanotct2",
	"death",
	editp_profiles["advmetalmaker"],
	{ damage = 0, aoe = 0, camerashake = 0, impulsefactor = 0 }
)
editp_death_profile(
	"legnanotct2",
	"death",
	editp_profiles["advmetalmaker"],
	{ damage = 0, aoe = 0, camerashake = 0, impulsefactor = 0 }
)
do
	local editp_patches = {
		busters = {
			buildpic = "scavengers/legkeres.dds",
			buildtime = 160000,
			canCloak = true,
			customparams = {
				scavcustomsquad = true,
				scavsquadbehavior = "berserk",
				scavsquadbehaviorchance = 1,
				scavsquadbehaviordistance = 1000,
				scavsquadmaxanger = 140,
				scavsquadminanger = 60,
				scavsquadrarity = "basic",
				scavsquadunitsamount = 20,
				scavsquadweight = 100,
			},
			energycost = 800000,
			health = 150000,
			icontype = "legkeres",
			initCloaked = true,
			mass = 50000,
			metalcost = 50000,
			speed = 55,
			stealth = true,
			weapondefs = {
				legkeres_cannon = {
					avoidfriendly = false,
					cegtag = "flakshard",
					collidefriendly = false,
					damage = { default = 3000, shields = 2000 },
					range = 1500,
					reloadtime = 1,
					weaponvelocity = 1000,
				},
				t2heatray = {
					damage = { default = 500 },
					laserflaresize = 8,
					reloadtime = 1,
					rgbcolor = "0.44 0.16 0.39",
					rgbcolor2 = "0.46 0.38 0.52",
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
		decimator = {
			buildpic = "scavengers/corbuzz.dds",
			buildtime = 2400000,
			customparams = {
				i18n_cs_tooltip = "The Ultimate Ground Defense (32 Max)",
				i18n_de_tooltip = "The Ultimate Ground Defense (32 Max)",
				i18n_en_tooltip = "The Ultimate Ground Defense (32 Max)",
				i18n_es_tooltip = "The Ultimate Ground Defense (32 Max)",
				i18n_fr_tooltip = "The Ultimate Ground Defense (32 Max)",
				i18n_hr_tooltip = "The Ultimate Ground Defense (32 Max)",
				i18n_it_tooltip = "The Ultimate Ground Defense (32 Max)",
				i18n_lt_tooltip = "The Ultimate Ground Defense (32 Max)",
				i18n_ru_tooltip = "The Ultimate Ground Defense (32 Max)",
				i18n_zh_tooltip = "The Ultimate Ground Defense (32 Max)",
				techlevel = 4,
			},
			description = "The Ultimate Ground Defense (32 Max)",
			energycost = 5000000,
			footprintx = 6,
			footprintz = 6,
			health = 303500,
			icontype = "corbuzz",
			maxthisunit = 32,
			metalcost = 500000,
			turnRate = 1000,
			weapondefs = {
				rflrpc = {
					accuracy = 0,
					areaofeffect = 300,
					avoidfriendly = false,
					collidefriendly = false,
					corethickness = 20,
					damage = { default = 60000, shields = 40000 },
					reloadtime = 1,
					rgbcolor = "0.46 0.38 0.52",
					rgbcolor2 = "0.46 0.38 0.52",
					weaponvelocity = 4150,
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
		epicantiair2 = {
			buildpic = "scavengers/leglraa.dds",
			buildtime = 208000,
			customparams = { techlevel = 4 },
			energycost = 1536000,
			health = 108670,
			icontype = "armfflak",
			metalcost = 200000,
			weapondefs = {
				arm_advsam = {
					areaofeffect = 30,
					avoidfriendly = false,
					burnblow = true,
					cegtag = "railgun",
					collidefriendly = false,
					customparams = { speceffect = "retarget" },
					damage = { default = 40000, vtol = 80000 },
					dance = 1,
					explosiongenerator = "custom:blank",
					flighttime = 4.2,
					range = 3000,
					reloadtime = 0.9,
					startvelocity = 1700,
					stockpile = false,
					tracks = true,
					trajectoryheight = 0.8,
					weaponacceleration = 1500,
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
		epicbas = {
			blocking = true,
			buildpic = "scavengers/legbastion.dds",
			buildtime = 120000,
			canSelfDestruct = true,
			customparams = {
				avoidfriendly = false,
				collidefriendly = false,
				i18n_cs_tooltip = "Heavy Concentrated Energy Beamer",
				i18n_de_tooltip = "Heavy Concentrated Energy Beamer",
				i18n_en_tooltip = "Heavy Concentrated Energy Beamer",
				i18n_es_tooltip = "Heavy Concentrated Energy Beamer",
				i18n_fr_tooltip = "Heavy Concentrated Energy Beamer",
				i18n_hr_tooltip = "Heavy Concentrated Energy Beamer",
				i18n_it_tooltip = "Heavy Concentrated Energy Beamer",
				i18n_lt_tooltip = "Heavy Concentrated Energy Beamer",
				i18n_ru_tooltip = "Heavy Concentrated Energy Beamer",
				i18n_zh_tooltip = "Heavy Concentrated Energy Beamer",
				techlevel = 4,
				unitgroup = "weapon",
			},
			description = "Heavy Concentrated Energy Beamer",
			energycost = 455000,
			energymake = 0,
			energystorage = 5000,
			explodeAs = "largeBuildingexplosiongeneric",
			footprintx = 6,
			footprintz = 6,
			health = 150000,
			icontype = "legbastion",
			maxwaterdepth = 0,
			metalcost = 21000,
			metalmake = 0,
			metalstorage = 0,
			radardistance = 1300,
			selfDestructAs = "largeBuildingExplosionGenericSelfd",
			selfDestructCountdown = 5,
			weapondefs = {
				t2heatray = {
					avoidfriendly = false,
					beamtime = 0.3,
					camerashake = 0.2,
					collidefriendly = false,
					damage = { default = 550 },
					energypershot = 400,
					range = 1700,
					reloadtime = 0.1,
					rgbcolor = "0.53 0.64 0.52",
					rgbcolor2 = "0.64 0.52 0.64",
					soundstart = "heatray3burn",
					thickness = 4.5,
				},
			},
			weapons = {
				[1] = {
					fastautoretargeting = true,
					onlytargetcategory = "SURFACE UNDERWATER SUB SHIP HOVER LAND FLOAT SWIM IMMOBILE",
				},
			},
			yardmap = "oooooo oooooo oooooo oooooo oooooo oooooo",
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
		epicbasilica = {
			buildpic = "scavengers/armbrtha.dds",
			buildtime = 420000,
			customparams = { techlevel = 4 },
			energycost = 954000,
			health = 170000,
			icontype = "armbrtha",
			metalcost = 50500,
			weapondefs = {
				weapon = {
					avoidfriendly = false,
					cegtag = "volcano_rock_trail",
					collidefriendly = false,
					damage = { default = 5000, scavboss = 4500, shields = 3800 },
					range = 2600,
					reloadtime = 0.8,
					soundstart = "banthstep",
					tolerance = 10000,
					weaponacceleration = 2100,
					weaponvelocity = 3000,
				},
			},
			weapons = { [1] = { onlytargetcategory = "SURFACE UNDERWATER SUB SHIP HOVER LAND FLOAT SWIM IMMOBILE" } },
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
		epicbasilicaair = {
			buildpic = "scavengers/armbrtha.dds",
			buildtime = 720000,
			customparams = { techlevel = 4 },
			energycost = 1254000,
			health = 170000,
			icontype = "armbrtha",
			metalcost = 100500,
			weapondefs = {
				weapon = {
					avoidfriendly = false,
					cegtag = "blood_trail_xl",
					collidefriendly = false,
					damage = { default = 5000, scavboss = 4500, shields = 3800, vtol = 6000 },
					range = 2900,
					reloadtime = 0.5,
					soundstart = "banthstep",
					weaponacceleration = 2100,
					weaponvelocity = 3500,
				},
			},
			weapons = { [1] = { onlytargetcategory = "VTOL" } },
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
		epicbeamer = {
			buildpic = "scavengers/armbeamer.dds",
			buildtime = 22800,
			customparams = { techlevel = 3 },
			energycost = 300000,
			health = 52430,
			icontype = "armbeamer",
			metalcost = 12000,
			weapondefs = {
				armbeamer_weapon = {
					avoidfriendly = false,
					collidefriendly = false,
					corethickness = 0.333,
					damage = { default = 190 },
					laserflaresize = 10.35,
					range = 1400,
					reloadtime = 0.1,
					rgbcolor = "0.79 0.63 0.86",
					thickness = 2.6,
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
		epicminiragna = {
			buildpic = "scavengers/armminivulc.dds",
			buildtime = 115000,
			customparams = { techlevel = 3 },
			energycost = 450000,
			health = 50700,
			icontype = "corminibuzz",
			metalcost = 25000,
			weapondefs = {
				armminivulc_weapon = {
					accuracy = 0,
					avoidfriendly = false,
					collidefriendly = false,
					damage = { default = 7000, scavboss = 1000, shields = 800 },
					range = 1500,
					reloadtime = 0.5,
					rgbcolor = "0.95 0.70 0.77",
					weaponvelocity = 2000,
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
		epicoly = {
			buildpic = "scavengers/leglrpc.dds",
			buildtime = 420000,
			customparams = { techlevel = 3 },
			energycost = 965000,
			health = 95000,
			icontype = "armvulc",
			metalcost = 59000,
			weapondefs = {
				lrpc = {
					accuracy = 100,
					avoidfriendly = false,
					cegtag = "arty-heavy-purple",
					collidefriendly = false,
					customparams = { max_range_reduction = 0.1, speceffect = "sector_fire", spread_angle = 5 },
					damage = { default = 4700 },
					projectiles = 6,
					range = 4850,
					reloadtime = 2,
					rgbcolor = "0.00 0.25 1.00",
					rgbcolor2 = "1.00 0.75 0.00",
					stockpile = false,
					weaponvelocity = 2100,
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
		epicpluto = {
			buildpic = "scavengers/legflak.dds",
			buildtime = 29000,
			customparams = { techlevel = 3 },
			energycost = 1000000,
			health = 40050,
			icontype = "leglupara",
			metalcost = 70020,
			weapondefs = {
				leg_t2_microflak = {
					accuracy = 500,
					avoidfriendly = false,
					collidefriendly = false,
					damage = { default = 800, vtol = 1000 },
					range = 1800,
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
