-- Adds a faction-specific T3/T4 construction-turret progression and its
-- requested cross-faction build options.
do
	local U = UnitDefs or {}

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

	local function ensureOption(builderName, optionName)
		local builder, option = U[builderName], U[optionName]
		if not (builder and option) then
			return
		end
		builder.buildoptions = builder.buildoptions or {}
		for _, existing in ipairs(builder.buildoptions) do
			if existing == optionName then
				return
			end
		end
		builder.buildoptions[#builder.buildoptions + 1] = optionName
	end

	local function removeOption(builderName, optionName)
		local builder = U[builderName]
		if not (builder and builder.buildoptions) then
			return
		end
		for index = #builder.buildoptions, 1, -1 do
			if builder.buildoptions[index] == optionName then
				table.remove(builder.buildoptions, index)
			end
		end
	end

	local factions = {
		{ prefix = "arm", name = "Armada" },
		{ prefix = "cor", name = "Cortex" },
		{ prefix = "leg", name = "Legion" },
	}
	local turretBlasts = {
		[3] = {
			{ "constructionboom_t3", 700, 350, "custom:genericbuildingexplosion-large", 8000, "xplomed1" },
			{ "constructionboom_t3_selfd", 1200, 600, "custom:genericbuildingexplosion-huge", 30000, "xplolrg3" },
		},
		[4] = {
			{ "constructionboom_t4", 1800, 900, "custom:genericbuildingexplosion-huge", 60000, "xplolrg3" },
			{ "constructionboom_t4_selfd", 2800, 1400, "custom:genericbuildingexplosion-gigantic", 180000, "xplonuk3" },
		},
	}

	local function createTurret(sourceName, unitName, displayName, tier)
		local turret = U[unitName]
		local source = U[sourceName]
		local isNew = turret == nil
		if isNew then
			if not source then
				return
			end
			turret = copy(source)
		end
		local rank = tier == 3 and "Epic" or "Legendary"
		turret.unitname = unitName
		turret.name = displayName
		turret.description = "Tier " .. tier .. " " .. rank .. " construction turret."
		turret.customparams = turret.customparams or {}
		turret.customparams.i18n_en_humanname = displayName
		turret.customparams.i18n_en_tooltip = turret.description
		if isNew and tier == 3 then
			turret.metalcost = 3700
			turret.energycost = 62000
			turret.buildtime = 108000
			turret.footprintx, turret.footprintz = 8, 8
			turret.collisionvolumescales = "82 150 82"
		elseif isNew then
			turret.metalcost = math.ceil((tonumber(source.metalcost) or 3700) * 3)
			turret.energycost = math.ceil((tonumber(source.energycost) or 62000) * 3)
			turret.buildtime = math.ceil((tonumber(source.buildtime) or 108000) * 3)
			turret.footprintx, turret.footprintz = 10, 10
			turret.collisionvolumescales = "104 180 104"
		end
		if tier == 3 then
			turret.health, turret.maxdamage = 10560, 10560
			turret.workertime, turret.builddistance = 2400, 750
		else
			turret.health, turret.maxdamage = 26400, 26400
			turret.workertime, turret.builddistance = 4000, 900
		end
		turret.weapondefs = turret.weapondefs or {}
		for _, blast in ipairs(turretBlasts[tier]) do
			turret.weapondefs[blast[1]] = {
				AreaOfEffect = blast[2], cameraShake = blast[3], impulsefactor = 0.123,
				soundhit = blast[6], soundstart = "largegun",
				explosiongenerator = blast[4], damage = { default = blast[5] },
				customparams = { unitexplosion = 1 },
			}
		end
		turret.explodeas, turret.selfdestructas = turretBlasts[tier][1][1], turretBlasts[tier][2][1]
		if isNew then
			U[unitName] = turret
		end
		if UnitDefNames then
			UnitDefNames[unitName] = turret
		end
		return turret
	end

	local sharedBuildOptions = {
		-- Player ultra turrets (both regular and advanced packs).
		"player_hailstorm", "player_needleswarm", "player_blackoutcascade",
		"player_phalanxlance", "player_quakedoom", "player_nullcathedral",
		"player_hivearray", "player_aegiseraser", "player_executioner",
		"player_prismcathedral", "player_hyperionlance", "player_starfallcataclysm",
		"player_streamarty", "player_holybeam", "player_aegisstarspire",
		"player_thornnest", "player_mirrorarray", "player_voidvortex",
		"player_infernocrucible", "player_cascademortar",
		-- Experimental land and air gantries for all factions.
		"armshltx", "corgant", "leggant", "armapt3", "corapt3", "legapt3",
		-- T2 bot, vehicle, and aircraft factories for all factions.
		"armalab", "coralab", "legalab", "armvp", "corvp", "legvp",
		"armaap", "coraap", "legaap",
		-- Standard faction shields, including T3 shields.
		"armgate", "corgate", "legdeflector", "armgatet3", "corgatet3", "leggatet3",
		"armfgate", "corfgate",
		-- Custom shield units, when the corresponding player pack is enabled.
		"player_aegisdome", "player_citadelumbrella",
	}

	local t2Constructors = {
		"armack", "armacv", "armaca",
		"corack", "coracv", "coraca",
		"legack", "legacv", "legaca",
	}

	for _, faction in ipairs(factions) do
		local prefix = faction.prefix
		createTurret(
			prefix .. "nanotct2",
			prefix .. "nanotct3",
			faction.name .. " T3 Epic Construction Turret",
			3
		)
		createTurret(
			prefix .. "nanotct3",
			prefix .. "nanotct4",
			faction.name .. " T4 Legendary Construction Turret",
			4
		)
	end

	for _, builderName in ipairs(t2Constructors) do
		local prefix = builderName:sub(1, 3)
		ensureOption(builderName, prefix .. "nanotct3")
		removeOption(builderName, prefix .. "nanotct4")
	end

	for _, faction in ipairs(factions) do
		local turretName = faction.prefix .. "nanotct3"
		if U[turretName] then
			for _, optionName in ipairs(sharedBuildOptions) do
				ensureOption(turretName, optionName)
			end
			ensureOption(turretName, faction.prefix .. "nanotct4")
		end
	end
end
