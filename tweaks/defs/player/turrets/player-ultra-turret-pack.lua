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
					range = 1500,
					reloadtime = 1.2,
					burst = 60,
					burstrate = 0.015,
					sprayangle = 1600,
					accuracy = 400,
					areaofeffect = 120,
					weaponvelocity = 4200,
					energypershot = 900,
					onlytargetcategory = T_V,
					damage = D(900, 12000, 4000),
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
			"Long-range AA interceptor battery",
			function(u, src)
				installWeapon(u, src, 1, "NEEDLE_SWARM", {
					weapontype = C_MSL,
					range = 3200,
					reloadtime = 3.0,
					burst = 8,
					burstrate = 0.1,
					weaponvelocity = 5200,
					startvelocity = 2400,
					weaponacceleration = 3600,
					flighttime = 8.0,
					tracks = true,
					turnrate = 160e3,
					dance = 4,
					wobble = 90,
					areaofeffect = 220,
					energypershot = 12000,
					damage = D(2500, 68000, 16000),
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
					burst = 10,
					burstrate = 0.08,
					sprayangle = 1300,
					accuracy = 260,
					areaofeffect = 780,
					weaponvelocity = 2400,
					energypershot = 14000,
					paralyzer = true,
					paralyzetime = 45,
					damage = D(400, 5e5, nil, 400),
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
			{ "armmercury", "armflak" },
			{ 310e3, 660e4, 250e3, 3, 30000, 800, 1600 },
			"Phalanx Skybeam",
			"Rapid close-range anti-air point defense beam",
			function(u, src)
				installWeapon(u, src, 1, "PHALANX_SKYBEAM", {
					weapontype = C_BLAS,
					largebeamlaser = true,
					range = 1400,
					reloadtime = 0.02,
                    beamtime = 0.012,
					beamttl = 2,
                    thickness = 4.0,
                    corethickness = 0.40,
					energypershot = 1400,
                    laserflaresize = 3,
					damage = D(220, 9000, 3000),
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
			{ 900e3, 1900e4, 900e3, 2, 60000, 700, 3200 },
			"Quake Doom",
			"Cratering siege artillery",
			function(u, src)
				installWeapon(u, src, 1, "QUAKE_DOOM", {
					weapontype = C_CAN,
					range = 5200,
					reloadtime = 4.0,
					energypershot = 120e3,
					accuracy = 500,
					areaofeffect = 1600,
					weaponvelocity = 2600,
					impulsefactor = 60,
					impulseboost = 40,
					craterboost = 20.0,
					cratermult = 15.0,
					camerashake = 200,
					size = 16.0,
					damage = D(96000, nil, 52000, 20000),
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
			{ 880e3, 1850e4, 950e3, 2, 62000, 800, 2800 },
			"Null Cathedral",
			"Strategic long-range ground EMP artillery",
			function(u, src)
				installWeapon(u, src, 1, "NULL_CATHEDRAL", {
					weapontype = C_CAN,
					range = 3400,
					reloadtime = 4.5,
					energypershot = 180e3,
					accuracy = 320,
					areaofeffect = 1800,
					weaponvelocity = 2000,
					paralyzer = true,
					paralyzetime = 90,
					camerashake = 160,
					size = 15.0,
					rgbcolor = "0.2 0.6 1",
					damage = D(900, nil, nil, 900),
					explosiongenerator = "custom:emp_l_preventable",
					soundhit = "emparm",
					onlytargetcategory = T_S,
				})
			end,
		},
		-- 7. HIVE ARRAY
{
			"player_hivearray", { "legstarfall", "corint" }, { 920e3, 1900e4, 850e3, 2, 64000, nil, 3200 },
			"Hive Array", "Guided missile barrage fortress",
			function(u, src)
		installWeapon(u, src, 1, "HIVE_ARRAY", {
			weapontype = C_MSL,
			range = 4200,
			reloadtime = 0.02,

			-- Vertical clearing arc physics:
			trajectoryheight = 1.5, -- Forces steep vertical launch clearance
			startvelocity = 600, -- Slower initial launch to ascend cleanly
			weaponvelocity = 3800,
			weaponacceleration = 2400,
			flighttime = 14.0,

			-- Obstacle & friendly safety gates:
			avoidfriendly = true, -- Holds fire if friendly bases/units block line
			avoidfeature = true, -- Avoids rocks, trees, and wreckage
			avoidground = true, -- Prevents descending below ground plane mid-flight

			-- Guidance:
			tracks = true,
			turnrate = 190e3, -- Snappier correction once above obstacles
			dance = 3, -- Reduced early weave to stop clipping
			wobble = 60, -- Tighter flight pattern

			areaofeffect = 200,
			energypershot = 3200,
			damage = D(5200, 34000, 12000),
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
			{ 860e3, 1780e4, 900e3, 2, 58000, 1350, 2400 },
			"Aegis Eraser",
			"Dedicated multi-round shield-breaking battery",
			function(u, src)
				installWeapon(u, src, 1, "AEGIS_ERASER", {
					weapontype = C_CAN,
					range = 3400,
					reloadtime = 1.5,
					burst = 8,
					burstrate = 0.04,
					projectilespershot = 4,
					sprayangle = 700,
					accuracy = 90,
					areaofeffect = 300,
					weaponvelocity = 3600,
					energypershot = 26000,
					size = 9.0,
					rgbcolor = "0.1 0.9 1",
					damage = D(22000, nil, 340e3),
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
			{ 940e3, 1950e4, 880e3, 2, 66000, 1400, 2600 },
			"Executioner",
			"Heavy single-target continuous thermal beam",
			function(u, src)
				installWeapon(u, src, 1, "EXECUTIONER", {
					weapontype = C_BLAS,
					largebeamlaser = true,
					range = 3600,
					reloadtime = 2.0,
                    beamtime = 1.2,
					beamttl = 170,
					energypershot = 190e3,
                    thickness = 8,
                    corethickness = 0.80,
                    laserflaresize = 5,
					firestarter = 100,
					damage = D(165000, nil, 90000, 30000),
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
			{ 980e3, 2000e4, 920e3, 2, 70000, 1350, 2600 },
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
						damage = D(52000, nil, 145000, 12000),
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
			{ "cordoom", "armanni" },
			{ 1200e3, 2600e4, 1000e3, 2, 88000, 1450, 2900 },
			"Hyperion Lance",
			"Experimental super-heavy obliteration beam",
			function(u, src)
				installWeapon(u, src, 1, "HYPERION_LANCE", {
					weapontype = C_BLAS,
					largebeamlaser = true,
					range = 3800,
					reloadtime = 4.5,
                    beamtime = 1.5,
					beamttl = 250,
					energypershot = 620e3,
                    thickness = 10,
                    corethickness = 0.90,
                    laserflaresize = 6,
					firestarter = 100,
					damage = D(680000, nil, 420000, 120000),
					texture3 = "largebeam",
					tilelength = 150,
					explosiongenerator = "custom:laserhit-large-sparks",
					rgbcolor = "1 0.65 0.05",
					soundstart = S_ANNI,
					onlytargetcategory = T_S,
				})
			end,
		},
		-- 12. ASTRAEUS STARFALL
		{
			"player_starfallcataclysm",
			{ "legstarfall", "corint", "armbrtha" },
			{ 1300e3, 2800e4, 1100e3, 2, 94000, 800, 4200 },
			"Astraeus Starfall",
			"Orbital-arc siege artillery",
			function(u, src)
				u.hightrajectorytype = 1
				installWeapon(u, src, 1, "ASTRAEUS_STARFALL", {
					weapontype = C_CAN,
					range = 9200,
					reloadtime = 12.0,
					burst = 8,
					burstrate = 0.22,
					projectilespershot = 24,
					sprayangle = 900,
					accuracy = 140,
					hightrajectory = 1,
					weaponvelocity = 3400,
					areaofeffect = 1100,
					camerashake = 220,
					energypershot = 5200,
					craterboost = 8.0,
					cratermult = 6.0,
					impulsefactor = 16.0,
					impulseboost = 10.0,
					firestarter = 100,
					size = 14.0,
					damage = D(92000, nil, 210000, 18000),
					cegtag = "starfire",
					explosiongenerator = "custom:starfire-explosion",
					soundstart = S_CAN2,
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
			u.energyupkeep, u.energyuse = st[5], st[5]
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
