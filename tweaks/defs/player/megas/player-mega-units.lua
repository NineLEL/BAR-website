do
	local U, lower = UnitDefs, string.lower
	local function C(t)
		if type(t) ~= "table" then
			return t
		end
		local r = {}
		for k, v in pairs(t) do
			r[C(k)] = C(v)
		end
		return r
	end

	local function teach(bld, dst)
		for b in bld:gmatch("%S+") do
			local u = U[b] or (UnitDefNames and UnitDefNames[b])
			if u then
				u.buildoptions = u.buildoptions or {}
				local has = false
				for _, x in ipairs(u.buildoptions) do
					if x == dst then
						has = true
						break
					end
				end
				if not has then
					u.buildoptions[#u.buildoptions + 1] = dst
				end
			end
		end
	end

	local function install(u, key, wep, cat)
		key = key:lower()
		u.weapondefs, u.weapons = u.weapondefs or {}, u.weapons or {}
		local oldW, suite = u.weapons, wep.is_suite and wep.slots or { [1] = wep }
		u.weapons = {}

		for idx, w in pairs(suite) do
			local k = wep.is_suite and (key .. "_" .. idx) or key
			w.noselfdamage, w.turret = true, true
			u.weapondefs[k] = C(w)
			local m = { def = k, onlytargetcategory = w.onlytargetcategory or cat }
			if oldW[idx] then
				for pk, pv in pairs(oldW[idx]) do
					if
						pk ~= "def"
						and m[pk] == nil
						and pk ~= "onlytargetcategory"
						and (wep.is_suite or (pk ~= "maindir" and pk ~= "maxangledif"))
					then
						m[pk] = C(pv)
					end
				end
			end
			u.weapons[idx] = m
		end

		if #oldW > #u.weapons then
			local dKey = key .. "_dummy"
			u.weapondefs[dKey] = {
				name = "Dummy",
				weapontype = "Cannon",
				range = 1,
				reloadtime = 9999,
				damage = { default = 0 },
				noselfdamage = true,
				turret = true,
				explosiongenerator = "custom:genericshellexplosion-tiny",
			}
			for sIdx = #u.weapons + 1, #oldW do
				local sSlot = oldW[sIdx]
				local dSlot = { def = dKey, onlytargetcategory = "NONE", badtargetcategory = "ALL" }
				if sSlot then
					dSlot.maindir, dSlot.maxangledif = sSlot.maindir, sSlot.maxangledif
				end
				u.weapons[sIdx] = dSlot
			end
		end
	end

	local function findSrc(c)
		for i = 1, #c do
			local s = U[c[i]] or U[lower(c[i])] or (UnitDefNames and (UnitDefNames[c[i]] or UnitDefNames[lower(c[i])]))
			if s then
				return s, c[i]
			end
		end
	end

	local LAND_GANTRIES = "armshltx corgant leggant everyexpe"
	local EXP_AIR = "armapt3 corapt3 legapt3 everyexpe"
	local FB_AIR = "armaap coraap legaap"
	local function getAir()
		for b in EXP_AIR:gmatch("%S+") do
			if U[b] or (UnitDefNames and UnitDefNames[b]) then
				return EXP_AIR
			end
		end
		return FB_AIR
	end

	local S_CNH, S_NU4, S_M1, S_M2, S_FLK_F, S_FLK_H, S_RCK, S_C1 =
		"weapons/cannon_heavy.wav",
		"weapons/xplonuk4.wav",
		"weapons/xplomed1.wav",
		"weapons/xplomed2.wav",
		"weapons/flak_fire.wav",
		"weapons/flak_hit.wav",
		"weapons/rockhvy1.wav",
		"weapons/cannhvy1.wav"

	local C_TAC, C_FLK, C_BRN, E_FN4, E_FN2, E_EMP, E_SHL =
		"cruisemissiletrail-tacnuke",
		"flakshard",
		"burnflame",
		"custom:FLASHNUKE480",
		"custom:FLASHNUKE280",
		"custom:exp_emp_large",
		"custom:genericshellexplosion-huge"

	local T_S, T_V, T_SV = "SURFACE", "VTOL", "SURFACE VTOL"
	local function W(n, t, r, rel, v, aoe, e, d, s, c, vt, extra)
		local o = {
			name = n,
			weapontype = t,
			range = r,
			reloadtime = rel,
			weaponvelocity = v,
			areaofeffect = aoe,
			energypershot = e,
			damage = { default = d },
		}
		if s then
			o.damage.shields = s
		end
		if c then
			o.damage.commandertoo = c
		end
		if vt then
			o.damage.vtol = vt
		end
		if extra then
			for k, val in pairs(extra) do
				o[k] = val
			end
		end
		return o
	end

	local WEAPONS = {
		jump = W("Rift Singularity Cannon", "Cannon", 3200, 4.2, 1800, 650, 48e3, 28e3, 42e3, 8e3, nil, {
			accuracy = 180,
			size = 18,
			stages = 36,
			alpha = 0.9,
			intensity = 2,
			rgbcolor = "0 0.95 1",
			cegtag = C_TAC,
			explosiongenerator = E_FN2,
			soundstart = S_CNH,
			soundhitdry = S_M1,
			craterboost = 5,
			cratermult = 3.5,
			impulsefactor = 12,
			impulseboost = 8,
			camerashake = 140,
			onlytargetcategory = T_S,
		}),
		vortex = W("Singularity Inversion Well", "Cannon", 3000, 4.5, 1400, 700, 42e3, 16e3, 45e3, 4500, nil, {
			accuracy = 160,
			size = 20,
			stages = 32,
			rgbcolor = "0.35 0.05 0.55",
			cegtag = "heatcloud-rot-purple",
			explosiongenerator = E_EMP,
			soundstart = S_CNH,
			soundhitdry = S_NU4,
			impulsefactor = -14,
			impulseboost = -9,
			craterboost = 0,
			cratermult = 0,
			camerashake = 120,
			onlytargetcategory = T_S,
		}),
		crack = W("Tungsten Sabot Shotgun", "Cannon", 2400, 3.2, 2400, 240, 28e3, 9600, 38e3, 3500, nil, {
			projectilespershot = 8,
			burst = 2,
			burstrate = 0.08,
			sprayangle = 850,
			accuracy = 320,
			separation = 0.8,
			size = 10,
			stages = 24,
			rgbcolor = "1 0.5 0.1",
			cegtag = "volcano_rock_trail",
			explosiongenerator = "custom:genericshellexplosion-medium",
			soundstart = S_CNH,
			soundhitdry = S_M1,
			craterboost = 3,
			cratermult = 2,
			edgeeffectiveness = 0.85,
			customparams = { shotgun = true, pellets = 16, pelletdamage = 600, maxrange = 2400 },
			onlytargetcategory = T_S,
		}),
		sol = W("Supernova Cataclysm", "Cannon", 3400, 5.5, 520, 850, 95e3, 48e3, 11e4, 14e3, nil, {
			accuracy = 100,
			edgeeffectiveness = 0.85,
			burnblow = true,
			firestarter = 100,
			size = 38,
			stages = 44,
			intensity = 3.5,
			alpha = 0.95,
			rgbcolor = "1 0.45 0.02",
			cegtag = C_BRN,
			explosiongenerator = E_FN4,
			soundstart = S_CNH,
			soundhitdry = S_NU4,
			craterboost = 7,
			cratermult = 5,
			impulsefactor = 14,
			impulseboost = 9,
			camerashake = 260,
			onlytargetcategory = T_S,
		}),
		flak = W("Thermite Flak Storm", "Cannon", 2400, 1.8, 3200, 320, 800, 600, 3200, nil, 9800, {
			canattackground = false,
			burnblow = true,
			burst = 24,
			burstrate = 0.03,
			sprayangle = 1800,
			edgeeffectiveness = 0.9,
			size = 8,
			rgbcolor = "1 0.45 0.1",
			cegtag = C_FLK,
			explosiongenerator = "custom:flakshard",
			soundstart = S_FLK_F,
			soundhitdry = S_FLK_H,
			onlytargetcategory = T_V,
		}),
		tesla = W("Tesla Chain Battery", "LightningCannon", 1800, 1.2, 4200, 140, 650, 1600, 1800, 550, 4200, {
			projectilespershot = 4,
			burst = 10,
			burstrate = 0.04,
			sprayangle = 2000,
			thickness = 12,
			rgbcolor = "0.2 0.85 1",
			explosiongenerator = "custom:genericshellexplosion-small-lightning",
			soundstart = "weapons/tecl_fire.wav",
			soundhitdry = "weapons/lashit.wav",
			edgeeffectiveness = 0.85,
			onlytargetcategory = T_SV,
		}),
		pyro = W("Carpet Fire Mortar", "Cannon", 2400, 3.6, 1100, 260, 750, 5200, 16e3, 1200, nil, {
			burst = 20,
			burstrate = 0.05,
			sprayangle = 1600,
			accuracy = 400,
			groundbounce = true,
			bouncerebound = 0.65,
			bounceminspeed = 200,
			numsubcatches = 3,
			firestarter = 100,
			size = 8.5,
			stages = 22,
			rgbcolor = "1 0.35 0.05",
			cegtag = C_BRN,
			explosiongenerator = "custom:napalm_fire",
			soundstart = S_CNH,
			soundhitdry = S_M2,
			edgeeffectiveness = 0.85,
			cratermult = 0.2,
			camerashake = 80,
			onlytargetcategory = T_S,
		}),
		beam = W("Annihilation Lance", "BeamLaser", 2600, 3.5, 0, 0, 65e3, 36e3, 68e3, 9e3, nil, {
			largebeamlaser = true,
			beamtime = 1.1,
			beamttl = 120,
			thickness = 7,
			corethickness = 0.65,
			laserflaresize = 5,
			pulsespeed = 8,
			scrollspeed = 8,
			rgbcolor = "0.75 0.05 1",
			rgbcolor2 = "0.45 0 0.85",
			firestarter = 100,
			explosiongenerator = E_FN2,
			soundstart = "weapons/beam_heavy.wav",
			soundhitdry = "weapons/burn02.wav",
			onlytargetcategory = T_S,
		}),
		emp = W("Atmospheric EMP", "Cannon", 2600, 5.5, 1600, 750, 60e3, 24e3, 52e3, 8e3, nil, {
			paralyzer = false,
			paralyzetime = 28,
			accuracy = 200,
			size = 22,
			stages = 32,
			intensity = 2.2,
			rgbcolor = "0.6 0.1 0.95",
			cegtag = "heatcloud-rot-purple",
			explosiongenerator = E_EMP,
			soundstart = S_CNH,
			soundhitdry = S_M2,
			customparams = { extra_damage = 95e3, paralyzemult = 1 },
			onlytargetcategory = T_SV,
		}),
		aether_main = W("Aether Siege Mortar", "Cannon", 3100, 3.8, 2000, 580, 40e3, 24e3, 55e3, 6500, nil, {
			accuracy = 220,
			sprayangle = 500,
			size = 18,
			stages = 28,
			rgbcolor = "0.9 0.8 0.2",
			cegtag = "arty-large",
			explosiongenerator = E_SHL,
			soundstart = S_CNH,
			soundhitdry = S_M1,
			craterboost = 5,
			cratermult = 3.5,
			impulsefactor = 14,
			impulseboost = 9,
			camerashake = 120,
			firestarter = 100,
			onlytargetcategory = T_S,
		}),
		aether_sec = W("Aether Deck Cannon", "Cannon", 2000, 0.6, 2600, 180, 600, 1800, 4200, 400, nil, {
			accuracy = 250,
			sprayangle = 550,
			burst = 6,
			burstrate = 0.06,
			size = 6,
			rgbcolor = "1 0.85 0.3",
			explosiongenerator = "custom:genericshellexplosion-medium",
			soundstart = S_C1,
			soundhitdry = S_M2,
			onlytargetcategory = T_S,
		}),
		aether_aa = W("Aether SAM", "MissileLauncher", 2200, 1.4, 3600, 90, 1400, 800, 2200, nil, 6800, {
			burst = 10,
			burstrate = 0.05,
			sprayangle = 450,
			startvelocity = 1400,
			weaponacceleration = 1800,
			flighttime = 6,
			tracks = true,
			turnrate = 95e3,
			dance = 4,
			wobble = 80,
			cegtag = "missiletrailaa",
			explosiongenerator = "custom:genericshellexplosion-medium-aa",
			soundstart = S_RCK,
			soundhitdry = S_M2,
			onlytargetcategory = T_V,
		}),
		torpedo = W("Voidstrike Torpedoes", "MissileLauncher", 2600, 4.2, 1100, 0, 32e3, 22e3, 58e3, 5200, nil, {
			burst = 4,
			burstrate = 0.25,
			weaponacceleration = 500,
			flighttime = 10,
			tracks = true,
			turnrate = 60e3,
			dance = 15,
			wobble = 600,
			size = 14,
			rgbcolor = "0 1 0.55",
			cegtag = C_TAC,
			explosiongenerator = E_SHL,
			soundstart = S_RCK,
			soundhitdry = S_M1,
			firestarter = 100,
			onlytargetcategory = T_S,
		}),
		pshield = {
			name = "Abyssal Phase Shield",
			weapontype = "Shield",
			shieldradius = 520,
			shieldpower = 125e3,
			shieldpowerregen = 950,
			shieldpowerregenenergy = 180,
			shieldrepulser = true,
			shieldintercepttype = 1,
			shieldalpha = 0.32,
			rgbcolor = "0.15 0.8 1",
			visibleshield = true,
			visibleShield = true,
		},
		pbarrage = W("Leviathan Rift Barrage", "Cannon", 2300, 1.6, 4200, 180, 6800, 4200, 9500, nil, nil, {
			burst = 5,
			burstrate = 0.1,
			sprayangle = 520,
			size = 8,
			rgbcolor = "0.35 0.95 1",
			cegtag = C_TAC,
			explosiongenerator = "custom:genericshellexplosion-large",
			soundstart = S_C1,
			soundhitdry = S_M2,
			onlytargetcategory = T_S,
		}),
		vulcan = W("Rotary Vulcan Array", "Cannon", 1800, 2.4, 3800, 0, 220, 1200, 1600, 350, 3600, {
			burst = 60,
			burstrate = 0.02,
			sprayangle = 900,
			accuracy = 320,
			size = 6,
			stages = 18,
			rgbcolor = "1 0.7 0.15",
			cegtag = C_FLK,
			explosiongenerator = "custom:genericshellexplosion-small",
			soundstart = S_FLK_F,
			soundhitdry = "weapons/xplosml2.wav",
			edgeeffectiveness = 0.85,
			onlytargetcategory = T_SV,
		}),
	}

	local SPECS = {
		{
			"player_riftcolossus",
			{ "armbanth" },
			"player_riftjump",
			WEAPONS.jump,
			"Rift Colossus",
			"Kinetic titan. Shockwaves.",
			{ 145e3, 32e5, 34e4, 56, 3, 2200, 0, 240 },
		},
		{
			"player_vortexdominator",
			{ "corjugg" },
			"player_vortexwell",
			WEAPONS.vortex,
			"Vortex Dominator",
			"Gravitational titan.",
			{ 140e3, 30e5, 32e4, 48, 3, 2400, 0, 220 },
		},
		{
			"player_aegisbreaker",
			{ "armrattet4", "corjugg", "armbanth" },
			"player_aegisbreaker",
			WEAPONS.crack,
			"Aegis Breaker",
			"Shotgun titan.",
			{ 135e3, 28e5, 29e4, 52, 3, 2000, 0, 200 },
		},
		{
			"player_solardecimator",
			{ "corjugg", "corkrog", "armbanth" },
			"player_solardecimator",
			WEAPONS.sol,
			"Sol Decimator",
			"Solar titan. Net +4000 E/s.",
			{ 185e3, 44e5, 42e4, 38, 2, 2800, 6800, 360 },
		},
		{
			"player_skyfurnace",
			{ "corkarganetht4", "corkarg", "corkrog" },
			"player_skyfurnace",
			WEAPONS.flak,
			"Sky Furnace",
			"AA fortress.",
			{ 120e3, 24e5, 26e4, 54, 4, 1800, 0, 180, 0, false, T_V },
		},
		{
			"player_stormsovereign",
			{ "armraz", "armbanth" },
			"player_stormtesla",
			WEAPONS.tesla,
			"Storm Sovereign",
			"Chaining tesla walker.",
			{ 125e3, 26e5, 27e4, 62, 4, 1900, 0, 200 },
		},
		{
			"player_pyroclast",
			{ "armmar", "armbanth" },
			"player_pyrocarpet",
			WEAPONS.pyro,
			"Pyroclast Dreadnought",
			"Fire titan.",
			{ 130e3, 27e5, 28e4, 50, 4, 2000, 0, 200 },
		},
		{
			"player_worldbeam",
			{ "corkarg", "corkrog" },
			"player_worldbeam",
			WEAPONS.beam,
			"World Beam",
			"Annihilation lance titan.",
			{ 140e3, 31e5, 30e4, 52, 3, 2500, 0, 220 },
		},
		{
			"player_singularity",
			{ "corcrwt4", "corcrw" },
			"player_singularityemp",
			WEAPONS.emp,
			"Singularity",
			"Aerial EMP dreadnought.",
			{ 150e3, 36e5, 28e4, 58, 2, 3200, 0, 220, 0, true },
		},
		{
			"player_aethersiege",
			{ "armfepocht4", "armepocht4", "armepoch_vtol", "armt4air", "armcybr", "legfortt4" },
			"player_aether",
			{
				is_suite = true,
				slots = { [1] = WEAPONS.aether_aa, [2] = WEAPONS.aether_main, [3] = WEAPONS.aether_sec },
			},
			"Aether Siege Fortress",
			"Aerial siege flagship.",
			{ 155e3, 35e5, 29e4, 52, 3, 2800, 0, 240, 0, true },
		},
		{
			"player_phantomleviathan",
			{ "corcrwh", "corcrwt4" },
			"player_phantomtorpedo",
			{ is_suite = true, slots = { [1] = WEAPONS.torpedo, [2] = WEAPONS.pshield, [3] = WEAPONS.pbarrage } },
			"Phantom Leviathan",
			"Cloaked dreadnought.",
			{ 220e3, 48e5, 42e4, 72, 4, 3200, 0, 420, 0, true },
		},
		{
			"player_archangel",
			{ "legfortt4", "corcrwt4", "corcrw" },
			"player_archangelvulcan",
			WEAPONS.vulcan,
			"Archangel Gunship",
			"Rotary Vulcan dreadnought.",
			{ 140e3, 31e5, 27e4, 66, 3, 2200, 0, 200, 0, true },
		},
	}

	local airBld = getAir()

	for i = 1, #SPECS do
		local p = SPECS[i]
		local s = findSrc(p[2])
		if s and not U[p[1]] then
			local u = C(s)
			local st = p[7]
			local isAir = st[10]

			u.unitname, u.name, u.description = p[1], p[5], p[6]
			u.metalcost, u.energycost, u.buildtime = st[1], st[2], st[2]
			u.health, u.maxdamage = st[3], st[3]
			u.speed, u.maxthisunit, u.energyupkeep = st[4], st[5], st[6]

			u.energymake = st[7] or 0
			u.autoheal = st[8] or 120
			u.sightdistance = math.max(u.sightdistance or 0, 1100)
			u.radardistance = math.max(u.radardistance or 0, 2600)
			u.activatewhenbuilt = true

			u.builder, u.buildoptions, u.cantbetransported = false, nil, true
			u.transportcapacity, u.transportsize = nil, nil
			u.cancloak, u.cloakable, u.initcloaked = false, false, false
			u.radardistancejam = (st[9] and st[9] > 0) and st[9] or 0
			if p[1] == "player_phantomleviathan" then
				u.cancloak, u.cloakable, u.initcloaked = true, true, true
				u.stealth = true
				u.cloakcost, u.cloakcostmoving = 18, 42
				u.mincloakdistance, u.decloakdistance = 220, 140
				u.decloakonfire, u.decloaksonfire = false, false
				u.customparams = u.customparams or {}
				u.customparams.stealthhealth = 0.35
				u.customparams.stealthregen = 240
			end

			if isAir then
				u.canfly, u.hoverattack, u.airhoverfactor = true, true, 0.15
				u.cruisealt, u.turnrate, u.collide = 310, 480, true
				u.maxacc, u.maxdec = 0.08, 0.08
			else
				u.canfly, u.canhover, u.floater = false, false, false
				u.minwaterdepth, u.maxwaterdepth, u.upright = nil, 48, true
			end

			u.customparams = u.customparams or {}
			u.customparams.techlevel, u.customparams.unitgroup = 4, "weapon"
			u.customparams.i18n_en_humanname = p[5]
			u.customparams.i18n_en_tooltip = p[6]

			install(u, p[3], p[4], st[11])
			U[p[1]] = u
			if UnitDefNames then
				UnitDefNames[p[1]] = u
			end
			teach(isAir and airBld or LAND_GANTRIES, p[1])
		end
	end
end
