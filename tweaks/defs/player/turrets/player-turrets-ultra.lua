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
			("speed maxacc maxdec maxvelocity turnrate cloakcost cloakcostmoving energymake energyuse energyupkeep"):gmatch(
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

	local function D(d, v, s, c)
		local t = { default = d }
		if v then
			t.vtol = v
		end
		if s then
			t.shields = s
		end
		if c then
			t.commandertoo = c
		end
		return t
	end

	local function setMissileVis(w, heavy)
		w.cegtag, w.smoketrail, w.smoketrailcastshadow = "missiletrailaa", true, false
		w.smokeperiod, w.smoketime, w.smokesize, w.smokecolor =
			heavy and 2 or 1, heavy and 12 or 24, heavy and 3.8 or 7.0, 1
		w.texture1, w.texture2 = "null", "smoketrailaa"
		w.explosiongenerator = heavy and "custom:genericshellexplosion-small"
			or "custom:genericshellexplosion-medium-aa"
	end

	local C_CAN, C_MSL, C_BLAS, T_V, T_S, T_SV =
		"Cannon", "MissileLauncher", "BeamLaser", "VTOL", "SURFACE", "SURFACE VTOL"
	local S_CAN1, S_CAN2, S_BLAS, S_ANNI = "cannhvy1", "cannhvy2", "beamlaserfire", "annigun1"

	local SPECS = {
		-- 1. HAILSTORM
		{
			"player_hailstorm",
			{ "armflak", "corflak" },
			{ 260e3, 540e4, 260e3, 4, 22000, 800, 1600 },
			"Hailstorm",
			"Short-range saturation flak battery",
			function(u, src)
				installWeapon(u, src, 1, "HAILSTORM_FLAK", {
					weapontype = C_CAN,
					range = 1550,
					reloadtime = 1.0,
					burst = 30,
					burstrate = 0.03,
					sprayangle = 1400,
					accuracy = 350,
					areaofeffect = 140,
					weaponvelocity = 4200,
					energypershot = 1200,
					onlytargetcategory = T_V,
					damage = D(1200, 16000, 4800),
					cegtag = "flaktrailaamg",
					explosiongenerator = "custom:flakshard",
					texture1 = "null",
					texture2 = "flaktrail",
					soundhit = "flakhit",
					soundstart = "flakfire",
				})
			end,
		},
		-- 2. NEEDLE SWARM
		{
			"player_needleswarm",
			{ "armmercury", "corscreamer" },
			{ 300e3, 620e4, 240e3, 3, 26000, 1250, 2800 },
			"Needle Swarm",
			"Fast-tracking long-range AA missiles",
			function(u, src)
				installWeapon(u, src, 1, "NEEDLE_SWARM", {
					weapontype = C_MSL,
					range = 3200,
					reloadtime = 1.8,
					burst = 6,
					burstrate = 0.08,
					weaponvelocity = 6000,
					startvelocity = 3000,
					weaponacceleration = 4800,
					flighttime = 8.0,
					tracks = true,
					turnrate = 200e3,
					dance = 0,
					wobble = 0,
					areaofeffect = 220,
					energypershot = 12000,
					damage = D(3000, 96000, 20000),
					soundhit = "packaahit",
					soundstart = "packaamissiles",
					onlytargetcategory = T_V,
				})
				setMissileVis(u.weapondefs.NEEDLE_SWARM, false)
			end,
		},
		-- 3. BLACKOUT CASCADE
		{
			"player_blackoutcascade",
			{ "corflak", "armflak" },
			{ 290e3, 600e4, 230e3, 3, 28000, 1000, 2200 },
			"Blackout Cascade",
			"Wide-area AA EMP battery",
			function(u, src)
				installWeapon(u, src, 1, "BLACKOUT_CASCADE", {
					weapontype = C_CAN,
					range = 1900,
					reloadtime = 3.5,
					burst = 8,
					burstrate = 0.08,
					sprayangle = 1200,
					accuracy = 260,
					areaofeffect = 700,
					weaponvelocity = 2600,
					energypershot = 14e3,
					paralyzer = true,
					paralyzetime = 18,
					damage = D(400, 140e3, nil, 400),
					explosiongenerator = "custom:emp_m_preventable",
					soundhit = "emparm",
					soundstart = S_CAN2,
					onlytargetcategory = T_V,
				})
			end,
		},
		-- 4. PHALANX SKYBEAM
		{
			"player_phalanxlance",
			{ "armflak", "armmercury" },
			{ 310e3, 660e4, 250e3, 3, 30000, 800, 1600 },
			"Phalanx Skybeam",
			"Rapid close-range anti-air point defense beam",
			function(u, src)
				installWeapon(u, src, 1, "PHALANX_SKYBEAM", {
					weapontype = C_BLAS,
					largebeamlaser = true,
					range = 1600,
					reloadtime = 0.04,
					beamtime = 0.034,
					beamttl = 2,
					thickness = 4.0,
					corethickness = 0.40,
					energypershot = 2400,
					laserflaresize = 3,
					damage = D(450, 18000, 6000),
					explosiongenerator = "custom:laserhit-small-blue",
					rgbcolor = "0.2 0.9 1",
					soundstart = S_BLAS,
					soundtrigger = 1,
					onlytargetcategory = T_V,
				})
			end,
		},
		-- 5. QUAKE DOOM
		{
			"player_quakedoom",
			{ "armbrtha", "corint" },
			{ 820e3, 1750e4, 850e3, 2, 56000, 700, 3200 },
			"Quake Doom",
			"Cratering siege artillery",
			function(u, src)
				installWeapon(u, src, 1, "QUAKE_DOOM", {
					weapontype = C_CAN,
					range = 5400,
					reloadtime = 2.8,
					energypershot = 110e3,
					accuracy = 420,
					areaofeffect = 1400,
					weaponvelocity = 2800,
					impulsefactor = 50,
					impulseboost = 35,
					craterboost = 16.0,
					cratermult = 12.0,
					camerashake = 160,
					size = 16.0,
					damage = D(310e3, nil, 240e3, 48e3),
					cegtag = "arty-huge",
					explosiongenerator = "custom:genericshellexplosion-huge",
					soundhit = "lrpcexplo",
					soundhitwet = "splshbig",
					onlytargetcategory = T_S,
				})
			end,
		},
		-- 6. NULL CATHEDRAL
		{
			"player_nullcathedral",
			{ "corint", "armbrtha" },
			{ 780e3, 1650e4, 820e3, 2, 54000, 800, 2800 },
			"Null Cathedral",
			"Strategic long-range ground EMP artillery",
			function(u, src)
				installWeapon(u, src, 1, "NULL_CATHEDRAL", {
					weapontype = C_CAN,
					range = 3800,
					reloadtime = 3.5,
					energypershot = 140e3,
					accuracy = 280,
					areaofeffect = 1500,
					weaponvelocity = 2400,
					paralyzer = true,
					paralyzetime = 28,
					camerashake = 140,
					size = 15.0,
					rgbcolor = "0.2 0.6 1",
					damage = D(180e3, nil, nil, 180e3),
					explosiongenerator = "custom:emp_l_preventable",
					soundhit = "emparm",
					onlytargetcategory = T_S,
				})
			end,
		},
		-- 7. HIVE ARRAY
		{
			"player_hivearray",
			{ "legstarfall", "corint" },
			{ 840e3, 1800e4, 780e3, 2, 58000, nil, 3200 },
			"Hive Array",
			"Guided missile barrage fortress",
			function(u, src)
				installWeapon(u, src, 1, "HIVE_ARRAY", {
					weapontype = C_MSL,
					range = 4000,
					reloadtime = 0.06,
					trajectoryheight = 1.5,
					startvelocity = 600,
					weaponvelocity = 3800,
					weaponacceleration = 2400,
					flighttime = 14.0,
					avoidfriendly = true,
					avoidfeature = true,
					avoidground = true,
					tracks = true,
					turnrate = 190e3,
					dance = 3,
					wobble = 60,
					areaofeffect = 200,
					energypershot = 4200,
					damage = D(7200, 32000, 18000),
					soundstart = "rocklit1",
					onlytargetcategory = T_SV,
				})
				setMissileVis(u.weapondefs.HIVE_ARRAY, true)
			end,
		},
		-- 8. AEGIS ERASER
		{
			"player_aegiseraser",
			{ "armanni", "cordoom" },
			{ 820e3, 1750e4, 860e3, 2, 56000, 1350, 2400 },
			"Aegis Eraser",
			"Dedicated multi-round shield-breaking battery",
			function(u, src)
				installWeapon(u, src, 1, "AEGIS_ERASER", {
					weapontype = C_CAN,
					range = 3400,
					reloadtime = 1.6,
					burst = 6,
					burstrate = 0.05,
					projectiles = 4,
					sprayangle = 650,
					accuracy = 90,
					areaofeffect = 280,
					weaponvelocity = 3600,
					energypershot = 18000,
					size = 9.0,
					rgbcolor = "0.1 0.9 1",
					damage = D(7500, nil, 180e3, 3500),
					explosiongenerator = "custom:genericshellexplosion-medium",
					soundhit = "xplomed2",
					soundstart = S_CAN1,
					onlytargetcategory = T_S,
				})
			end,
		},
		-- 9. EXECUTIONER
		{
			"player_executioner",
			{ "cordoom", "armanni" },
			{ 860e3, 1850e4, 860e3, 2, 60000, 1400, 2600 },
			"Executioner",
			"Heavy single-target continuous thermal beam",
			function(u, src)
				installWeapon(u, src, 1, "EXECUTIONER", {
					weapontype = C_BLAS,
					largebeamlaser = true,
					range = 3600,
					reloadtime = 1.6,
					beamtime = 1.0,
					beamttl = 170,
					energypershot = 180e3,
					thickness = 8,
					corethickness = 0.80,
					laserflaresize = 5,
					firestarter = 100,
					damage = D(280e3, nil, 180e3, 50e3),
					texture3 = "largebeam",
					tilelength = 150,
					explosiongenerator = "custom:laserhit-large-red",
					rgbcolor = "1 0.12 0.02",
					soundstart = S_ANNI,
					onlytargetcategory = T_S,
				})
			end,
		},
		-- 10. PRISM CATHEDRAL
		{
			"player_prismcathedral",
			{ "cordoom" },
			{ 880e3, 1900e4, 880e3, 2, 62000, 1350, 2600 },
			"Prism Cathedral",
			"Three-channel independent beam fortress",
			function(u, src)
				local cfgs = {
					{ "0.75 0.15 1.0", 16, 0.70 },
					{ "0.50 0.10 0.95", 15, 0.65 },
					{ "0.95 0.35 0.95", 17, 0.75 },
				}
				for slot = 1, 3 do
					local cfg = cfgs[slot]
					installWeapon(u, src, slot, "PRISM_BEAM_" .. slot, {
						weapontype = C_BLAS,
						largebeamlaser = true,
						range = 3400,
						reloadtime = 1.2,
						beamtime = 0.55,
						beamttl = 22,
						energypershot = 44000,
						thickness = cfg[2] * 0.8,
						corethickness = cfg[3] * 0.8,
						laserflaresize = 5,
						firestarter = 100,
						damage = D(76e3, nil, 175e3, 18e3),
						texture3 = "largebeam",
						tilelength = 150,
						explosiongenerator = "custom:laserhit-large-blue",
						rgbcolor = cfg[1],
						soundstart = S_ANNI,
						onlytargetcategory = T_S,
					})
				end
			end,
		},
		-- 11. HYPERION LANCE
		{
			"player_hyperionlance",
			{ "armannit3", "armanni" },
			{ 1150e3, 2500e4, 1000e3, 2, 80000, 1450, 2900 },
			"Hyperion Lance",
			"Experimental super-heavy obliteration beam",
			function(u, src)
				installWeapon(u, src, 1, "HYPERION_LANCE", {
					weapontype = C_BLAS,
					largebeamlaser = true,
					range = 4000,
					reloadtime = 4.0,
					beamtime = 1.5,
					beamttl = 250,
					energypershot = 540e3,
					thickness = 10,
					corethickness = 0.90,
					laserflaresize = 6,
					firestarter = 100,
					damage = D(1100e3, nil, 600e3, 160e3),
					texture3 = "largebeam",
					tilelength = 150,
					explosiongenerator = "custom:laserhit-large-sparks",
					rgbcolor = "1 0.65 0.05",
					soundstart = S_ANNI,
					onlytargetcategory = T_S,
				})
			end,
		},
-- 12. AEGIS ORBITFALL: Autonomous Kinetic Rail Battery
		{
			"player_orbitfall",
			{ "legstarfall", "armbrtha", "corint" },
			{ 1200e3, 2600e4, 1050e3, 2, 84000, 950, 4800 },
			"Aegis Orbitfall",
			"Fully automatic continuous kinetic battery. Rains rapid precision hyper-velocity rods across strategic ranges.",
			function(u, src)
				u.hightrajectorytype = 2 -- Auto-calculate ballistic trajectory per target distance
				installWeapon(u, src, 1, "AEGIS_ORBITFALL", {
					weapontype = C_CAN,
					range = 8400,

					-- Rapid cyclic cadence: ~4 rounds every second without manual firing
					reloadtime = 0.25,
					burst = 1,
					projectiles = 1,

					-- Tight dispersion with slight natural scatter for self-sweeping barrages
					sprayangle = 240,
					accuracy = 85,

					-- Extreme muzzle velocity eliminates excessive shell travel delay
					weaponvelocity = 6400,
					mygravity = 0.35,

					areaofeffect = 360,
					edgeeffectiveness = 0.6,
					camerashake = 45,
					energypershot = 22000,

					craterboost = 3.0,
					cratermult = 2.0,
					impulsefactor = 6.0,
					impulseboost = 4.0,
					size = 9.5,

					-- 36,000 baseline / 85,000 shield damage per round (144k DPS sustained)
					damage = D(36e3, nil, 85e3, 11e3),
					cegtag = "railgun-trail-blue",
					explosiongenerator = "custom:genericshellexplosion-medium",
					soundstart = S_CAN1,
					soundhit = "rflrpcexplo",
					soundhitwet = "splshbig",
					onlytargetcategory = T_S,
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
			st[1], st[2] = st[1] * 0.20, st[2] * 0.20
			u.unitname, u.name = spec[1], spec[1]
			u.health, u.maxdamage = st[3], st[3]
			u.metalcost, u.energycost, u.buildtime = st[1], st[2], st[2]
			u.energyupkeep, u.energyuse = st[5] * TURRET_ENERGY_FACTOR, st[5] * TURRET_ENERGY_FACTOR
			if st[6] then
				u.sightdistance = st[6]
			end
			if st[7] then
				u.radardistance = st[7]
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
			u.maxthisunit = st[4]

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
					weapontype = C_CAN,
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
						onlytargetcategory = sSlot and sSlot.onlytargetcategory or T_S,
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
