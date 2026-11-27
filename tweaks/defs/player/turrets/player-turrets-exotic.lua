-- Exotic Mechanics Turret Pack (T4)
-- Eight mechanistically distinct turrets using verified BAR engine and gadget features:
-- airburst split artillery, cloaked overpenetrating railgun, chain-lightning spire,
-- sweepfire molten heat-ray, corrosive pool artillery, ricochet plasma glaive,
-- EW jammer/radar VLS bastion, and amphibious torpedo + shock-rail battery.
do
	local U, L = UnitDefs, string.lower

	local function C(v)
		if type(v) ~= "table" then
			return v
		end
		local r = {}
		for k, x in pairs(v) do
			r[C(k)] = C(x)
		end
		return r
	end

	local function FU(n)
		return n and (U[n] or U[L(n)])
	end

	local function FS(c)
		for i = 1, #c do
			local s = FU(c[i])
			if s then
				return s, c[i]
			end
		end
	end

	local function FW(u, d)
		if not (u and u.weapondefs) then
			return
		end
		if u.weapondefs[d] then
			return u.weapondefs[d]
		end
		local w = L(d)
		for n, x in pairs(u.weapondefs) do
			if L(n) == w then
				return x
			end
		end
	end

	local function GS(u, i)
		if not (u and u.weapons and u.weapons[i] and u.weapons[i].def) then
			return
		end
		local d = FW(u, u.weapons[i].def)
		return d and u.weapons[i], d
	end

	local function GSC(u)
		return u and u.weapons and #u.weapons or 0
	end

	local function TH(builders, dst)
		for b in builders:gmatch("%S+") do
			local bd = U[b]
			if bd then
				bd.buildoptions = bd.buildoptions or {}
				local ex = false
				for _, opt in ipairs(bd.buildoptions) do
					if opt == dst then
						ex = true
						break
					end
				end
				if not ex then
					bd.buildoptions[#bd.buildoptions + 1] = dst
				end
			end
		end
	end

	local function CU(nm, c)
		if U[nm] then
			return U[nm], U[nm], nm
		end
		local src, sn = FS(c)
		if not src then
			return
		end
		local u = C(src)
		U[nm] = u
		return u, src, sn
	end

	local function SN(u)
		for k in ("speed maxacc maxdec maxvelocity turnrate cloakcost cloakcostmoving energymake energyuse energyupkeep radardistancejam"):gmatch("%S+") do
			u[k] = 0
		end
		u.movementclass = nil
		for k in ("canmove canpatrol canfight canrepeat canassist canrepair canreclaim canresurrect cancapture turninplace cloakable cancloak initcloaked stealth builder"):gmatch("%S+") do
			u[k] = false
		end
		u.buildoptions, u.weapons, u.weapondefs = nil, {}, {}
		u.activatewhenbuilt, u.onoffable = true, true
	end

	local function LB(u, nm, tip)
		u.customparams = u.customparams or {}
		u.customparams.techlevel = 4
		for l in ("en de fr es it ru zh cs hr lt"):gmatch("%S+") do
			u.customparams["i18n_" .. l .. "_humanname"], u.customparams["i18n_" .. l .. "_tooltip"] = nm, tip
		end
	end

	local function I(u, src, ss, nn, ov, sov)
		local sSlot, sDef = GS(src, ss)
		if not (sSlot and sDef) then
			return false
		end
		local w = C(sDef)
		for k, v in pairs(ov or {}) do
			w[k] = C(v)
		end
		w.noselfdamage, w.turret = true, true
		u.weapondefs[nn] = w

		local s = C(sSlot)
		s.def = nn
		sov = sov or {}
		if w.onlytargetcategory and not sov.onlytargetcategory then
			sov.onlytargetcategory = w.onlytargetcategory
		end
		for k, v in pairs(sov) do
			s[k] = C(v)
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

	local T_S, T_SV, T_NA = "SURFACE", "SURFACE VTOL", "NOTAIR"
	local G, PH = "custom:genericshellexplosion-", "custom:plasmahit-"

	local SPECS = {
		-- 1. HELIOS SPLITTER: Mid-Air Apex Split Airburst Artillery
		{
			"player_sunsplitter",
			{ "legcluster", "corint" },
			{ 760e3, 1680e4, 620e3, 2, 42000, 950, 2800 },
			"Helios Splitter",
			"Solar airburst mortar splitting at apex into 14 blazing meteors.",
			function(u, src)
				u.hightrajectorytype = 1
				I(u, src, 1, "HELIOS_SHELL", {
					weapontype = "Cannon",
					range = 3800,
					reloadtime = 4.2,
					hightrajectory = 1,
					weaponvelocity = 1400,
					mygravity = 0.45,
					accuracy = 160,
					areaofeffect = 240,
					energypershot = 84000,
					size = 18,
					stages = 32,
					intensity = 3.0,
					alpha = 0.95,
					rgbcolor = "1 0.82 0.25",
					cegtag = "starfire_arty",
					explosiongenerator = "custom:starfire-explosion",
					soundstart = "lrpcshot3",
					soundhit = "xplomed4",
					customparams = {
						speceffect = "split",
						speceffect_def = "player_sunsplitter_sun_shard",
						number = 14,
						splitexplosionceg = "starfire-explosion",
						cegtag = "ministarfire",
						model = "",
					},
					damage = D(16000, nil, 24000, 3200),
					onlytargetcategory = T_S,
				})
				I(u, src, 2, "sun_shard", {
					weapontype = "Cannon",
					range = 1200,
					reloadtime = 9999,
					areaofeffect = 240,
					edgeeffectiveness = 0.65,
					impulsefactor = 6.0,
					craterboost = 2.0,
					cratermult = 1.5,
					camerashake = 55,
					size = 9,
					stages = 20,
					intensity = 2.2,
					rgbcolor = "1 0.72 0.2",
					cegtag = "ministarfire",
					explosiongenerator = "custom:ministarfire-explosion",
					soundstart = "cannhvy5",
					soundhit = "xplomed2",
					damage = D(11000, nil, 18000, 2200),
					onlytargetcategory = "NONE",
				}, { onlytargetcategory = "NONE", badtargetcategory = "ALL" })
			end,
		},
		-- 2. HYPERION SKEWER: Cloaked Pop-Up Overpenetrating Rail Sniper
		{
			"player_skewerspike",
			{ "armpb", "leglraa" },
			{ 680e3, 1520e4, 480e3, 3, 34000, 1250, 2200 },
			"Hyperion Skewer",
			"Cloaked ambush bunker firing overpenetrating rail slugs through killed targets.",
			function(u, src)
				u.cancloak = true
				u.initcloaked = true
				u.decloakonfire = true
				u.cloakcost = 60
				u.cloakcostmoving = 60
				u.mincloakdistance = 450
				u.stealth = true
				u.damagemodifier = 0.25
				I(u, src, 1, "HYPERION_SKEWER", {
					weapontype = "LaserCannon",
					range = 3200,
					reloadtime = 2.6,
					weaponvelocity = 7500,
					energypershot = 48000,
					duration = 0.09,
					thickness = 8.5,
					corethickness = 0.65,
					intensity = 2.6,
					areaofeffect = 16,
					impactonly = 1,
					noexplode = true,
					impulsefactor = 14.0,
					camerashake = 90,
					rgbcolor = "0.95 0.2 1",
					cegtag = "railgun-epic",
					explosiongenerator = PH .. "huge",
					soundstart = "heavyrailgun",
					soundhit = "sabothit",
					customparams = {
						overpenetrate = true,
						overpenetrate_falloff = true,
						overpenetrate_slowing = false,
						overpenetrate_penalty = 0.06,
					},
					damage = D(165e3, 140e3, 210e3, 24000),
					onlytargetcategory = T_SV,
				})
			end,
		},
		-- 3. ZEUS CONDUIT: True 7-Target Chain-Lightning Spire
		{
			"player_arcpylon",
			{ "corscavdtl", "legdtl", "armclaw" },
			{ 460e3, 1050e4, 420e3, 4, 24000, 950, 1900 },
			"Zeus Conduit",
			"Tesla spire whose lightning bolts fork across up to 7 nearby air or ground targets.",
			function(u, src)
				I(u, src, 1, "ZEUS_ARC", {
					weapontype = "LightningCannon",
					range = 1750,
					reloadtime = 1.6,
					burst = 4,
					burstrate = 0.06,
					weaponvelocity = 5400,
					energypershot = 9600,
					thickness = 16,
					beamttl = 2,
					duration = 1.6,
					intensity = 3.0,
					areaofeffect = 64,
					impactonly = 1,
					paralyzer = false,
					rgbcolor = "0.45 0.88 1",
					cegtag = "lightning_stormbolt",
					explosiongenerator = G .. "large-lightning-thor",
					soundstart = "electric2",
					soundhit = "xploelc2",
					soundtrigger = true,
					customparams = {
						spark_ceg = "genericshellexplosion-splash-large-lightning",
						spark_forkdamage = "0.45",
						spark_maxunits = "7",
						spark_range = "260",
					},
					damage = D(18000, 28000, 32000, 3200),
					onlytargetcategory = T_SV,
				})
			end,
		},
		-- 4. SOLARIS SWEEPER: Continuous Sweepfire Molten Heat-Ray
		{
			"player_chronosweep",
			{ "legbastion", "cordoomt3", "armanni" },
			{ 740e3, 1620e4, 720e3, 2, 46000, 1200, 2400 },
			"Solaris Sweeper",
			"Sweepfire heat-ray tower raking a continuous molten lance across formations.",
			function(u, src)
				I(u, src, 1, "SOLARIS_SWEEP", {
					weapontype = "BeamLaser",
					largebeamlaser = true,
					range = 2400,
					reloadtime = 3.2,
					beamtime = 0.12,
					beamttl = 8,
					energypershot = 24000,
					thickness = 11,
					corethickness = 0.65,
					laserflaresize = 12,
					scrollspeed = 14,
					pulsespeed = 12,
					firestarter = 100,
					areaofeffect = 180,
					edgeeffectiveness = 0.65,
					camerashake = 40,
					texture3 = "largebeam",
					tilelength = 150,
					rgbcolor = "1 0.55 0.05",
					rgbcolor2 = "1 0.96 0.65",
					explosiongenerator = "custom:heatray-huge",
					soundstart = "heatray3",
					soundtrigger = 1,
					customparams = {
						sweepfire_firetime = 2.6,
					},
					damage = D(14000, 9000, 26000, 2600),
					onlytargetcategory = T_SV,
				}, {
					fastautoretargeting = true,
					onlytargetcategory = T_SV,
				})
			end,
		},
		-- 5. VIPER CAULDRON: Persistent Corrosive Acid Pool Mortar
		{
			"player_blightmortar",
			{ "legacluster", "armguard", "corpun" },
			{ 560e3, 1260e4, 540e3, 3, 30000, 900, 2100 },
			"Viper Cauldron",
			"Acid mortar leaving 16-second shield-piercing corrosive pools.",
			function(u, src)
				I(u, src, 1, "VIPER_CAULDRON", {
					weapontype = "Cannon",
					range = 2800,
					reloadtime = 4.0,
					burst = 4,
					burstrate = 0.14,
					sprayangle = 650,
					accuracy = 140,
					weaponvelocity = 1800,
					areaofeffect = 240,
					edgeeffectiveness = 0.8,
					energypershot = 36000,
					size = 13,
					stages = 24,
					intensity = 2.2,
					rgbcolor = "0.25 1 0.15",
					cegtag = "sporetrail-large",
					explosiongenerator = "custom:acid-explosion-xl",
					soundstart = "rflrpc3",
					soundhit = "xplomed2",
					customparams = {
						area_onhit_ceg = "acid-area-150-repeat",
						area_onhit_damageceg = "acid-damage-gen",
						area_onhit_range = 150,
						area_onhit_time = 16,
						area_onhit_damage = 1400,
						area_onhit_resistance = "acid",
						area_onhit_shieldpen = true,
					},
					damage = D(18000, nil, 36000, 3600),
					onlytargetcategory = T_S,
				})
			end,
		},
		-- 6. VALKYRIE GLAIVE: Multi-Bounce Ricocheting Plasma Skimmer
		{
			"player_diskricochet",
			{ "armamb", "corpun" },
			{ 520e3, 1140e4, 460e3, 3, 28000, 950, 2000 },
			"Valkyrie Glaive",
			"Skimming plasma discs that ricochet up to 4 times over hills and water.",
			function(u, src)
				I(u, src, 1, "VALKYRIE_GLAIVE", {
					weapontype = "Cannon",
					range = 2400,
					reloadtime = 2.0,
					burst = 3,
					burstrate = 0.12,
					sprayangle = 420,
					accuracy = 110,
					weaponvelocity = 2400,
					mygravity = 0.22,
					flighttime = 6,
					areaofeffect = 210,
					edgeeffectiveness = 0.75,
					burnblow = false,
					groundbounce = true,
					waterbounce = true,
					numbounce = 4,
					bouncerebound = 0.78,
					bounceminspeed = 180,
					collidefriendly = false,
					energypershot = 22000,
					size = 12,
					stages = 26,
					intensity = 2.4,
					rgbcolor = "0.1 1 0.85",
					cegtag = "gausscannonprojectile",
					explosiongenerator = PH .. "medium",
					soundstart = "sabotfire",
					soundhit = "sabothit",
					damage = D(22000, nil, 42000, 4000),
					onlytargetcategory = T_S,
				})
			end,
		},
		-- 7. AEGIS VLS BASTION: EW Radar/Jammer Citadel & Vertical Dive-Strike Missiles
		{
			"player_vlsbastion",
			{ "legrampart", "cortron", "armemp" },
			{ 900e3, 2000e4, 720e3, 2, 48000, 1200, 3600 },
			"Aegis VLS Bastion",
			"EW radar/jammer citadel with auto-firing shield-piercing vertical cruise missiles.",
			function(u, src, sourceName)
				if sourceName == "legrampart" then
					u.yardmap = ("o"):rep(25)
				end
				u.radardistancejam = 950
				u.radaremitheight = 72
				u.customparams.geothermal = nil
				u.customparams.restrictions_exclusion = nil
				I(u, src, 1, "AEGIS_VLS_CRUISE", {
					weapontype = "StarburstLauncher",
					range = 4200,
					reloadtime = 5.0,
					burst = 4,
					burstrate = 0.22,
					stockpile = false,
					commandfire = false,
					tracks = true,
					turnrate = 42000,
					weaponvelocity = 2600,
					startvelocity = 200,
					weaponacceleration = 650,
					weapontimer = 1.6,
					flighttime = 12,
					areaofeffect = 320,
					edgeeffectiveness = 0.7,
					energypershot = 72000,
					interceptedbyshieldtype = 0,
					craterboost = 3.0,
					cratermult = 2.0,
					camerashake = 110,
					cegtag = "cruisemissiletrail-tacnuke",
					explosiongenerator = "custom:starfire-explosion",
					soundstart = "antinukelaunch",
					soundhit = "xplolrg4",
					customparams = {
						cruise_and_verticalize = true,
						uptime_max = 4,
						shield_aoe_penetration = true,
					},
					damage = D(44000, nil, 90000, 8000),
					onlytargetcategory = T_S,
				})
			end,
		},
		-- 8. LEVIATHAN MAW: Naval/Coastal Shock-Rail & 5-Torpedo Sub-Hunter Battery
		{
			"player_abyssalkraken",
			{ "armanavaldefturret", "corfdoom", "coratl" },
			{ 640e3, 1420e4, 680e3, 2, 32000, 1100, 2200 },
			"Leviathan Maw",
			"Aquatic citadel combining high-impulse shock-rail guns and 5-torpedo sub-hunter salvos.",
			function(u, src)
				u.minwaterdepth = 8
				u.maxwaterdepth = 9999
				u.sonardistance = 2200
				I(u, src, 1, "KRAKEN_SHOCKRAIL", {
					weapontype = "Cannon",
					waterweapon = false,
					range = 2400,
					reloadtime = 2.2,
					burst = 2,
					burstrate = 0.12,
					weaponvelocity = 4200,
					areaofeffect = 240,
					impulsefactor = 32,
					impulseboost = 22,
					camerashake = 95,
					energypershot = 24000,
					size = 11,
					stages = 22,
					intensity = 2.4,
					rgbcolor = "0.15 0.85 1",
					cegtag = "gausscannonprojectilexl",
					explosiongenerator = PH .. "huge",
					soundstart = "cannhvy5",
					soundhit = "xplolrg3",
					damage = D(34000, nil, 68000, 5600),
					onlytargetcategory = T_S,
				})
				I(u, src, GS(src, 2) and 2 or 1, "KRAKEN_TORPEDO", {
					weapontype = "TorpedoLauncher",
					range = 2400,
					reloadtime = 2.4,
					burst = 5,
					burstrate = 0.16,
					waterweapon = true,
					tracks = true,
					turnrate = 48000,
					weaponvelocity = 1400,
					startvelocity = 240,
					weaponacceleration = 360,
					weapontimer = 10,
					areaofeffect = 120,
					energypershot = 18000,
					cegtag = "torpedotrail-small",
					explosiongenerator = G .. "large-uw",
					soundstart = "torpedo1",
					soundhit = "xplodep1",
					damage = D(16000, nil, 24000, 3000),
					onlytargetcategory = T_NA,
				})
			end,
		},
	}

	local BUILDERS =
		"armack corack legack armacv coracv legacv armaca coraca legaca armacsub coracsub armcsa corcsa legnavyconship leganavyconsub legspcon armbehem corcrabe"
	local created, EF = {}, 0.25

	for _, spec in ipairs(SPECS) do
		local u, source, sourceName = CU(spec[1], spec[2])
		if u and source then
			local slots = GSC(source)
			SN(u)

			local st = spec[3]
			st[1], st[2] = st[1] * 0.20, st[2] * 0.20
			u.unitname, u.name = spec[1], spec[1]
			u.health, u.maxdamage = st[3], st[3]
			u.metalcost, u.energycost, u.buildtime = st[1], st[2], st[2]
			u.energyupkeep, u.energyuse = st[5] * EF, st[5] * EF
			if st[6] then
				u.sightdistance = st[6]
			end
			if st[7] then
				u.radardistance = st[7]
			end

			u.category = source.category or "ALL SURFACE WEAPON"
			u.maxwaterdepth, u.maxslope = 18, 16
			u.canattack, u.canstop, u.activatewhenbuilt, u.onoffable = true, true, true, true

			u.customparams = u.customparams or {}
			u.customparams.techlevel = 4
			u.customparams.unitgroup = "weapon"
			u.customparams.t4_turret = 1
			u.customparams.t4_exotic = 1
			u.customparams.t4_source = sourceName
			u.customparams.t4_source_weapon_slots = slots
			u.maxthisunit = st[4]

			LB(u, spec[4], spec[5])
			spec[6](u, source, sourceName)
			for _, weapon in pairs(u.weapondefs) do
				if weapon.energypershot then
					weapon.energypershot = weapon.energypershot * EF
				end
			end
			u.customparams.turret_energy_factor = EF

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
						onlytargetcategory = sSlot and sSlot.onlytargetcategory or T_S,
					}
				end
			end

			created[#created + 1] = spec[1]
		end
	end

	for _, unitName in ipairs(created) do
		TH(BUILDERS, unitName)
	end
end
