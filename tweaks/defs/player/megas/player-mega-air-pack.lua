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
						and pk ~= "maindir"
						and pk ~= "maxangledif"
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
		"cannhvy5",
		"xplonuk4",
		"xplomed1",
		"flakfire",
		"rockhvy1"
	local C_T, C_F, C_B, E_F, E_E, E_S =
		"cruisemissiletrail-tacnuke",
		"flaktrailaamg",
		"flamestreamxl",
		"custom:starfire-explosion",
		"custom:juno-explo",
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
			o.damage.commanders = c
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
		emp = W("Atmospheric EMP", "Cannon", 2600, 4.5, 1600, 750, 50e3, 140e3, 180e3, 20e3, nil, {
			paralyzer = true,
			paralyzetime = 12,
			accuracy = 200,
			size = 26,
			stages = 36,
			intensity = 2.4,
			rgbcolor = "0.55 0.15 1",
			cegtag = "juno_sphere_emit",
			explosiongenerator = E_E,
			soundstart = "junofir2",
			soundhitdry = "junohit2",
			onlytargetcategory = TSV,
		}),
		a_m = W("Siege Mortar", "Cannon", 2450, 5, 2000, 300, 4800, 9000, 11000, 3500, nil, {
			accuracy = 220,
			sprayangle = 500,
			size = 18,
			stages = 28,
			intensity = 2.4,
			rgbcolor = "1 0.72 0.25",
			cegtag = "arty-huge",
			explosiongenerator = E_S,
			soundstart = "bertha6",
			soundhitdry = "xplolrg3",
			craterboost = 5,
			cratermult = 3.5,
			impulsefactor = 14,
			impulseboost = 9,
			camerashake = 120,
			firestarter = 100,
			onlytargetcategory = TS,
		}),
		a_s = W("Deck Cannon", "Cannon", 1450, 1.2, 2600, 120, 300, 900, 1200, 300, nil, {
			canattackground = true,
			accuracy = 250,
			sprayangle = 550,
			burst = 6,
			burstrate = 0.06,
			size = 6.5,
			stages = 16,
			rgbcolor = "1 0.85 0.3",
			cegtag = "arty-small",
			explosiongenerator = "custom:genericshellexplosion-medium",
			soundstart = "cannhvy1",
			soundhitdry = "xplomed2",
			onlytargetcategory = TS,
		}),
		a_a = W("SAM Array", "MissileLauncher", 1750, 2, 3600, 55, 500, 100, 200, nil, 950, {
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
			texture1 = "null",
			texture2 = "smoketrailaa",
			cegtag = "missiletrailaa-large",
			explosiongenerator = "custom:genericshellexplosion-medium-aa",
			soundstart = "packolau",
			soundhitdry = "packohit",
			onlytargetcategory = TV,
		}),
		torp = W("Torpedo Launcher", "MissileLauncher", 1950, 5, 1100, 0, 2200, 5200, 6400, 2500, nil, {
			burst = 4,
			burstrate = 0.25,
			weaponacceleration = 500,
			flighttime = 10,
			tracks = true,
			turnrate = 60e3,
			dance = 15,
			wobble = 600,
			size = 14,
			stages = 22,
			rgbcolor = "0 1 0.6",
			cegtag = "cruisemissiletrail-starburst",
			explosiongenerator = "custom:plasmahit-huge",
			soundstart = "mismed1",
			soundhitdry = "xplolrg4",
			firestarter = 100,
			onlytargetcategory = TS,
		}),
		pshield = {
			weapontype = "Shield",
			shieldradius = 520,
			shieldpower = 45000,
			shieldpowerregen = 225,
			shieldpowerregenenergy = 125,
			shieldrepulser = true,
			shieldintercepttype = 1,
			shieldalpha = 0.36,
			shieldgoodcolor = "0.15 0.85 1 0.85",
			shieldbadcolor = "1 0.35 0.15 0.9",
			rgbcolor = "0.15 0.8 1",
			visibleshield = true,
		},
		pbr = W("Rift Barrage", "Cannon", 2300, 1.5, 4200, 180, 6800, 5600, 12e3, nil, nil, {
			canattackground = true,
			burst = 5,
			burstrate = 0.1,
			sprayangle = 520,
			size = 9,
			stages = 18,
			intensity = 2.0,
			rgbcolor = "0.3 0.92 1",
			cegtag = "tachyonshot",
			explosiongenerator = "custom:plasmahit-medium",
			soundstart = "railgun3",
			soundhitdry = "xplolrg3",
			onlytargetcategory = TS,
		}),
		vulc = W("Rotary Vulcan", "Cannon", 1800, 2.0, 3800, 0, 220, 1250, 2400, 350, 3600, {
			burst = 60,
			burstrate = 0.02,
			sprayangle = 900,
			accuracy = 320,
			size = 6.5,
			stages = 18,
			intensity = 1.6,
			rgbcolor = "1 0.72 0.18",
			cegtag = C_F,
			explosiongenerator = "custom:genericshellexplosion-small",
			soundstart = "flashemgxl",
			soundhitdry = "flashemgxlhit2",
			edgeeffectiveness = 0.85,
			onlytargetcategory = TSV,
		}),
		ionic = {
			name = "Ionic Pulse Beam",
			weapontype = "BeamLaser",
			range = 1500,
			reloadtime = 0.65,
			beamtime = 0.08,
			largebeamlaser = true,
			corethickness = 0.6,
			laserflaresize = 9,
			scrollspeed = 10,
			pulsespeed = 10,
			explosiongenerator = "custom:tachyonshot",
			beamttl = 3,
			rgbcolor = "0.3 0.92 1",
			rgbcolor2 = "0.8 0.98 1",
			thickness = 5,
			soundstart = "railgun3",
			soundtrigger = 1,
			damage = { default = 2600, vtol = 1800, shields = 4800 },
			energypershot = 220,
			onlytargetcategory = TSV,
		},
		plasmacluster = W("Plasma Cluster Torpedoes", "MissileLauncher", 2300, 4, 1500, 180, 1200, 3600, 4400, nil, nil, {
			burst = 4,
			burstrate = 0.3,
			startvelocity = 1200,
			weaponacceleration = 800,
			flighttime = 8,
			tracks = true,
			turnrate = 45e3,
			dance = 8,
			wobble = 200,
			size = 16,
			stages = 24,
			rgbcolor = "1 0.4 0.8",
			cegtag = "cruisemissiletrail-starburst",
			explosiongenerator = "custom:plasmahit-huge",
			soundstart = "mismed1",
			soundhitdry = "xplolrg4",
			firestarter = 120,
			onlytargetcategory = TV,
		}),
		javelin = W("Capacitor Javelin Swarm", "MissileLauncher", 2000, 2.4, 3200, 80, 500, 300, 500, nil, 900, {
			burst = 12,
			burstrate = 0.08,
			startvelocity = 1600,
			weaponacceleration = 1600,
			flighttime = 5,
			tracks = true,
			turnrate = 70e3,
			dance = 2,
			wobble = 60,
			size = 8,
			stages = 18,
			rgbcolor = "0.2 0.9 1",
			cegtag = "missiletrailaa-large",
			explosiongenerator = "custom:genericshellexplosion-medium-aa",
			soundstart = "packolau",
			soundhitdry = "packohit",
			onlytargetcategory = TSV,
		}),
	}

		local SP = {
		{
			"player_singularity",
			{ "corcrwt4", "corcrw" },
			"plasma",
			WP.plasmacluster,
			"Void Nexus",
			"Plasma cluster dreadnought",
			{ 75e3, 145e4, 165e3, 58, 2, 450, 0, 45, 0, true },
		},
		{
			"player_aethersiege",
			{ "armfepocht4", "armepocht4", "legfortt4" },
			"aether",
			{ is_suite = true, slots = { [1] = WP.a_a, [2] = WP.a_m, [3] = WP.a_s } },
			"Celestial Juggernaut",
			"Aerial flagship",
			{ 100e3, 195e4, 225e3, 44, 3, 650, 0, 65, 0, true },
		},
		{
			"player_phantomleviathan",
			{ "corcrwh", "corcrwt4" },
			"phantom",
			{ is_suite = true, slots = { [1] = WP.torp, [2] = WP.pshield, [3] = WP.javelin } },
			"Phantom Leviathan",
			"Cloaked dreadnought",
			{ 125e3, 245e4, 245e3, 62, 2, 750, 0, 75, 0, true },
		},
		{
			"player_archangel",
			{ "legfortt4", "corcrwt4", "corcrw" },
			"ionic",
			WP.ionic,
			"Sentinel Colossus",
			"Precision beam dreadnought",
			{ 70e3, 135e4, 155e3, 66, 3, 450, 0, 45, 0, true },
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
					areaofeffect = 850,
					edgeeffectiveness = 0.8,
					damage = { default = 30000, commanders = 7500 },
					explosiongenerator = EG,
				}
				u.weapondefs.sing_s = {
					weapontype = "Cannon",
					areaofeffect = 1400,
					edgeeffectiveness = 0.9,
					damage = { default = 75000, commanders = 18000 },
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
