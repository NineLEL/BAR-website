-- Combined T3/T4 economy, advanced fusion, and construction-turret pack.
do
	local U = UnitDefs or {}
	local factions = {
		{ "arm", "Armada" },
		{ "cor", "Cortex" },
		{ "leg", "Legion" },
	}
	local languages = { "en", "de", "fr", "es", "it", "ru", "zh", "cs", "hr", "lt" }
	local builders = {
		arm = { "armack", "armacv", "armaca" },
		cor = { "corack", "coracv", "coraca" },
		leg = { "legack", "legacv", "legaca" },
	}
	local constructionTurretBases = {
		arm = "armrespawn",
		cor = "correspawn",
		leg = "legnanotcbase",
	}
	local subs = { arm = "armacsub", cor = "coracsub", leg = "legacsub" }

	local function copy(value)
		if type(value) ~= "table" then
			return value
		end
		local result = {}
		for key, child in pairs(value) do
			result[copy(key)] = copy(child)
		end
		return result
	end
	local function add(builderName, unitName)
		local builder, unit = U[builderName], U[unitName]
		if not (builder and unit) then
			return
		end
		builder.buildoptions = builder.buildoptions or {}
		for _, current in ipairs(builder.buildoptions) do
			if current == unitName then
				return
			end
		end
		builder.buildoptions[#builder.buildoptions + 1] = unitName
	end
	local function publish(name, unit)
		U[name] = unit
		if UnitDefNames then
			UnitDefNames[name] = unit
		end
	end
	local function localized(unit, name, tooltip)
		unit.customparams = unit.customparams or {}
		for _, language in ipairs(languages) do
			unit.customparams["i18n_" .. language .. "_humanname"] = name
			unit.customparams["i18n_" .. language .. "_tooltip"] = tooltip
		end
	end
	local function round(value)
		return math.floor(value + 0.5)
	end
	local function scaled(value, factor)
		return value and math.ceil(value * factor) or nil
	end

	-- Converter Specs:
	-- Base Epic (reference): 6,000 E -> 120 M (ratio 50.0:1) @ 9,000 M / 550,000 E
	-- Legendary (T3):       16,000 E -> 360 M (ratio 44.4:1) @ 15,000 M / 750,000 E
	-- Ultra (T4):           48,000 E -> 1,200 M (ratio 40.0:1) @ 32,000 M / 1,600,000 E
	-- Format: { unitName, sourceUnit, faction, techLevel, energyCap, efficiency, metalCost, energyCost, buildTime, health }
	local converterSpecs = {
		-- Legendary (T3)
		{ "armmmkr_t3", "armmmkr", "arm", 3, 16000, 0.0225000000, 14200, 720000, 460000, 12000 },
		{ "cormmkr_t3", "cormmkr", "cor", 3, 16000, 0.0225000000, 15000, 750000, 480000, 13500 },
		{ "legadveconv_t3", "legadveconv", "leg", 3, 16000, 0.0225000000, 15000, 750000, 480000, 13500 },

		-- Ultra (T4)
		{ "armmmkr_t4", "armmmkr", "arm", 4, 48000, 0.0250000000, 30500, 1550000, 860000, 28000 },
		{ "cormmkr_t4", "cormmkr", "cor", 4, 48000, 0.0250000000, 32000, 1600000, 900000, 32000 },
		{ "legadveconv_t4", "legadveconv", "leg", 4, 48000, 0.0250000000, 32000, 1600000, 900000, 32000 },
	}

	for _, sp in ipairs(converterSpecs) do
		local source = U[sp[2]]
		if source then
			local rank = sp[4] == 3 and "Legendary" or "Ultra"
			local name = rank .. " Energy Converter"
			local unit = copy(source)
			unit.unitname, unit.name = sp[1], name
			unit.description = name
			unit.metalcost, unit.energycost, unit.buildtime, unit.health = sp[7], sp[8], sp[9], sp[10]
			unit.activatewhenbuilt, unit.onoffable = true, true
			unit.weapondefs = unit.weapondefs or {}
			unit.customparams = unit.customparams or {}
			unit.customparams.techlevel = sp[4]
			unit.customparams.energyconv_capacity = sp[5]
			unit.customparams.energyconv_efficiency = sp[6]
			localized(
				unit,
				name,
				("Converts %d energy into %d metal per sec. Explodes violently."):format(sp[5], round(sp[5] * sp[6]))
			)
			publish(sp[1], unit)
			for _, builderName in ipairs(builders[sp[3]]) do
				add(builderName, sp[1])
			end
		end
	end

	local mexSpecs = {
		{ "armmoho_t3", "armmoho", "arm", 3, 0.008, 8, 90, 1200, 4500, 60000, 52000, 7500 },
		{ "cormoho_t3", "cormoho", "cor", 3, 0.008, 8, 90, 1200, 5200, 78000, 58000, 9500 },
		{ "legmoho_t3", "legmoho", "leg", 3, 0.008, 8, 90, 1200, 5200, 78000, 58000, 9500 },
		{ "armmoho_t4", "armmoho", "arm", 4, 0.016, 16, 240, 2000, 16000, 270000, 180000, 17000 },
		{ "cormoho_t4", "cormoho", "cor", 4, 0.016, 16, 240, 2000, 18500, 320000, 200000, 20000 },
		{ "legmoho_t4", "legmoho", "leg", 4, 0.016, 16, 240, 2000, 18500, 320000, 200000, 20000 },
	}
	for _, sp in ipairs(mexSpecs) do
		local source = U[sp[2]]
		if source then
			local rank = sp[4] == 3 and "Epic" or "Legendary"
			local name = rank .. " Metal Extractor"
			local unit = copy(source)
			unit.unitname, unit.name, unit.description = sp[1], name, name
			unit.extractsmetal, unit.makesmetal, unit.energyupkeep = sp[5], sp[6], sp[7]
			unit.metalstorage, unit.metalcost, unit.energycost = sp[8], sp[9], sp[10]
			unit.buildtime, unit.health = sp[11], sp[12]
			unit.activatewhenbuilt, unit.onoffable = true, true
			unit.weapondefs = unit.weapondefs or {}
			unit.customparams = unit.customparams or {}
			unit.customparams.techlevel, unit.customparams.metal_extractor = sp[4], sp[6]
			unit.customparams.standardextractor = true
			localized(
				unit,
				name,
				("Produces %d metal, upkeep %dE, storage %d. Explodes violently if destroyed."):format(
					sp[6],
					sp[7],
					sp[8]
				)
			)
			publish(sp[1], unit)
			for _, builderName in ipairs(builders[sp[3]]) do
				add(builderName, sp[1])
			end
		end
	end

	local storageSpecs = {
		{ "armuwadvmst3", "armuwadvms", "arm", "m", 3, 40000, 4800, 80000, 120000, 52000 },
		{ "coruwadvmst3", "coruwadvms", "cor", "m", 3, 40000, 5300, 90000, 128000, 56000 },
		{ "legamstort3", "legamstor", "leg", "m", 3, 40000, 5300, 90000, 128000, 56000 },
		{ "armuwadvmst4", "armuwadvms", "arm", "m", 4, 160000, 19000, 340000, 480000, 195000 },
		{ "coruwadvmst4", "coruwadvms", "cor", "m", 4, 160000, 21500, 390000, 520000, 225000 },
		{ "legamstort4", "legamstor", "leg", "m", 4, 160000, 21500, 390000, 520000, 225000 },
		{ "armuwadvest3", "armuwadves", "arm", "e", 3, 250000, 5200, 95000, 120000, 52000 },
		{ "coruwadvest3", "coruwadves", "cor", "e", 3, 250000, 5700, 105000, 128000, 56000 },
		{ "legadvestoret3", "legadvestore", "leg", "e", 3, 250000, 5700, 105000, 128000, 56000 },
		{ "armuwadvest4", "armuwadves", "arm", "e", 4, 1500000, 20500, 470000, 480000, 195000 },
		{ "coruwadvest4", "coruwadves", "cor", "e", 4, 1500000, 23000, 530000, 520000, 225000 },
		{ "legadvestoret4", "legadvestore", "leg", "e", 4, 1500000, 23000, 530000, 520000, 225000 },
	}
	for _, sp in ipairs(storageSpecs) do
		local source = U[sp[2]]
		if source then
			local resource = sp[4] == "m" and "Metal" or "Energy"
			local rank = sp[5] == 3 and "Epic" or "Legendary"
			local name = rank .. " " .. resource .. " Storage"
			local unit = copy(source)
			unit.unitname, unit.name, unit.description = sp[1], name, name
			if sp[4] == "m" then
				unit.metalstorage, unit.energystorage = sp[6], 0
			else
				unit.energystorage, unit.metalstorage = sp[6], 0
			end
			unit.metalcost, unit.energycost, unit.buildtime, unit.health = sp[7], sp[8], sp[9], sp[10]
			unit.techlevel = sp[5]
			unit.weapondefs = unit.weapondefs or {}
			unit.customparams = unit.customparams or {}
			unit.customparams.techlevel = sp[5]
			localized(
				unit,
				name,
				(
					rank
					.. " "
					.. resource
					.. " storage adds %d capacity. Explodes "
					.. (sp[5] == 3 and "violently" or "catastrophically")
					.. " if destroyed."
				):format(sp[6])
			)
			publish(sp[1], unit)
			for _, builderName in ipairs(builders[sp[3]]) do
				add(builderName, sp[1])
			end
			local sub = subs[sp[3]]
			if sub and unit.maxwaterdepth ~= nil then
				add(sub, sp[1])
			end
		end
	end

	-- T3 advanced fusions are native BAR units; add their builder options and
	-- create matching Legendary T4 variants.
	for _, faction in ipairs(factions) do
		local prefix = faction[1]
		local sourceName, targetName = prefix .. "afust3", prefix .. "afust4"
		local source = U[sourceName]
		if source then
			for _, builderName in ipairs(builders[prefix]) do
				add(builderName, sourceName)
			end
			local unit = copy(source)
			local energyMake = scaled(source.energymake, 2) or 0
			local name = "Legendary Fusion Reactor"
			unit.unitname, unit.name, unit.description = targetName, name, name
			unit.buildtime, unit.metalcost, unit.energycost =
				scaled(source.buildtime, 2.2), scaled(source.metalcost, 2.2), scaled(source.energycost, 2.2)
			unit.energymake, unit.energystorage = energyMake, scaled(source.energystorage, 5)
			unit.health, unit.idleautoheal = scaled(source.health, 5.5), scaled(source.idleautoheal, 6)
			unit.damagemodifier, unit.footprintx, unit.footprintz = 0.95, 12, 12
			localized(unit, name, ("Produces %d Energy. Catastrophic if destroyed."):format(energyMake))
			publish(targetName, unit)
			for _, builderName in ipairs(builders[prefix]) do
				add(builderName, targetName)
			end
		end
	end

	local function ensureOption(builderName, unitName)
		add(builderName, unitName)
	end
	local function removeOption(builderName, unitName)
		local builder = U[builderName]
		if not (builder and builder.buildoptions) then
			return
		end
		for i = #builder.buildoptions, 1, -1 do
			if builder.buildoptions[i] == unitName then
				table.remove(builder.buildoptions, i)
			end
		end
	end
	local turretOptions = {
		"player_hailstorm",
		"player_needleswarm",
		"player_blackoutcascade",
		"player_phalanxlance",
		"player_quakedoom",
		"player_nullcathedral",
		"player_hivearray",
		"player_aegiseraser",
		"player_executioner",
		"player_prismcathedral",
		"player_hyperionlance",
		"player_starfallcataclysm",
		"player_streamarty",
		"player_holybeam",
		"player_aegisstarspire",
		"player_thornnest",
		"player_mirrorarray",
		"player_voidvortex",
		"player_infernocrucible",
		"player_cascademortar",
		"armshltx",
		"corgant",
		"leggant",
		"armapt3",
		"corapt3",
		"legapt3",
		"armalab",
		"coralab",
		"legalab",
		"armvp",
		"corvp",
		"legvp",
		"armaap",
		"coraap",
		"legaap",
		"armgate",
		"corgate",
		"legdeflector",
		"armgatet3",
		"corgatet3",
		"leggatet3",
		"armfgate",
		"corfgate",
		"player_aegisdome",
		"player_citadelumbrella",
	}
	local factionDefenseOptions = {
		arm = {
			"armamb",
			"armpb",
			"armanni",
			"armflak",
			"armmercury",
			"armemp",
			"armamd",
			"armsilo",
			"armbrtha",
			"armvulc",
			"armdf",
		},
		cor = {
			"cortoast",
			"corvipe",
			"cordoom",
			"corflak",
			"corscreamer",
			"cortron",
			"corfmd",
			"corsilo",
			"corint",
			"corbuzz",
		},
		leg = {
			"legacluster",
			"legapopupdef",
			"legbastion",
			"legflak",
			"leglraa",
			"legperdition",
			"legabm",
			"legsilo",
			"leglrpc",
			"legstarfall",
		},
	}
	for _, faction in ipairs(factions) do
		local prefix = faction[1]
		local t3Name, t4Name = prefix .. "nanotct3", prefix .. "nanotct4"
		local t3, t4 = U[t3Name], U[t4Name]
		local base = U[constructionTurretBases[prefix]]
		if base then
			t3, t4 = copy(base), copy(base)
		elseif not t3 then
			local source = U[prefix .. "nanotct2"]
			if source then
				t3 = copy(source)
			end
		end
		if t3 then
			t3.disabled = false
			t3.metalcost, t3.energycost, t3.buildtime = 3700, 62000, 108000
			t3.footprintx, t3.footprintz, t3.collisionvolumescales = 8, 8, "82 150 82"
		end
		if t3 then
			t3.health, t3.maxdamage, t3.workertime, t3.builddistance = 10560, 10560, 2400, 750
			local name = "Epic Construction Turret"
			t3.unitname, t3.name, t3.description = t3Name, name, name
			localized(t3, name, t3.description)
			publish(t3Name, t3)
		end
		if not t4 and t3 then
			t4 = copy(t3)
		end
		if t4 then
			t4.unitname = t4Name
			if t3 then
				t4.metalcost = math.ceil((tonumber(t3.metalcost) or 3700) * 3)
				t4.energycost = math.ceil((tonumber(t3.energycost) or 62000) * 3)
				t4.buildtime = math.ceil((tonumber(t3.buildtime) or 108000) * 3)
				t4.footprintx, t4.footprintz, t4.collisionvolumescales = 10, 10, "104 180 104"
			end
		end
		if t4 then
			t4.disabled = false
			t4.health, t4.maxdamage, t4.workertime, t4.builddistance = 26400, 26400, 4000, 900
			local name = "Legendary Construction Turret"
			t4.unitname, t4.name, t4.description = t4Name, name, name
			localized(t4, name, t4.description)
			publish(t4Name, t4)
		end
		for _, builderName in ipairs(builders[prefix]) do
			ensureOption(builderName, t3Name)
			removeOption(builderName, t4Name)
		end
		if t3 then
			ensureOption(t3Name, t3Name)
			for _, optionName in ipairs(turretOptions) do
				ensureOption(t3Name, optionName)
			end
			for _, optionName in ipairs(factionDefenseOptions[prefix]) do
				ensureOption(t3Name, optionName)
				ensureOption(t4Name, optionName)
			end
			ensureOption(t3Name, t4Name)
		end
	end

	local effect = "custom:genericbuildingexplosion-"
	local large, huge, gigantic = effect .. "large", effect .. "huge", effect .. "gigantic"
	local nuke, big, medium = "xplonuk3", "xplolrg3", "xplomed1"
	local B = {
		c = {
			{ { 1200, 600, huge, 18000, 0, nuke }, { 2000, 1000, gigantic, 65000, 0, nuke } },
			{ { 2400, 1200, gigantic, 90000, 0, nuke }, { 3600, 1800, gigantic, 240000, 0, nuke } },
		},
		x = {
			{ { 600, 300, large, 3000, 0, medium }, { 900, 450, huge, 9000, 0, big } },
			{ { 1200, 600, huge, 25000, 0, big }, { 2000, 1000, gigantic, 90000, 0, nuke } },
		},
		m = {
			{ { 720, 360, large, 2200, 0, medium }, { 1200, 600, huge, 10000, 0, big } },
			{ { 1500, 750, huge, 30000, 0, big }, { 2300, 1150, gigantic, 90000, 0, nuke } },
		},
		e = {
			{ { 1200, 600, huge, 20000, 9000, nuke }, { 2000, 1000, gigantic, 75000, 22000, nuke } },
			{ { 2400, 1200, gigantic, 90000, 40000, nuke }, { 3600, 1800, gigantic, 240000, 75000, nuke } },
		},
		f = {
			{ { 1600, 800, huge, 45000, 0, nuke }, { 2400, 1200, gigantic, 135000, 0, nuke } },
			{ { 3000, 1500, gigantic, 180000, 0, nuke }, { 4800, 2400, gigantic, 500000, 0, nuke } },
		},
		t = {
			{ { 700, 350, large, 8000, 0, medium }, { 1200, 600, huge, 30000, 0, big } },
			{ { 1800, 900, huge, 60000, 0, big }, { 2800, 1400, gigantic, 180000, 0, nuke } },
		},
	}
	local stores = {
		{ "armuwadvmst3", "armuwadvmst4", "armuwadvest3", "armuwadvest4" },
		{ "coruwadvmst3", "coruwadvmst4", "coruwadvest3", "coruwadvest4" },
		{ "legamstort3", "legamstort4", "legadvestoret3", "legadvestoret4" },
	}
	local function blast(unit, key, tier, pair)
		if not unit then
			return
		end
		unit.weapondefs = unit.weapondefs or {}
		local death, selfd = key .. "_t" .. tier, key .. "_t" .. tier .. "_selfd"
		for i = 1, 2 do
			local p, name = pair[i], i == 1 and death or selfd
			local damage = { default = p[4] }
			if p[5] > 0 then
				damage.commanders = p[5]
			end
			unit.weapondefs[name] = {
				AreaOfEffect = p[1],
				cameraShake = p[2],
				impulsefactor = 0.123,
				soundhit = p[6],
				soundstart = "largegun",
				explosiongenerator = p[3],
				damage = damage,
				customparams = { unitexplosion = 1 },
			}
		end
		unit.explodeas, unit.selfdestructas = death, selfd
	end
	for i, faction in ipairs(factions) do
		local prefix = faction[1]
		local converter = prefix == "leg" and "legadveconv" or prefix .. "mmkr"
		for tier = 3, 4 do
			local index = tier - 2
			blast(U[converter .. "_t" .. tier], "convboom", tier, B.c[index])
			blast(U[prefix .. "moho_t" .. tier], "mexboom", tier, B.x[index])
			blast(U[stores[i][index]], "storagemetalboom", tier, B.m[index])
			blast(U[stores[i][tier]], "storageenergyboom", tier, B.e[index])
			blast(U[prefix .. "afust" .. tier], "fusionboom", tier, B.f[index])
			blast(U[prefix .. "nanotct" .. tier], "constructionboom", tier, B.t[index])
		end
	end
end
