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
			return U[name]
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
			("speed maxacc maxdec maxvelocity turnrate cloakcost cloakcostmoving energymake energyuse energyupkeep"):gmatch(
				"%S+"
			)
		do
			u[k] = 0
		end
		u.movementclass = nil
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
		w.stockpile, w.stockpiletime, w.commandfire, w.metalpershot, w.interceptor, w.coverage, w.impactonly, w.model, w.customparams =
			false, nil, false, 0, 0, nil, nil, "", {}
		for k, v in pairs(overrides or {}) do
			w[k] = copy(v)
		end
		w.noselfdamage, w.turret = true, true
		u.weapondefs[newName] = w

		local s = copy(sSlot)
		s.def, s.maindir, s.maxangledif = newName, nil, nil
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
					reloadtime = 0.55,
					accuracy = 200,
					sprayangle = 420,
					areaofeffect = 480,
					weaponvelocity = 4200,
					energypershot = 3600,
					damage = { default = 3600, shields = 4500, commanders = 1000 },
					impulsefactor = 8.0,
					impulseboost = 5.0,
					craterboost = 3.0,
					cratermult = 2.5,
					camerashake = 90,
					size = 11.0,
					stages = 18,
					intensity = 2.0,
					rgbcolor = "1 0.72 0.3",
					cegtag = "arty-medium",
					explosiongenerator = "custom:genericshellexplosion-medium",
					soundhit = "xplolrg3",
					soundstart = "rflrpc3",
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
					reloadtime = 0.25,
                    beamtime = 0.034,
					beamttl = 2,
                    thickness = 3.5,
                    corethickness = 0.50,
                    laserflaresize = 10,
					scrollspeed = 10,
					pulsespeed = 12,
					energypershot = 2000,
					rgbcolor = "1 0.96 0.82",
					rgbcolor2 = "1 1 0.98",
					damage = { default = 2300, shields = 2400, vtol = 1200, commanders = 550 },
					texture3 = "largebeam",
					tilelength = 150,
					explosiongenerator = "custom:laserhit-large-yellow",
					soundstart = "beamershot2",
					soundtrigger = 1,
					onlytargetcategory = "SURFACE VTOL",
				}, { badtargetcategory = "GROUNDSCOUT" })
			end,
		},

		-- 3. AEGIS STARSPIRE: Quad-Channel Long-Range Continuous Sky-Melter
		{
			"player_aegisstarspire",
			{ "corhllllt" },
			{ 620e3, 1600e4, 1600e4, 780e3, 3, 38000, 1400, 3800 },
			"Aegis Starspire",
			"Four laser channels engage air raids at up to 3600 range.",
			function(u, src)
				local beamHues = { "0.0 0.95 1.0", "0.4 0.25 1.0", "0.0 0.75 1.0", "0.25 0.55 1.0" }
				for slot = 1, 4 do
					installWeapon(u, src, slot, "AEGIS_STARBEAM_" .. slot, {
						weapontype = "BeamLaser",
						canattackground = false,
						largebeamlaser = true,
						range = 3600,
						reloadtime = 0.4,
                        beamtime = 0.034,
						beamttl = 3,
                        thickness = 4.0,
                        corethickness = 0.55,
                        laserflaresize = 8,
						energypershot = 700,
						pulsespeed = 12,
						scrollspeed = 10,
						rgbcolor = beamHues[slot],
						rgbcolor2 = "0.7 0.1 1.0",
						texture3 = "largebeam",
						tilelength = 120,
						damage = { default = 100, vtol = 950, shields = 400, commanders = 60 },
						explosiongenerator = "custom:laserhit-large-aqua",
						soundstart = "lasrhvy2",
						soundtrigger = 1,
						onlytargetcategory = "VTOL",
					}, {
						fastautoretargeting = true,
						onlytargetcategory = "VTOL",
						badtargetcategory = "",
					})
				end
			end,
		},

		-- 4. TEMPEST STORM: Electrified Chain-Arc Anti-Swarm Battery
		{
			"player_thornnest",
			{ "corpun", "armguard", "corflak" },
			{ 360e3, 780e4, 780e4, 380e3, 4, 18000, 850, 1800 },
			"Tempest Storm",
			"Chain-arc array for massed ground swarms and air raids.",
			function(u, src)
				installWeapon(u, src, 1, "TEMPEST_STORM", {
					weapontype = "LightningCannon",
					canattackground = true,
					range = 1550,
					reloadtime = 1.4,
					burst = 8,
					burstrate = 0.04,
					projectiles = 4,
					sprayangle = 2200,
					weaponvelocity = 5400,
					thickness = 14,
					rgbcolor = "0.25 0.88 1.0",
					areaofeffect = 200,
					edgeeffectiveness = 0.85,
					energypershot = 1200,
					firestarter = 100,
					cegtag = "lightning_stormbolt",
					explosiongenerator = "custom:genericshellexplosion-large-lightning",
					soundstart = "electric2",
					soundhitdry = "lashit",
					soundhit = "xploelc2",
					customparams = {
						spark_forkdamage = "0.25",
						spark_maxunits = "3",
						spark_range = "130",
					},
					damage = { default = 330, vtol = 420, shields = 600, commanders = 100 },
					onlytargetcategory = "SURFACE VTOL",
				}, { badtargetcategory = "" })
			end,
		},

		-- 5. PRISM DISRUPTOR: Long-range beam and EMP interception
		{
			"player_mirrorarray",
			{ "armmercury", "corscreamer" },
			{ 320e3, 700e4, 780e4, 380e3, 4, 16000, 950, 1800 },
			"Prism Disruptor",
			"Long-range prism beam that briefly paralyzes heavy ground and air targets",
			function(u, src)
				installWeapon(u, src, 1, "MIRROR_INTERCEPT", {
					weapontype = "BeamLaser",
					canattackground = true,
					range = 2400,
					reloadtime = 3.2,
					beamtime = 0.20,
					largebeamlaser = true,
					beamttl = 8,
					corethickness = 0.55,
					thickness = 7,
					laserflaresize = 9,
					scrollspeed = 8,
					pulsespeed = 10,
					energypershot = 6000,
					paralyzetime = 5,
					paralyzer = true,
					damage = { default = 27000, vtol = 24000, shields = 10000, commanders = 5000 },
					rgbcolor = "0.25 0.92 1",
					rgbcolor2 = "0.9 1 1",
					explosiongenerator = "custom:laserhit-emp",
					soundhit = "xploelc1",
					soundstart = "lasrhvy3",
					onlytargetcategory = "SURFACE VTOL",
				}, { badtargetcategory = "LIGHTAIRSCOUT" })
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
				local slot = getSlot(src, 1)
				installWeapon(u, src, 1, "VOID_VORTEX", {
					weapontype = "Cannon",
					range = 3400,
					reloadtime = 5,
					accuracy = 180,
					areaofeffect = 440,
					edgeeffectiveness = 0.85,
					weaponvelocity = 2200,
					energypershot = 42000,
					impulsefactor = -4,
					impulseboost = -3,
					craterboost = 0,
					cratermult = 0,
					camerashake = 180,
					size = 18.0,
					stages = 36,
					intensity = 3.0,
					alpha = 0.95,
					rgbcolor = "0.45 0.08 0.78",
					cegtag = "juno_sphere_emit",
					explosiongenerator = "custom:juno-explo",
					soundhit = "xplonuk4",
					soundstart = "junofir2",
					damage = { default = 30000, shields = 29000, commanders = 5500 },
					onlytargetcategory = "SURFACE VTOL",
				}, slot and slot.badtargetcategory == "VTOL" and { badtargetcategory = "" } or nil)
			end,
		},

		-- 7. INFERNO CRUCIBLE: Heavy Napalm Torrent Flamethrower
		{
			"player_infernocrucible",
			{ "corpun", "armguard", "corpyro" },
			{ 450e3, 980e4, 980e4, 620e3, 4, 24000, 950, 2000 },
			"Inferno Crucible",
			"Heavy multi-barrel chemical flamethrower. Envelops chokepoints in an inescapable sea of liquid fire.",
			function(u, src)
				installWeapon(u, src, 1, "INFERNO_CRUCIBLE", {
					weapontype = "Flame",
					range = 1050,
					reloadtime = 1.6,
					burst = 14,
					burstrate = 0.034,
					projectiles = 2,
					sprayangle = 1300,
					weaponvelocity = 1100,
					flamegfxtime = 1.2,
					size = 7.5,
					sizegrowth = 1.8,
					intensity = 1.4,
					rgbcolor = "1.0 0.38 0.05",
					areaofeffect = 240,
					edgeeffectiveness = 0.88,
					energypershot = 1400,
					firestarter = 100,
					groundbounce = true,
					bouncerebound = 0.45,
					numbounce = 1,
					cegtag = "flamestreamxl",
					explosiongenerator = "custom:fire-incinerator",
					soundstart = "flamhvy1",
					soundhit = "flamhit1",
					damage = { default = 520, shields = 850, commanders = 160 },
					onlytargetcategory = "SURFACE",
				})
			end,
		},

		-- 8. CASCADE MORTAR: High-Arc Geyser Saturation Battery
		{
			"player_cascademortar",
			{ "legcluster", "corpun", "armguard" },
			{ 1100e3, 2400e4, 2400e4, 1200e3, 2, 80000, 1100, 3600 },
			"Cascade Mortar",
			"Apocalyptic orbital plasma geyser. Rains devastating cataclysms across map sectors.",
			function(u, src)
				u.hightrajectory = 1
				installWeapon(u, src, 1, "CASCADE_FOUNTAIN", {
					weapontype = "Cannon",
					range = 6200,
					reloadtime = 7,
					burst = 8,
					burstrate = 0.10,
					projectiles = 5,
					sprayangle = 1200,
					accuracy = 320,
					hightrajectory = 1,
					weaponvelocity = 1750,
					mygravity = 0.40,
					areaofeffect = 390,
					edgeeffectiveness = 0.75,
					energypershot = 12000,
					size = 16.0,
					stages = 40,
					intensity = 4.0,
					alpha = 0.96,
					rgbcolor = "0.15 0.88 1.0",
					cegtag = "cruisemissiletrail-tacnuke",
					explosiongenerator = "custom:nukedatbewm",
					soundstart = "nukelaunch",
					soundhit = "xplonuk4",
					craterboost = 6.0,
					cratermult = 4.0,
					impulsefactor = 18.0,
					impulseboost = 12.0,
					camerashake = 240,
					damage = { default = 1300, shields = 1800, commanders = 350 },
					onlytargetcategory = "SURFACE",
				})
			end,
		},
	}

	local BUILDERS =
		"armack corack legack armacv coracv legacv armaca coraca legaca armacsub coracsub armcsa corcsa legnavyconship leganavyconsub legspcon armbehem corcrabe"
	local created = {}
	local TURRET_ENERGY_FACTOR = 0.25

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
			local upkeep = st[6] * TURRET_ENERGY_FACTOR * 0.2
			u.energyupkeep, u.energyuse = upkeep, upkeep
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
			for _, weapon in pairs(u.weapondefs) do
				if weapon.energypershot then
					weapon.energypershot = weapon.energypershot * TURRET_ENERGY_FACTOR
				end
			end
			u.customparams.turret_energy_factor = TURRET_ENERGY_FACTOR

			if source.weapons and #u.weapons < #source.weapons then
				local dName = spec[1] .. "_dummy"
				local mainW = u.weapons[1] and u.weapondefs[u.weapons[1].def]
				u.weapondefs[dName] = {
					weapontype = "Cannon",
					range = 1,
					reloadtime = 9999,
					damage = { default = 0 },
					canattackground = false,
					noselfdamage = true,
					turret = true,
					explosiongenerator = mainW and mainW.explosiongenerator or "custom:genericshellexplosion-tiny-aa",
				}
				for sIdx = #u.weapons + 1, #source.weapons do
					u.weapons[sIdx] = {
						def = dName,
						onlytargetcategory = "NONE",
					}
				end
			end
		end
		if u then
			created[#created + 1] = spec[1]
		end
	end

	for _, unitName in ipairs(created) do
		teach(BUILDERS, unitName)
	end
end
