-- Combined T3/T4 economy, advanced fusion, and construction-turret pack.
do
	local U, UN = UnitDefs or {}, UnitDefNames
	local F = { arm = "Armada", cor = "Cortex", leg = "Legion" }
	local FL = { "arm", "cor", "leg" }
	local BLD = {
		arm = { "armack", "armacv", "armaca" },
		cor = { "corack", "coracv", "coraca" },
		leg = { "legack", "legacv", "legaca" },
	}
	local VIS = { arm = "armrespawn", cor = "correspawn", leg = "legnanotcbase" }
	local SUB = { arm = "armacsub", cor = "coracsub", leg = "legacsub" }
	local LANG = { "en", "de", "fr", "es", "it", "ru", "zh", "cs", "hr", "lt" }

	local function cp(v)
		if type(v) ~= "table" then
			return v
		end
		local r = {}
		for k, c in pairs(v) do
			r[cp(k)] = cp(c)
		end
		return r
	end

	local function add(bName, uName)
		local b = U[bName]
		if not (b and U[uName]) then
			return
		end
		b.buildoptions = b.buildoptions or {}
		for _, v in ipairs(b.buildoptions) do
			if v == uName then
				return
			end
		end
		b.buildoptions[#b.buildoptions + 1] = uName
	end

	local function pub(n, u)
		U[n] = u
		if UN then
			UN[n] = u
		end
	end

	local function i18n(u, name, tip)
		u.customparams = u.customparams or {}
		for _, l in ipairs(LANG) do
			u.customparams["i18n_" .. l .. "_humanname"] = name
			u.customparams["i18n_" .. l .. "_tooltip"] = tip
		end
	end

	local function sc(v, f)
		return v and math.ceil(v * f) or nil
	end

	-- Converters: { id, src, fac, t, cap, eff, m, e, bt, hp }
	local convs = {
		{ "armmmkr_t3", "armmmkr", "arm", 3, 16000, 0.0225, 14200, 720000, 460000, 12000 },
		{ "cormmkr_t3", "cormmkr", "cor", 3, 16000, 0.0225, 15000, 750000, 480000, 13500 },
		{ "legadveconv_t3", "legadveconv", "leg", 3, 16000, 0.0225, 15000, 750000, 480000, 13500 },
		{ "armmmkr_t4", "armmmkr", "arm", 4, 48000, 0.025, 30500, 1550000, 860000, 28000 },
		{ "cormmkr_t4", "cormmkr", "cor", 4, 48000, 0.025, 32000, 1600000, 900000, 32000 },
		{ "legadveconv_t4", "legadveconv", "leg", 4, 48000, 0.025, 32000, 1600000, 900000, 32000 },
	}
	for _, s in ipairs(convs) do
		local src = U[s[2]]
		if src then
			local n = (s[4] == 3 and "Legendary" or "Ultra") .. " Energy Converter"
			local u = cp(src)
			u.unitname, u.name, u.description = s[1], n, n
			u.metalcost, u.energycost, u.buildtime, u.health = s[7], s[8], s[9], s[10]
			u.activatewhenbuilt, u.onoffable = true, true
			u.weapondefs = u.weapondefs or {}
			u.customparams = u.customparams or {}
			u.customparams.techlevel, u.customparams.energyconv_capacity, u.customparams.energyconv_efficiency =
				s[4], s[5], s[6]
			i18n(
				u,
				n,
				("Converts %d energy into %d metal per sec. Explodes violently."):format(
					s[5],
					math.floor(s[5] * s[6] + 0.5)
				)
			)
			pub(s[1], u)
			for _, b in ipairs(BLD[s[3]]) do
				add(b, s[1])
			end
		end
	end

	-- Moho: { id, src, fac, t, ext, make, upkeep, st, m, e, bt, hp }
	local mexs = {
		{ "armmoho_t3", "armmoho", "arm", 3, 0.008, 8, 90, 1200, 4500, 60000, 52000, 7500 },
		{ "cormoho_t3", "cormoho", "cor", 3, 0.008, 8, 90, 1200, 5200, 78000, 58000, 9500 },
		{ "legmoho_t3", "legmoho", "leg", 3, 0.008, 8, 90, 1200, 5200, 78000, 58000, 9500 },
		{ "armmoho_t4", "armmoho", "arm", 4, 0.016, 16, 240, 2000, 16000, 270000, 180000, 17000 },
		{ "cormoho_t4", "cormoho", "cor", 4, 0.016, 16, 240, 2000, 18500, 320000, 200000, 20000 },
		{ "legmoho_t4", "legmoho", "leg", 4, 0.016, 16, 240, 2000, 18500, 320000, 200000, 20000 },
	}
	for _, s in ipairs(mexs) do
		local src = U[s[2]]
		if src then
			local n = (s[4] == 3 and "Epic" or "Legendary") .. " Metal Extractor"
			local u = cp(src)
			u.unitname, u.name, u.description = s[1], n, n
			u.extractsmetal, u.makesmetal, u.energyupkeep = s[5], s[6], s[7]
			u.metalstorage, u.metalcost, u.energycost, u.buildtime, u.health = s[8], s[9], s[10], s[11], s[12]
			u.activatewhenbuilt, u.onoffable = true, true
			u.weapondefs = u.weapondefs or {}
			u.customparams = u.customparams or {}
			u.customparams.techlevel, u.customparams.metal_extractor, u.customparams.standardextractor =
				s[4], s[6], true
			i18n(
				u,
				n,
				("Produces %d metal, upkeep %dE, storage %d. Explodes violently if destroyed."):format(s[6], s[7], s[8])
			)
			pub(s[1], u)
			for _, b in ipairs(BLD[s[3]]) do
				add(b, s[1])
			end
		end
	end

	-- Storage: { id, src, fac, type, t, cap, m, e, bt, hp }
	local storages = {
		{ "armuwadvmst3", "armuwadvms", "arm", "m", 3, 40000, 4800, 80000, 120000, 52000 },
		{ "coruwadvmst3", "coruwadvms", "cor", "m", 3, 40000, 5300, 90000, 128000, 56000 },
		{ "legamstort3", "legamstor", "leg", "m", 3, 40000, 5300, 90000, 128000, 56000 },
		{ "armuwadvmst4", "armuwadvms", "arm", "m", 4, 160000, 19000, 340000, 480000, 195000 },
		{ "coruwadvmst4", "coruwadvms", "cor", "m", 4, 160000, 21500, 390000, 520000, 225000 },
		{ "legamstort4", "legamstor", "leg", "m", 4, 160000, 21500, 390000, 520000, 225000 },
		{ "armuwadvest3", "armuwadves", "arm", "e", 3, 250000, 5200, 95000, 120000, 52000 },
		{ "coruwadvest3", "coruwadves", "cor", "e", 3, 250000, 5700, 105000, 128000, 56000 },
		{ "legadvestoret3", "legadvestore", "leg", "e", 3, 250000, 5700, 105000, 128000, 56000 },
		{ "armuwadvest4", "armuwadves", "arm", "e", 4, 1500000, 20500, 470000, 480000, 195000 },
		{ "coruwadvest4", "coruwadves", "cor", "e", 4, 1500000, 23000, 530000, 520000, 225000 },
		{ "legadvestoret4", "legadvestore", "leg", "e", 4, 1500000, 23000, 530000, 520000, 225000 },
	}
	for _, s in ipairs(storages) do
		local src = U[s[2]]
		if src then
			local res = s[4] == "m" and "Metal" or "Energy"
			local rk = s[5] == 3 and "Epic" or "Legendary"
			local n = rk .. " " .. res .. " Storage"
			local u = cp(src)
			u.unitname, u.name, u.description = s[1], n, n
			u.metalstorage = s[4] == "m" and s[6] or 0
			u.energystorage = s[4] == "e" and s[6] or 0
			u.metalcost, u.energycost, u.buildtime, u.health, u.techlevel = s[7], s[8], s[9], s[10], s[5]
			u.weapondefs = u.weapondefs or {}
			u.customparams = u.customparams or {}
			u.customparams.techlevel = s[5]
			i18n(
				u,
				n,
				("%s %s storage adds %d capacity. Explodes %s if destroyed."):format(
					rk,
					res,
					s[6],
					s[5] == 3 and "violently" or "catastrophically"
				)
			)
			pub(s[1], u)
			for _, b in ipairs(BLD[s[3]]) do
				add(b, s[1])
			end
			local sb = SUB[s[3]]
			if sb and u.maxwaterdepth then
				add(sb, s[1])
			end
		end
	end

	-- Fusions
	for _, p in ipairs(FL) do
		local sN, tN = p .. "afust3", p .. "afust4"
		local src = U[sN]
		if src then
			for _, b in ipairs(BLD[p]) do
				add(b, sN)
			end
			local u = cp(src)
			local em = sc(src.energymake, 2) or 0
			local n = "Legendary Fusion Reactor"
			u.unitname, u.name, u.description = tN, n, n
			u.buildtime, u.metalcost, u.energycost =
				sc(src.buildtime, 2.2), sc(src.metalcost, 2.2), sc(src.energycost, 2.2)
			u.energymake, u.energystorage = em, sc(src.energystorage, 5)
			u.health, u.idleautoheal = sc(src.health, 5.5), sc(src.idleautoheal, 6)
			u.damagemodifier, u.footprintx, u.footprintz = 0.95, 12, 12
			i18n(u, n, ("Produces %d Energy. Catastrophic if destroyed."):format(em))
			pub(tN, u)
			for _, b in ipairs(BLD[p]) do
				add(b, tN)
			end
		end
	end

	-- Turrets
	local tOpts = {
		"player_hailstorm",
		"player_needleswarm",
		"player_blackoutcascade",
		"player_phalanxlance",
		"player_quakedoom",
		"player_nullcathedral",
		"player_hivearray",
		"player_aegiseraser",
		"player_executioner",
		"player_prismcathedral",
		"player_hyperionlance",
		"player_starfallcataclysm",
		"player_streamarty",
		"player_holybeam",
		"player_aegisstarspire",
		"player_thornnest",
		"player_mirrorarray",
		"player_voidvortex",
		"player_infernocrucible",
		"player_cascademortar",
		"armshltx",
		"corgant",
		"leggant",
		"armapt3",
		"corapt3",
		"legapt3",
		"armalab",
		"coralab",
		"legalab",
		"armvp",
		"corvp",
		"legvp",
		"armaap",
		"coraap",
		"legaap",
		"armgate",
		"corgate",
		"legdeflector",
		"armgatet3",
		"corgatet3",
		"leggatet3",
		"armfgate",
		"corfgate",
		"player_aegisdome",
		"player_citadelumbrella",
	}
	local fDef = {
		arm = {
			"armamb",
			"armpb",
			"armanni",
			"armflak",
			"armmercury",
			"armemp",
			"armamd",
			"armsilo",
			"armbrtha",
			"armvulc",
			"armdf",
		},
		cor = { "cortoast", "corvipe", "cordoom", "corflak", "corscreamer", "cortron", "corfmd", "corsilo", "corint", "corbuzz" },
		leg = {
			"legacluster",
			"legapopupdef",
			"legbastion",
			"legflak",
			"leglraa",
			"legperdition",
			"legabm",
			"legsilo",
			"leglrpc",
			"legstarfall",
		},
	}

	for _, p in ipairs(FL) do
		local t3N, t4N = p .. "nanotct3", p .. "nanotct4"
		local base = U[p .. "nanotct2"]
		local vis = U[VIS[p]]
		if base then
			local t3, t4 = cp(base), cp(base)
			if vis then
				t3.objectname, t3.script, t3.corpse, t3.featuredefs =
					vis.objectname, vis.script, vis.corpse, cp(vis.featuredefs)
				t4.objectname, t4.script, t4.corpse, t4.featuredefs =
					vis.objectname, vis.script, vis.corpse, cp(vis.featuredefs)
			end

			t3.unitname, t3.name, t3.description = t3N, "Epic Construction Turret", "Epic Construction Turret"
			t3.disabled = false
			t3.metalcost, t3.energycost, t3.buildtime = 3700, 62000, 108000
			t3.footprintx, t3.footprintz, t3.collisionvolumescales = 8, 8, "82 150 82"
			t3.health, t3.maxdamage, t3.workertime, t3.builddistance = 10560, 10560, 2400, 750
			i18n(t3, t3.name, t3.description)
			pub(t3N, t3)

			t4.unitname, t4.name, t4.description = t4N, "Legendary Construction Turret", "Legendary Construction Turret"
			t4.disabled = false
			t4.metalcost, t4.energycost, t4.buildtime = 11100, 186000, 324000
			t4.footprintx, t4.footprintz, t4.collisionvolumescales = 10, 10, "104 180 104"
			t4.health, t4.maxdamage, t4.workertime, t4.builddistance = 26400, 26400, 4000, 900
			i18n(t4, t4.name, t4.description)
			pub(t4N, t4)

			for _, b in ipairs(BLD[p]) do
				add(b, t3N)
				local bo = U[b] and U[b].buildoptions
				if bo then
					for i = #bo, 1, -1 do
						if bo[i] == t4N then
							table.remove(bo, i)
						end
					end
				end
			end

			add(t3N, t3N)
			add(t3N, t4N)
			for _, o in ipairs(tOpts) do
				add(t3N, o)
				add(t4N, o)
			end
			for _, o in ipairs(fDef[p]) do
				add(t3N, o)
				add(t4N, o)
			end
		end
	end

	-- Explosions
	local eg = "custom:genericbuildingexplosion-"
	local el, eh, egig = eg .. "large", eg .. "huge", eg .. "gigantic"
	local nuk, big, med = "xplonuk3", "xplolrg3", "xplomed1"
	local B = {
		c = {
			{ { 1200, 600, eh, 18000, 0, nuk }, { 2000, 1000, egig, 65000, 0, nuk } },
			{ { 2400, 1200, egig, 90000, 0, nuk }, { 3600, 1800, egig, 240000, 0, nuk } },
		},
		x = {
			{ { 600, 300, el, 3000, 0, med }, { 900, 450, eh, 9000, 0, big } },
			{ { 1200, 600, eh, 25000, 0, big }, { 2000, 1000, egig, 90000, 0, nuk } },
		},
		m = {
			{ { 720, 360, el, 2200, 0, med }, { 1200, 600, eh, 10000, 0, big } },
			{ { 1500, 750, eh, 30000, 0, big }, { 2300, 1150, egig, 90000, 0, nuk } },
		},
		e = {
			{ { 1200, 600, eh, 20000, 9000, nuk }, { 2000, 1000, egig, 75000, 22000, nuk } },
			{ { 2400, 1200, egig, 90000, 40000, nuk }, { 3600, 1800, egig, 240000, 75000, nuk } },
		},
		f = {
			{ { 1600, 800, eh, 45000, 0, nuk }, { 2400, 1200, egig, 135000, 0, nuk } },
			{ { 3000, 1500, egig, 180000, 0, nuk }, { 4800, 2400, egig, 500000, 0, nuk } },
		},
		t = {
			{ { 700, 350, el, 8000, 0, med }, { 1200, 600, eh, 30000, 0, big } },
			{ { 1800, 900, eh, 60000, 0, big }, { 2800, 1400, egig, 180000, 0, nuk } },
		},
	}
	local ST_MAP = {
		arm = { "armuwadvmst3", "armuwadvmst4", "armuwadvest3", "armuwadvest4" },
		cor = { "coruwadvmst3", "coruwadvmst4", "coruwadvest3", "coruwadvest4" },
		leg = { "legamstort3", "legamstort4", "legadvestoret3", "legadvestoret4" },
	}

	local function blast(u, k, tier, pr)
		if not u then
			return
		end
		u.weapondefs = u.weapondefs or {}
		local dN, sN = k .. "_t" .. tier, k .. "_t" .. tier .. "_selfd"
		for i = 1, 2 do
			local p, nm = pr[i], i == 1 and dN or sN
			local dmg = { default = p[4] }
			if p[5] > 0 then
				dmg.commanders = p[5]
			end
			u.weapondefs[nm] = {
				AreaOfEffect = p[1],
				cameraShake = p[2],
				impulsefactor = 0.123,
				soundhit = p[6],
				soundstart = "largegun",
				explosiongenerator = p[3],
				damage = dmg,
				customparams = { unitexplosion = 1 },
			}
		end
		u.explodeas, u.selfdestructas = dN, sN
	end

	for _, p in ipairs(FL) do
		local cN = p == "leg" and "legadveconv" or p .. "mmkr"
		for tr = 3, 4 do
			local idx = tr - 2
			blast(U[cN .. "_t" .. tr], "convboom", tr, B.c[idx])
			blast(U[p .. "moho_t" .. tr], "mexboom", tr, B.x[idx])
			blast(U[ST_MAP[p][idx]], "storagemetalboom", tr, B.m[idx])
			blast(U[ST_MAP[p][tr]], "storageenergyboom", tr, B.e[idx])
			blast(U[p .. "afust" .. tr], "fusionboom", tr, B.f[idx])
			blast(U[p .. "nanotct" .. tr], "constructionboom", tr, B.t[idx])
		end
	end
end
