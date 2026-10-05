do
	local U, lower = UnitDefs, string.lower

	local function copy(v)
		if type(v) ~= "table" then
			return v
		end
		local r = {}
		for k, x in pairs(v) do
			r[copy(k)] = copy(x)
		end
		return r
	end

	local function findUnit(n)
		return n and (U[n] or U[lower(n)])
	end

	local function findSource(c)
		for i = 1, #c do
			local s = findUnit(c[i])
			if s then
				return s, c[i]
			end
		end
	end

	local function findWDef(u, defName)
		if not (u and u.weapondefs) then
			return
		end
		if u.weapondefs[defName] then
			return u.weapondefs[defName]
		end
		local w = lower(defName)
		for n, d in pairs(u.weapondefs) do
			if lower(n) == w then
				return d
			end
		end
	end

	local function getSlot(u, idx)
		if not (u and u.weapons and u.weapons[idx] and u.weapons[idx].def) then
			return
		end
		local d = findWDef(u, u.weapons[idx].def)
		return d and u.weapons[idx], d
	end

	local function getSlotCount(u)
		if not (u and u.weapons) then
			return 0
		end
		local c = 0
		for i = 1, 32 do
			local s, d = getSlot(u, i)
			if not (s and d) then
				break
			end
			c = i
		end
		return c
	end

	local function teach(builders, dest)
		for b in builders:gmatch("%S+") do
			local bd = U[b]
			if bd then
				bd.buildoptions = bd.buildoptions or {}
				local exists = false
				for _, opt in ipairs(bd.buildoptions) do
					if opt == dest then
						exists = true
						break
					end
				end
				if not exists then
					bd.buildoptions[#bd.buildoptions + 1] = dest
				end
			end
		end
	end

	local function createUnit(name, c)
		if U[name] then
			return U[name], U[name], name
		end
		local src, srcName = findSource(c)
		if not src then
			return
		end
		local u = copy(src)
		U[name] = u
		return u, src, srcName
	end

	local function sanitize(u)
		for k in
			("maxacc maxdec maxvelocity turnrate cloakcost cloakcostmoving energymake energyuse energyupkeep"):gmatch(
				"%S+"
			)
		do
			u[k] = 0
		end
		for k in
			("canmove canpatrol canfight canrepeat canassist canrepair canreclaim canresurrect cancapture turninplace cloakable cancloak initcloaked builder"):gmatch(
				"%S+"
			)
		do
			u[k] = false
		end
		u.buildoptions, u.weapons, u.weapondefs = nil, {}, {}
		u.activatewhenbuilt, u.onoffable = true, true
	end

	local function label(u, name, tip)
		u.customparams = u.customparams or {}
		u.customparams.techlevel = 4
		for l in ("en de fr es it ru zh cs hr lt"):gmatch("%S+") do
			u.customparams["i18n_" .. l .. "_humanname"], u.customparams["i18n_" .. l .. "_tooltip"] = name, tip
		end
	end

	local function installWeapon(u, src, srcSlot, newName, overrides, slotOverrides)
		local sSlot, sDef = getSlot(src, srcSlot)
		if not (sSlot and sDef) then
			return false
		end
		local w = copy(sDef)
		for k, v in pairs(overrides or {}) do
			w[k] = copy(v)
		end
		w.noselfdamage, w.turret = true, true
		u.weapondefs[newName] = w

		local s = copy(sSlot)
		s.def = newName
		slotOverrides = slotOverrides or {}
		if w.onlytargetcategory and not slotOverrides.onlytargetcategory then
			slotOverrides.onlytargetcategory = w.onlytargetcategory
		end
		for k, v in pairs(slotOverrides) do
			s[k] = copy(v)
		end
		u.weapons[#u.weapons + 1] = s
		return true
	end

	-- Specs format: { name, srcCandidates, {metal, energy, buildtime, hp, cap, upkeep, sight, radar}, hname, tip, setup }
	local SPECS = {
		-- 1. STREAM ARTILLERY: Sustained Shell Pressure
		{
			"player_streamarty",
			{ "corint", "armbrtha" },
			{ 780e3, 1700e4, 1700e4, 900e3, 2, 38000, 850, 3200 },
			"Stream Artillery",
			"Continuous rapid-fire kinetic artillery battery",
			function(u, src)
				installWeapon(u, src, 1, "STREAM_ARTILLERY", {
					weapontype = "Cannon",
					range = 4600,
					reloadtime = 0.06,
					accuracy = 200,
					sprayangle = 420,
					areaofeffect = 520,
					weaponvelocity = 4200,
					energypershot = 6200,
					damage = { default = 3400, shields = 9000, commandertoo = 900 },
					impulsefactor = 8.0,
					impulseboost = 5.0,
					craterboost = 3.0,
					cratermult = 2.5,
					camerashake = 90,
					size = 9.0,
					cegtag = "arty-small",
					explosiongenerator = "custom:genericshellexplosion-small",
					soundhit = "xplomed2",
					soundstart = "cannhvy1",
					onlytargetcategory = "SURFACE",
				})
			end,
		},

		-- 2. HOLY BEAM: Precision Sustained Thermal Lance
		{
			"player_holybeam",
			{ "armanni", "cordoom" },
			{ 700e3, 1500e4, 1500e4, 820e3, 2, 34000, 1350, 2600 },
			"Holy Beam",
			"Continuous precision white-gold lance beam",
			function(u, src)
				installWeapon(u, src, 1, "HOLY_BEAM", {
					weapontype = "BeamLaser",
					largebeamlaser = true,
					range = 3600,
					reloadtime = 0.03,
                    beamtime = 0.018,
					beamttl = 2,
                    thickness = 3.0,
                    corethickness = 0.50,
                    laserflaresize = 4,
					energypershot = 3600,
					rgbcolor = "1 0.96 0.82",
					damage = { default = 2600, shields = 12000, vtol = 7000, commandertoo = 700 },
					texture3 = "largebeam",
					tilelength = 150,
					explosiongenerator = "custom:laserhit-small-yellow",
					soundstart = "beamlaserfire",
					soundtrigger = 1,
					onlytargetcategory = "SURFACE VTOL",
				})
			end,
		},

		-- 3. AEGIS STARSPIRE: Long-Range Multi-Lock Continuous Sky-Melter
		{
			"player_aegisstarspire",
			{ "legflak", "corflak", "armflak", "armmercury" },
			{ 620e3, 1600e4, 1600e4, 780e3, 3, 38000, 1400, 3800 },
			"Aegis Starspire",
			"Multi-channel continuous laser spires. Locks 3 targets at 4400 range to disintegrate air raids.",
			function(u, src)
				local beamHues = { "0.0 0.95 1.0", "0.4 0.25 1.0", "0.0 0.75 1.0" }
				for slot = 1, 3 do
					installWeapon(u, src, 1, "AEGIS_STARBEAM_" .. slot, {
						weapontype = "BeamLaser",
						largebeamlaser = true,
						range = 4400,
						reloadtime = 0.04,
                        beamtime = 0.022,
						beamttl = 3,
                        thickness = 4.0,
                        corethickness = 0.55,
                        laserflaresize = 5,
						energypershot = 2400,
						pulsespeed = 12,
						scrollspeed = 10,
						rgbcolor = beamHues[slot],
						rgbcolor2 = "0.7 0.1 1.0",
						texture3 = "largebeam",
						tilelength = 120,
						damage = { default = 4200, vtol = 42000, shields = 14000, commandertoo = 800 },
						explosiongenerator = "custom:laserhit-large-blue",
						soundstart = "beamlaserfire",
						soundtrigger = 1,
						onlytargetcategory = "VTOL",
					}, {
						fastautoretargeting = true,
						onlytargetcategory = "VTOL",
					})
				end
			end,
		},

		-- 4. TEMPEST STORM: Electrified Arc & Thermite Anti-Swarm Matrix
		{
			"player_thornnest",
			{ "corpun", "armguard", "corflak" },
			{ 280e3, 620e4, 620e4, 450e3, 4, 18000, 850, 1800 },
			"Tempest Storm",
			"Electrified napalm chain-arc array. Vaporizes massed ground swarms and air raids.",
			function(u, src)
				installWeapon(u, src, 1, "TEMPEST_STORM", {
					weapontype = "LightningCannon",
					range = 1550,
					reloadtime = 0.4,
					burst = 12,
					burstrate = 0.025,
					projectilespershot = 8,
					sprayangle = 2400,
					weaponvelocity = 5400,
					thickness = 16,
					rgbcolor = "0.25 0.85 1.0",
					areaofeffect = 220,
					edgeeffectiveness = 0.9,
					energypershot = 950,
					firestarter = 100,
					cegtag = "burnflame",
					explosiongenerator = "custom:genericshellexplosion-small-lightning",
					soundstart = "weapons/tecl_fire.wav",
					soundhitdry = "weapons/lashit.wav",
					soundhit = "xplomed1",
					damage = { default = 3200, vtol = 12000, shields = 4500, commandertoo = 850 },
					onlytargetcategory = "SURFACE VTOL",
				})
			end,
		},

		-- 5. MIRROR ARRAY: Miniature Precision Point Defense
		{
			"player_mirrorarray",
			{ "armmercury", "corscreamer" },
			{ 320e3, 700e4, 780e4, 380e3, 4, 16000, 950, 1800 },
			"Mirror Array",
			"High-velocity miniature kinetic point-defense battery",
			function(u, src)
				installWeapon(u, src, 1, "MIRROR_INTERCEPT", {
					weapontype = "Cannon",
					range = 1800,
					reloadtime = 0.05,
					accuracy = 10,
					sprayangle = 90,
					areaofeffect = 60,
					weaponvelocity = 6200,
					energypershot = 900,
					damage = { default = 900, vtol = 5200, shields = 900, commandertoo = 300 },
					size = 4.5,
					rgbcolor = "0.85 0.95 1",
					explosiongenerator = "custom:laserhit-small-blue",
					soundhit = "flakhit",
					soundstart = "flakfire",
					onlytargetcategory = "SURFACE VTOL",
				})
			end,
		},

		-- 6. VOID VORTEX: Singular Gravitational Inversion Battery
		{
			"player_voidvortex",
			{ "corpun", "armguard", "corint" },
			{ 580e3, 1400e4, 1400e4, 620e3, 3, 36000, 950, 2600 },
			"Void Vortex",
			"Gravitational collapse artillery. Pulls, compresses, and shatters advancing armadas.",
			function(u, src)
				installWeapon(u, src, 1, "VOID_VORTEX", {
					weapontype = "Cannon",
					range = 3400,
					reloadtime = 2.4,
					accuracy = 180,
					areaofeffect = 850,
					edgeeffectiveness = 0.9,
					weaponvelocity = 1800,
					energypershot = 45000,
					impulsefactor = -75.0,
					impulseboost = -55.0,
					craterboost = 0,
					cratermult = 0,
					camerashake = 220,
					size = 18.0,
					stages = 36,
					intensity = 3.0,
					alpha = 0.95,
					rgbcolor = "0.38 0.04 0.62",
					cegtag = "heatcloud-rot-purple",
					explosiongenerator = "custom:exp_emp_large",
					soundhit = "weapons/xplonuk4.wav",
					soundstart = "weapons/cannon_heavy.wav",
					damage = { default = 28000, shields = 95000, commandertoo = 7000 },
					onlytargetcategory = "SURFACE VTOL",
				})
			end,
		},

		-- 7. INFERNO CRUCIBLE: Heavy Napalm Torrent Flamethrower
		{
			"player_infernocrucible",
			{ "corgol", "corkrog", "corpun", "armguard" },
			{ 450e3, 980e4, 980e4, 620e3, 4, 24000, 950, 2000 },
			"Inferno Crucible",
			"Heavy multi-barrel chemical flamethrower. Envelops chokepoints in an inescapable sea of liquid fire.",
			function(u, src)
				installWeapon(u, src, 1, "INFERNO_CRUCIBLE", {
					weapontype = "Flame",
					range = 1950,
					reloadtime = 0.15,
					burst = 28,
					burstrate = 0.025,
					projectilespershot = 4,
					sprayangle = 1400,
					weaponvelocity = 1100,
					flamegfxtime = 75,
					size = 7.5,
					sizegrowth = 1.8,
					intensity = 0.9,
					rgbcolor = "1.0 0.38 0.05",
					areaofeffect = 260,
					edgeeffectiveness = 0.92,
					energypershot = 1200,
					firestarter = 100,
					groundbounce = true,
					bouncerebound = 0.45,
					bounceminspeed = 180,
					cegtag = "burnflame",
					explosiongenerator = "custom:napalm_fire",
					soundstart = "weapons/flamfir1.wav",
					soundhit = "weapons/burn02.wav",
					damage = { default = 4800, shields = 16000, commandertoo = 1100 },
					onlytargetcategory = "SURFACE",
				})
			end,
		},

		-- 8. CASCADE MORTAR: High-Arc Geyser Saturation Battery
		{
			"player_cascademortar",
			{ "legcluster", "corpun", "armguard" },
			{ 1100e3, 2400e4, 2400e4, 1500e3, 2, 92000, 1100, 3600 },
			"Cascade Mortar",
			"Apocalyptic orbital plasma geyser. Rains devastating apocalyptic cataclysms across entire map sectors.",
			function(u, src)
				u.hightrajectorytype = 1
				installWeapon(u, src, 1, "CASCADE_FOUNTAIN", {
					weapontype = "Cannon",
					range = 7200,
					reloadtime = 0.3,
					burst = 24,
					burstrate = 0.02,
					projectilespershot = 20,
					sprayangle = 1100,
					accuracy = 320,
					hightrajectory = 1,
					weaponvelocity = 1300,
					mygravity = 0.55,
					areaofeffect = 1400,
					edgeeffectiveness = 0.9,
					energypershot = 2600,
					size = 18.0,
					stages = 48,
					intensity = 4.5,
					alpha = 0.98,
					rgbcolor = "0.1 0.85 1.0",
					cegtag = "cruisemissiletrail-tacnuke",
					explosiongenerator = "custom:FLASHNUKE280",
					soundstart = "weapons/cannon_heavy.wav",
					soundhit = "weapons/xplonuk4.wav",
					craterboost = 11.0,
					cratermult = 8.0,
					impulsefactor = 30.0,
					impulseboost = 22.0,
					camerashake = 400,
					damage = { default = 42000, shields = 180000, commandertoo = 9000 },
					onlytargetcategory = "SURFACE",
				})
			end,
		},
	}

	local BUILDERS =
		"armack corack legack armacv coracv legacv armaca coraca legaca armacsub coracsub armcsa corcsa legnavyconship leganavyconsub legspcon armbehem corcrabe"
	local created = {}

	for _, spec in ipairs(SPECS) do
		local u, source, sourceName = createUnit(spec[1], spec[2])
		if u and source then
			local slots = getSlotCount(source)
			sanitize(u)

			local st = spec[3]
			st[1], st[2], st[3] = st[1] * 0.20, st[2] * 0.20, st[3] * 0.20
			u.unitname, u.name = spec[1], spec[1]
			u.metalcost, u.energycost, u.buildtime = st[1], st[2], st[3]
			u.health, u.maxdamage = st[4], st[4]
			u.energyupkeep, u.energyuse = st[6], st[6]
			if st[7] then
				u.sightdistance = st[7]
			end
			if st[8] then
				u.radardistance = st[8]
			end

			u.category = source.category or "ALL SURFACE WEAPON"
			u.maxwaterdepth, u.maxslope = 12, 14
			u.canattack, u.canstop, u.activatewhenbuilt, u.onoffable = true, true, true, true

			u.customparams = u.customparams or {}
			u.customparams.techlevel = 4
			u.customparams.unitgroup = "weapon"
			u.customparams.t4_turret = 1
			u.customparams.t4_source = sourceName
			u.customparams.t4_source_weapon_slots = slots
			u.maxthisunit = st[5]

			label(u, spec[4], spec[5])
			spec[6](u, source)

			if source.weapons and #u.weapons < #source.weapons then
				local dName = spec[1] .. "_dummy"
				local mainW = u.weapons[1] and u.weapondefs[u.weapons[1].def]
				u.weapondefs[dName] = {
					weapontype = "Cannon",
					range = 1,
					reloadtime = 9999,
					damage = { default = 0 },
					noselfdamage = true,
					turret = true,
					explosiongenerator = mainW and mainW.explosiongenerator or "custom:genericshellexplosion-tiny-aa",
				}
				for sIdx = #u.weapons + 1, #source.weapons do
					local sSlot = source.weapons[sIdx]
					u.weapons[sIdx] = {
						def = dName,
						onlytargetcategory = sSlot and sSlot.onlytargetcategory or "SURFACE",
					}
				end
			end

			created[#created + 1] = spec[1]
		end
	end

	for _, unitName in ipairs(created) do
		teach(BUILDERS, unitName)
	end
end
