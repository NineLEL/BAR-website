do
	local U, L = UnitDefs, string.lower
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
				local h = false
				for _, x in ipairs(u.buildoptions) do
					if x == dst then
						h = true
						break
					end
				end
				if not h then
					u.buildoptions[#u.buildoptions + 1] = dst
				end
			end
		end
	end
	local function install(u, k, w, cat)
		k = k:lower()
		u.weapondefs, u.weapons = u.weapondefs or {}, u.weapons or {}
		local ow, st = u.weapons, w.is_suite and w.slots or { [1] = w }
		u.weapons = {}
		for i, v in pairs(st) do
			local sk = w.is_suite and (k .. "_" .. i) or k
			v.noselfdamage, v.turret = true, true
			u.weapondefs[sk] = C(v)
			local m = { def = sk, onlytargetcategory = v.onlytargetcategory or cat }
			if ow[i] then
				for pk, pv in pairs(ow[i]) do
					if
						pk ~= "def"
						and m[pk] == nil
						and pk ~= "onlytargetcategory"
						and (w.is_suite or (pk ~= "maindir" and pk ~= "maxangledif"))
					then
						m[pk] = C(pv)
					end
				end
			end
			u.weapons[i] = m
		end
		if #ow > #u.weapons then
			local dk = k .. "_d"
			u.weapondefs[dk] = {
				weapontype = "Cannon",
				range = 1,
				reloadtime = 9999,
				damage = { default = 0 },
				noselfdamage = true,
				turret = true,
				explosiongenerator = "custom:genericshellexplosion-tiny",
			}
			for s = #u.weapons + 1, #ow do
				local sl = ow[s]
				local d = { def = dk, onlytargetcategory = "NONE", badtargetcategory = "ALL" }
				if sl then
					d.maindir, d.maxangledif = sl.maindir, sl.maxangledif
				end
				u.weapons[s] = d
			end
		end
	end
	local function findSrc(c)
		for i = 1, #c do
			local s = U[c[i]] or U[L(c[i])] or (UnitDefNames and (UnitDefNames[c[i]] or UnitDefNames[L(c[i])]))
			if s then
				return s, c[i]
			end
		end
	end

	local LG = "armshltx corgant leggant everyexpe"
	local EA = "armapt3 corapt3 legapt3 everyexpe"
	local function getAir()
		for b in EA:gmatch("%S+") do
			if U[b] or (UnitDefNames and UnitDefNames[b]) then
				return EA
			end
		end
		return "armaap coraap legaap"
	end

	local S_C, S_N, S_M, S_F, S_R =
		"weapons/cannon_heavy.wav",
		"weapons/xplonuk4.wav",
		"weapons/xplomed1.wav",
		"weapons/flak_fire.wav",
		"weapons/rockhvy1.wav"
	local C_T, C_F, C_B, E_F, E_E, E_S =
		"cruisemissiletrail-tacnuke",
		"flakshard",
		"burnflame",
		"custom:FLASHNUKE280",
		"custom:exp_emp_large",
		"custom:genericshellexplosion-huge"
	local TS, TV, TSV = "SURFACE", "VTOL", "SURFACE VTOL"

	local function W(n, t, r, rel, v, aoe, e, d, s, c, vt, ex)
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
		if ex then
			for k, val in pairs(ex) do
				o[k] = val
			end
		end
		return o
	end

	local WP = {
		jump = W(
			"Rift Cannon",
			"Cannon",
			3200,
			4.2,
			1800,
			650,
			48e3,
			28e3,
			42e3,
			8e3,
			nil,
			{
				accuracy = 180,
				size = 22,
				stages = 36,
				alpha = 0.9,
				intensity = 2,
				rgbcolor = "0 0.95 1",
				cegtag = C_T,
				explosiongenerator = E_F,
				soundstart = S_C,
				soundhitdry = S_M,
				craterboost = 5,
				cratermult = 3.5,
				impulsefactor = 12,
				impulseboost = 8,
				camerashake = 110,
				onlytargetcategory = TS,
			}
		),
		vortex = W(
			"Vortex Well",
			"Cannon",
			3000,
			4.5,
			1400,
			700,
			42e3,
			16e3,
			45e3,
			4500,
			nil,
			{
				accuracy = 160,
				size = 23,
				stages = 32,
				rgbcolor = "0.35 0.05 0.55",
				cegtag = "heatcloud-rot-purple",
				explosiongenerator = E_E,
				soundstart = S_C,
				soundhitdry = S_N,
				impulsefactor = -14,
				impulseboost = -9,
				craterboost = 0,
				cratermult = 0,
				camerashake = 120,
				onlytargetcategory = TS,
			}
		),
		crack = W(
			"Sabot Shotgun",
			"Cannon",
			2400,
			3.2,
			2400,
			240,
			28e3,
			9600,
			38e3,
			3500,
			nil,
			{
				projectilespershot = 8,
				burst = 2,
				burstrate = 0.08,
				sprayangle = 850,
				customparams = { shotgun = true },
				accuracy = 320,
				separation = 0.8,
				size = 10,
				stages = 24,
				rgbcolor = "1 0.5 0.1",
				cegtag = "volcano_rock_trail",
				explosiongenerator = "custom:genericshellexplosion-medium",
				soundstart = S_C,
				soundhitdry = S_M,
				craterboost = 3,
				cratermult = 2,
				edgeeffectiveness = 0.85,
				onlytargetcategory = TS,
			}
		),
		sol = W(
			"Cataclysm",
			"Cannon",
			3400,
			5.5,
			520,
			850,
			95e3,
			48e3,
			11e4,
			14e3,
			nil,
			{
				accuracy = 100,
				edgeeffectiveness = 0.85,
				burnblow = true,
				firestarter = 100,
				size = 44,
				stages = 48,
				intensity = 3.5,
				alpha = 0.95,
				rgbcolor = "1 0.45 0.02",
				cegtag = C_B,
				explosiongenerator = "custom:FLASHNUKE480",
				soundstart = S_C,
				soundhitdry = S_N,
				craterboost = 7,
				cratermult = 5,
				impulsefactor = 14,
				impulseboost = 9,
				camerashake = 180,
				onlytargetcategory = TS,
			}
		),
		flak = W(
			"Flak Storm",
			"Cannon",
			2400,
			1.8,
			3200,
			320,
			800,
			600,
			3200,
			nil,
			9800,
			{
				canattackground = false,
				burnblow = true,
				burst = 6,
				burstrate = 0.12,
				projectilespershot = 4,
				sprayangle = 1800,
				edgeeffectiveness = 0.9,
				size = 8,
				rgbcolor = "1 0.45 0.1",
				cegtag = C_F,
				explosiongenerator = "custom:flakshard",
				soundstart = S_F,
				soundhitdry = S_F,
				onlytargetcategory = TV,
			}
		),
		tesla = W(
			"Tesla Battery",
			"LightningCannon",
			1800,
			1.2,
			4200,
			140,
			650,
			1600,
			1800,
			550,
			4200,
			{
				projectilespershot = 4,
				burst = 10,
				burstrate = 0.08,
				sprayangle = 2000,
				thickness = 12,
				rgbcolor = "0.2 0.85 1",
				explosiongenerator = "custom:genericshellexplosion-small-lightning",
				soundstart = "weapons/tecl_fire.wav",
				soundhitdry = "weapons/lashit.wav",
				edgeeffectiveness = 0.85,
				onlytargetcategory = TSV,
			}
		),
		pyro = W(
			"Carpet Mortar",
			"Cannon",
			2400,
			3.6,
			1100,
			260,
			750,
			5200,
			16e3,
			1200,
			nil,
			{
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
				cegtag = C_B,
				explosiongenerator = "custom:napalm_fire",
				soundstart = S_C,
				soundhitdry = "weapons/xplomed2.wav",
				edgeeffectiveness = 0.85,
				cratermult = 0.2,
				camerashake = 45,
				onlytargetcategory = TS,
			}
		),
		emp = W(
			"Atmospheric EMP",
			"Cannon",
			2600,
			5.5,
			1600,
			750,
			60e3,
			24e3,
			52e3,
			8e3,
			nil,
			{
				paralyzer = true,
				paralyzetime = 10,
				accuracy = 200,
				size = 26,
				stages = 36,
				intensity = 2.2,
				rgbcolor = "0.6 0.1 0.95",
				cegtag = "heatcloud-rot-purple",
				explosiongenerator = E_E,
				soundstart = S_C,
				soundhitdry = "weapons/xplomed2.wav",
				onlytargetcategory = TSV,
			}
		),
		a_m = W(
			"Siege Mortar",
			"Cannon",
			3100,
			3.8,
			2000,
			580,
			40e3,
			24e3,
			55e3,
			6500,
			nil,
			{
				accuracy = 220,
				sprayangle = 500,
				size = 18,
				stages = 28,
				rgbcolor = "0.9 0.8 0.2",
				cegtag = "arty-large",
				explosiongenerator = E_S,
				soundstart = S_C,
				soundhitdry = S_M,
				craterboost = 5,
				cratermult = 3.5,
				impulsefactor = 14,
				impulseboost = 9,
				camerashake = 120,
				firestarter = 100,
				onlytargetcategory = TS,
			}
		),
		a_s = W(
			"Deck Cannon",
			"Cannon",
			2000,
			0.6,
			2600,
			180,
			600,
			1800,
			4200,
			400,
			nil,
			{
				canattackground = true,
				accuracy = 250,
				sprayangle = 550,
				burst = 6,
				burstrate = 0.06,
				size = 6,
				rgbcolor = "1 0.85 0.3",
				explosiongenerator = "custom:genericshellexplosion-medium",
				soundstart = "weapons/cannhvy1.wav",
				soundhitdry = "weapons/xplomed2.wav",
				onlytargetcategory = TS,
			}
		),
		a_a = W(
			"SAM Array",
			"MissileLauncher",
			2200,
			1.4,
			3600,
			90,
			1400,
			800,
			2200,
			nil,
			6800,
			{
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
				soundstart = S_R,
				soundhitdry = "weapons/xplomed2.wav",
				onlytargetcategory = TV,
			}
		),
		torp = W(
			"Torpedo Launcher",
			"MissileLauncher",
			2600,
			4.2,
			1100,
			0,
			32e3,
			22e3,
			58e3,
			5200,
			nil,
			{
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
				cegtag = C_T,
				explosiongenerator = E_S,
				soundstart = S_R,
				soundhitdry = S_M,
				firestarter = 100,
				onlytargetcategory = TS,
			}
		),
		pshield = {
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
		},
		pbr = W(
			"Rift Barrage",
			"Cannon",
			2300,
			1.6,
			4200,
			180,
			6800,
			4200,
			9500,
			nil,
			nil,
			{
				canattackground = true,
				burst = 5,
				burstrate = 0.1,
				sprayangle = 520,
				size = 8,
				rgbcolor = "0.35 0.95 1",
				cegtag = C_T,
				explosiongenerator = "custom:genericshellexplosion-large",
				soundstart = "weapons/cannhvy1.wav",
				soundhitdry = "weapons/xplomed2.wav",
				onlytargetcategory = TS,
			}
		),
		vulc = W(
			"Rotary Vulcan",
			"Cannon",
			1800,
			2.4,
			3800,
			0,
			220,
			1200,
			1600,
			350,
			3600,
			{
				burst = 60,
				burstrate = 0.02,
				sprayangle = 900,
				accuracy = 320,
				size = 6,
				stages = 18,
				rgbcolor = "1 0.7 0.15",
				cegtag = C_F,
				explosiongenerator = "custom:genericshellexplosion-small",
				soundstart = S_F,
				soundhitdry = "weapons/xplosml2.wav",
				edgeeffectiveness = 0.85,
				onlytargetcategory = TSV,
			}
		),
		apol = W(
			"Apollyon Matrix",
			"Cannon",
			2200,
			1.6,
			3600,
			160,
			480,
			1600,
			3800,
			420,
			6200,
			{
				burst = 100,
				burstrate = 0.018,
				projectilespershot = 4,
				sprayangle = 1200,
				accuracy = 340,
				size = 6.5,
				stages = 20,
				rgbcolor = "1 0.82 0.2",
				cegtag = C_F,
				explosiongenerator = "custom:genericshellexplosion-small-lightning",
				soundstart = S_F,
				soundhitdry = "weapons/xplosml2.wav",
				edgeeffectiveness = 0.85,
				onlytargetcategory = TSV,
			}
		),
	}

	local SP = {
		{
			"player_riftcolossus",
			{ "armbanth" },
			"jump",
			WP.jump,
			"Rift Colossus",
			"Kinetic titan",
			{ 145e3, 32e5, 34e4, 56, 3, 2200, 0, 240 },
		},
		{
			"player_vortexdominator",
			{ "corjugg" },
			"vortex",
			WP.vortex,
			"Vortex Dominator",
			"Gravitational titan",
			{ 140e3, 30e5, 32e4, 48, 3, 2400, 0, 220 },
		},
		{
			"player_aegisbreaker",
			{ "armrattet4", "corjugg", "armbanth" },
			"crack",
			WP.crack,
			"Aegis Breaker",
			"Shotgun titan",
			{ 135e3, 28e5, 29e4, 52, 3, 2000, 0, 200 },
		},
		{
			"player_solardecimator",
			{ "corjugg", "armbanth" },
			"sol",
			WP.sol,
			"Sol Decimator",
			"Solar titan",
			{ 185e3, 44e5, 42e4, 38, 2, 2800, 6800, 360 },
		},
		{
			"player_skyfurnace",
			{ "corkarganetht4", "corkarg" },
			"flak",
			WP.flak,
			"Sky Furnace",
			"AA fortress",
			{ 120e3, 24e5, 26e4, 54, 4, 1800, 0, 180, 0, false, TV },
		},
		{
			"player_stormsovereign",
			{ "armraz", "armbanth" },
			"tesla",
			WP.tesla,
			"Storm Sovereign",
			"Tesla walker",
			{ 125e3, 26e5, 27e4, 62, 4, 1900, 0, 200 },
		},
		{
			"player_pyroclast",
			{ "armmar", "armbanth" },
			"pyro",
			WP.pyro,
			"Pyroclast Dreadnought",
			"Fire titan",
			{ 130e3, 27e5, 28e4, 50, 4, 2000, 0, 200 },
		},
		{
			"player_apollyonfortress",
			{ "legapollyon", "corpun", "corint" },
			"apollyon",
			WP.apol,
			"Apollyon Fortress",
			"Flak platform",
			{ 135e3, 29e5, 30e4, 46, 3, 2100, 0, 220 },
		},
	}

	local AB = getAir()

	for i = 1, #SP do
		local p = SP[i]
		local s = findSrc(p[2])
		if s and not U[p[1]] then
			local u = C(s)
			local st = p[7]
			local air = st[10]
			u.unitname, u.name, u.description = p[1], p[5], p[6]
			u.metalcost, u.energycost, u.buildtime = st[1], st[2], st[2]
			u.health, u.maxdamage = st[3], st[3]
			u.speed, u.maxthisunit, u.energyupkeep = st[4], st[5], st[6]
			u.energymake, u.autoheal = st[7] or 0, st[8] or 120
			u.sightdistance, u.radardistance =
				math.max(u.sightdistance or 0, 1100), math.max(u.radardistance or 0, 2600)
			u.activatewhenbuilt, u.builder, u.cantbetransported = true, false, true
			u.cancloak, u.cloakable, u.initcloaked = false, false, false
			u.radardistancejam = (st[9] and st[9] > 0) and st[9] or 0
			if p[1] == "player_phantomleviathan" then
				u.cancloak, u.cloakable, u.initcloaked, u.stealth = true, true, true, true
				u.cloakcost, u.cloakcostmoving, u.mincloakdistance, u.decloakdistance = 18, 42, 220, 140
				u.decloakonfire, u.decloaksonfire = false, false
				u.customparams = u.customparams or {}
				u.customparams.stealthhealth, u.customparams.stealthregen = 0.35, 240
			end
			if air then
				u.canfly, u.hoverattack, u.airhoverfactor, u.cruisealt, u.turnrate, u.collide =
					true, true, 0.15, 310, 480, true
				u.maxacc, u.maxdec = 0.08, 0.08
			else
				u.canfly, u.canhover, u.floater = false, false, false
				u.maxwaterdepth, u.upright = 48, true
			end
			u.customparams = u.customparams or {}
			u.customparams.techlevel, u.customparams.unitgroup = 4, "weapon"
			u.customparams.i18n_en_humanname, u.customparams.i18n_en_tooltip = p[5], p[6]
			if p[1] == "player_singularity" then
				local EG = "custom:genericbuildingexplosion-gigantic"
				u.explodeas, u.selfdestructas = "sing_d", "sing_s"
				u.weapondefs = u.weapondefs or {}
				u.weapondefs.sing_d = {
					weapontype = "Cannon",
					areaofeffect = 2400,
					edgeeffectiveness = 0.8,
					damage = { default = 5e5, commanders = 25e4 },
					explosiongenerator = EG,
				}
				u.weapondefs.sing_s = {
					weapontype = "Cannon",
					areaofeffect = 4200,
					edgeeffectiveness = 0.9,
					damage = { default = 15e5, commanders = 75e4 },
					explosiongenerator = EG,
				}
			end
			install(u, p[3], p[4], st[11])
			U[p[1]] = u
			if UnitDefNames then
				UnitDefNames[p[1]] = u
			end
			teach(air and AB or LG, p[1])
		end
	end
end
