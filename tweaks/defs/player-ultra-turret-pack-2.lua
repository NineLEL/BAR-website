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
					beamtime = 0.03,
					beamttl = 2,
					thickness = 9.0,
					corethickness = 1.60,
					laserflaresize = 16,
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

		-- 3. GRAVITY WELL: Kinetic Displacement Pulse
		{
			"player_gravitywell",
			{ "armbrtha", "corint" },
			{ 520e3, 1100e4, 1200e4, 560e3, 3, 26000, 750, 2000 },
			"Gravity Well",
			"Heavy kinetic displacement launcher that scatters advancing assault groups",
			function(u, src)
				installWeapon(u, src, 1, "GRAVITY_PULSE", {
					weapontype = "Cannon",
					range = 2600,
					reloadtime = 3.5,
					accuracy = 380,
					areaofeffect = 1100,
					weaponvelocity = 700,
					energypershot = 52000,
					impulsefactor = 90.0,
					impulseboost = 60.0,
					craterboost = 12.0,
					cratermult = 9.0,
					camerashake = 180,
					size = 15.0,
					rgbcolor = "0.3 0.1 0.5",
					damage = { default = 2200, shields = 38000, commandertoo = 800 },
					cegtag = "arty-large",
					explosiongenerator = "custom:genericshellexplosion-huge",
					soundhit = "lrpcexplo",
					soundstart = "cannhvy2",
					onlytargetcategory = "SURFACE",
				})
			end,
		},

		-- 4. THORN NEST: Cheap Anti-Rush Flechette Shotgun
		{
			"player_thornnest",
			{ "corpun", "armguard" },
			{ 240e3, 520e4, 560e4, 320e3, 5, 14000, 650, 1300 },
			"Thorn Nest",
			"Rapid close-range flechette shotgun for anti-swarm defense",
			function(u, src)
				installWeapon(u, src, 1, "THORN_SHOTGUN", {
					weapontype = "Cannon",
					range = 1200,
					reloadtime = 0.5,
					burst = 30,
					burstrate = 0.015,
					sprayangle = 2000,
					accuracy = 600,
					areaofeffect = 140,
					weaponvelocity = 3200,
					energypershot = 1400,
					damage = { default = 2400, vtol = 9000, shields = 1600, commandertoo = 600 },
					size = 5.0,
					explosiongenerator = "custom:genericshellexplosion-tiny",
					soundhit = "xplosml2",
					soundstart = "cannon1",
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

		-- 6. LEVIATHAN TRAP: Single-Target Stasis Clamp
		{
			"player_leviathantrap",
			{ "armemp", "corgate" },
			{ 480e3, 1000e4, 1100e4, 520e3, 3, 30000, 850, 2200 },
			"Leviathan Trap",
			"Specialist stasis mortar that locks down high-threat priority units",
			function(u, src)
				installWeapon(u, src, 1, "LEVIATHAN_STASIS", {
					weapontype = "MissileLauncher",
					range = 2600,
					reloadtime = 4.0,
					weaponvelocity = 900,
					startvelocity = 500,
					weaponacceleration = 300,
					flighttime = 10.0,
					tracks = true,
					turnrate = 90e3,
					areaofeffect = 200,
					energypershot = 120e3,
					paralyzer = true,
					paralyzetime = 120,
					damage = { default = 600, commandertoo = 600 },
					smoketrail = false,
					cegtag = nil,
					explosiongenerator = "custom:emp_l_preventable",
					soundhit = "emparm",
					soundstart = "rocklit1",
					onlytargetcategory = "SURFACE VTOL",
				})
			end,
		},

		-- 7. SWARM REAPER: Area Saturation Canister Battery
		{
			"player_swarmreaper",
			{ "armbrtha", "corint" },
			{ 600e3, 1300e4, 1400e4, 700e3, 3, 30000, 800, 2500 },
			"Swarm Reaper",
			"Medium-range canister artillery that blankets clustered formations in shrapnel",
			function(u, src)
				installWeapon(u, src, 1, "SWARM_REAPER", {
					weapontype = "Cannon",
					range = 2800,
					reloadtime = 1.6,
					projectilespershot = 20,
					sprayangle = 1500,
					accuracy = 480,
					areaofeffect = 300,
					weaponvelocity = 3000,
					energypershot = 16000,
					size = 9.0,
					damage = { default = 5200, shields = 14000, commandertoo = 1200 },
					cegtag = "arty-small",
					explosiongenerator = "custom:genericshellexplosion-medium",
					soundhit = "xplomed2",
					soundstart = "cannhvy2",
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
				reloadtime = 0.3, -- Starts the next salvo almost immediately

			-- 16 waves of 12 shells = 192 shells launched every cycle
			burst = 24,
			burstrate = 0.02,
			projectilespershot = 20,

			-- Broad geyser fountain dispersion
			sprayangle = 1100,
			accuracy = 320,

			-- Crucial for keeping them in the sky:
			hightrajectory = 1,
			weaponvelocity = 1300, -- Slower speed = longer hang time in the air
			mygravity = 0.55, -- Floats the arc higher for dramatic hang-time

			-- AoE & Impact
			areaofeffect = 1400,
			edgeeffectiveness = 0.9,
			energypershot = 2600, -- Kept manageable so 480 shells don't instantly stall the grid

			-- Visual Presence
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

			-- 192 shells * 1800 dmg = ~345,600 raw barrage damage
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

			-- COB DETONATE_WEAPON slot mismatch fix
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
