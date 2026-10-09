-- Imported from https://github.com/PixelAlien0/ScavX
-- Original module: tweakdefs3
-- Verified release source: ScavX_Commands_SunlessK (1).txt
-- Decoded and restored from the ScavX project payload.
-- Description: Clones Walking Fortress (armlunchbox) and Floating Wall-nut
-- (corcrwt4), then injects custom clones into Arm, Core, and Legion builder
-- menus across ACA, ACK, ACSUB, ACV, commanders, T3 builders, and Everything
-- Experimental.

-- EDITP_CLONES_BEGIN
do
	local function clone_copy(value)
		if type(value) ~= "table" then
			return value
		end
		local copy = {}
		for key, child in pairs(value) do
			copy[clone_copy(key)] = clone_copy(child)
		end
		return copy
	end
	local function clone_set_name(u, name, tooltip)
		if not u.customparams then
			u.customparams = {}
		end
		local c = u.customparams
		local l = { "en", "de", "fr", "es", "it", "ru", "zh", "cs", "hr", "lt" }
		for _, lang in ipairs(l) do
			c["i18n_" .. lang .. "_humanname"] = name
			c["i18n_" .. lang .. "_tooltip"] = tooltip
		end
	end
	local function clone_clean(u)
		if u.maxthisunit then
			u.maxthisunit = nil
		end
		if u.customparams then
			u.customparams.raptorbuildmeta = nil
		end
	end
	local function clone_preserve_visuals(u, source)
		local fields = {
			"objectname",
			"script",
			"buildpic",
			"icontype",
			"sfxtypes",
			"sounds",
			"featuredefs",
			"corpse",
			"explodeas",
			"selfdestructas",
			"weapondefs",
			"weapons",
		}
		for _, field in ipairs(fields) do
			if source[field] ~= nil then
				u[field] = clone_copy(source[field])
			end
		end
		if type(source.customparams) == "table" then
			if type(u.customparams) ~= "table" then
				u.customparams = {}
			end
			local shieldFields =
				{ "shield_radius", "shield_power", "shield_color_mult", "shield_emit_height", "shield_emit_offset" }
			for _, field in ipairs(shieldFields) do
				if source.customparams[field] ~= nil then
					u.customparams[field] = clone_copy(source.customparams[field])
				end
			end
		end
	end
	local function clone_sync_shield_visuals(u)
		if type(u.weapons) ~= "table" or type(u.weapondefs) ~= "table" then
			return
		end
		for _, mount in ipairs(u.weapons) do
			local defName = type(mount) == "table" and mount.def or nil
			if type(defName) == "string" then
				local defKey = defName:lower()
				local weaponDef = u.weapondefs[defKey]
				if type(weaponDef) ~= "table" then
					for candidateKey, candidate in pairs(u.weapondefs) do
						if type(candidateKey) == "string" and candidateKey:lower() == defKey then
							weaponDef = candidate
							break
						end
					end
				end
				if type(weaponDef) == "table" then
					local shield = type(weaponDef.shield) == "table" and weaponDef.shield or nil
					local radius = (shield and shield.radius) or weaponDef.shieldradius
					local power = (shield and shield.power) or weaponDef.shieldpower
					if radius ~= nil or power ~= nil then
						if type(u.customparams) ~= "table" then
							u.customparams = {}
						end
						if radius ~= nil then
							u.customparams.shield_radius = radius
						end
						if power ~= nil then
							u.customparams.shield_power = power
						end
						return
					end
				end
			end
		end
	end
	local function clone_swap_weapon(u, slotNum, srcUnit, srcWep, destWep)
		destWep = destWep or srcWep
		if UnitDefs[srcUnit] and UnitDefs[srcUnit].weapondefs and UnitDefs[srcUnit].weapondefs[srcWep] then
			if not u.weapondefs then
				u.weapondefs = {}
			end
			u.weapondefs[destWep] = clone_copy(UnitDefs[srcUnit].weapondefs[srcWep])
		end
		if not u.weapons then
			u.weapons = {}
		end
		if not u.weapons[slotNum] then
			u.weapons[slotNum] = {}
		end
		u.weapons[slotNum].def = destWep:upper()
		if UnitDefs[srcUnit] and UnitDefs[srcUnit].weapons then
			local srcSlotIdx = nil
			for idx, w in ipairs(UnitDefs[srcUnit].weapons) do
				if w.def and w.def:lower() == srcWep then
					srcSlotIdx = idx
					break
				end
			end
			if srcSlotIdx and UnitDefs[srcUnit].weapons[srcSlotIdx] then
				for k, v in pairs(UnitDefs[srcUnit].weapons[srcSlotIdx]) do
					if k ~= "def" then
						if type(v) == "table" then
							u.weapons[slotNum][k] = clone_copy(v)
						else
							u.weapons[slotNum][k] = v
						end
					end
				end
			end
		end
	end
	do
		local s = "armlunchbox"
		local n = "walkingfort"
		if UnitDefs[s] and not UnitDefs[n] then
			UnitDefs[n] = clone_copy(UnitDefs[s])
			local u = UnitDefs[n]
			if UnitDefNames then
				UnitDefNames[n] = u
			end
			clone_clean(u)
			clone_preserve_visuals(u, UnitDefs[s])
			local srcBo = UnitDefs[s].buildoptions
			local bo = {}
			if type(srcBo) == "table" then
				for _, x in ipairs(srcBo) do
					if type(x) == "string" then
						bo[#bo + 1] = x
					end
				end
			end
			u.buildoptions = bo
			clone_set_name(u, "Walking Fortress", "???")
			clone_swap_weapon(u, 1, "meteor", "weapon", "weapon")
			clone_sync_shield_visuals(u)
		end
	end
	do
		local s = "corcrwt4"
		local n = "wallnut"
		if UnitDefs[s] and not UnitDefs[n] then
			UnitDefs[n] = clone_copy(UnitDefs[s])
			local u = UnitDefs[n]
			if UnitDefNames then
				UnitDefNames[n] = u
			end
			clone_clean(u)
			clone_preserve_visuals(u, UnitDefs[s])
			local srcBo = UnitDefs[s].buildoptions
			local bo = {}
			if type(srcBo) == "table" then
				for _, x in ipairs(srcBo) do
					if type(x) == "string" then
						bo[#bo + 1] = x
					end
				end
			end
			u.buildoptions = bo
			clone_set_name(u, "Floating Wall-nut", "Air Sacrificial Lamb (Huge Health) / Semi Anti Air")
			clone_swap_weapon(u, 1, "legafigdef", "leggun", "leggun")
			clone_swap_weapon(u, 2, "legafigdef", "leggun", "leggun")
			clone_swap_weapon(u, 3, "legafigdef", "leggun", "leggun")
			clone_swap_weapon(u, 4, "legafigdef", "leggun", "leggun")
			clone_swap_weapon(u, 5, "legafigdef", "leggun", "leggun")
			clone_swap_weapon(u, 6, "legafigdef", "leggun", "leggun")
			clone_sync_shield_visuals(u)
		end
	end
end
local function editp_bo(i, a, r, o)
	local u = UnitDefs and UnitDefs[i]
	if not u then
		return
	end
	if type(u.buildoptions) ~= "table" then
		u.buildoptions = {}
	end
	if o then
		local t = {}
		for x in string.gmatch(o, "%S+") do
			t[#t + 1] = x
		end
		u.buildoptions = t
		return
	end
	local rm = {}
	if r then
		for x in string.gmatch(r, "%S+") do
			rm[x] = true
		end
	end
	local seen = {}
	local out = {}
	for _, x in ipairs(u.buildoptions) do
		if type(x) == "string" then
			local k = string.lower(x)
			if not rm[k] then
				out[#out + 1] = x
				seen[k] = true
			end
		end
	end
	if a then
		for x in string.gmatch(a, "%S+") do
			local k = string.lower(x)
			if not seen[k] then
				out[#out + 1] = x
				seen[k] = true
			end
		end
	end
	u.buildoptions = out
end
editp_bo(
	"armaca",
	"epicbas epicantiair2 epicoly pulsinator t3builder epicsanctuary epicbasilica epicminiragna epicbeamer epicpluto decimator t5sanctuary epicbasilicaair everyexpe t2metalgenerator fountain epicwall",
	nil,
	nil
)
editp_bo(
	"armack",
	"epicbas epicantiair2 epicoly pulsinator t3builder epicsanctuary epicbasilica epicminiragna epicbeamer epicpluto decimator t5sanctuary epicbasilicaair everyexpe t2metalgenerator fountain epicwall",
	nil,
	nil
)
editp_bo(
	"armacsub",
	"epicbas epicantiair2 epicoly pulsinator t3builder epicsanctuary epicbasilica epicminiragna epicbeamer epicpluto decimator t5sanctuary epicbasilicaair everyexpe t2metalgenerator fountain epicwall",
	nil,
	nil
)
editp_bo(
	"armacv",
	"epicbas epicantiair2 epicoly pulsinator t3builder epicbasilicaair epicbasilica epicbeamer epicminiragna epicpluto epicsanctuary everyexpe t5sanctuary decimator t2metalgenerator fountain epicwall",
	nil,
	nil
)
editp_bo("armapt3", "wallnut", nil, nil)
editp_bo("armca", "t1metalgenerator", nil, nil)
editp_bo("armch", "t1metalgenerator", nil, nil)
editp_bo("armck", "t1metalgenerator", nil, nil)
editp_bo("armcom", "t1metalgenerator", nil, nil)
editp_bo("armcs", "t1metalgenerator", nil, nil)
editp_bo("armcsa", "t1metalgenerator", nil, nil)
editp_bo("armcv", "t1metalgenerator", nil, nil)
editp_bo(
	"coraca",
	"epicbas epicantiair2 epicoly pulsinator t3builder epicsanctuary epicbasilica epicminiragna epicbeamer epicpluto decimator t5sanctuary epicbasilicaair everyexpe t2metalgenerator fountain epicwall",
	nil,
	nil
)
editp_bo(
	"corack",
	"epicbas epicantiair2 epicoly pulsinator t3builder epicsanctuary epicbasilica epicminiragna epicbeamer epicpluto decimator t5sanctuary epicbasilicaair everyexpe t2metalgenerator fountain epicwall",
	nil,
	nil
)
editp_bo(
	"coracsub",
	"epicbas epicantiair2 epicoly pulsinator t3builder epicsanctuary epicbasilica epicminiragna epicbeamer epicpluto decimator t5sanctuary epicbasilicaair everyexpe t2metalgenerator fountain epicwall",
	nil,
	nil
)
editp_bo(
	"coracv",
	"epicbas epicantiair2 epicoly pulsinator t3builder epicbasilicaair epicbasilica epicbeamer epicminiragna epicpluto epicsanctuary everyexpe decimator t5sanctuary t2metalgenerator fountain epicwall",
	nil,
	nil
)
editp_bo("corapt3", "wallnut", nil, nil)
editp_bo("corca", "t1metalgenerator", nil, nil)
editp_bo("corch", "t1metalgenerator", nil, nil)
editp_bo("corck", "t1metalgenerator", nil, nil)
editp_bo("corcom", "t1metalgenerator", nil, nil)
editp_bo("corcs", "t1metalgenerator", nil, nil)
editp_bo("corcsa", "t1metalgenerator", nil, nil)
editp_bo("corcv", "t1metalgenerator", nil, nil)
editp_bo(
	"everyexpe",
	"legapollyon legeheatraymech_old armprowl armassimilator legelrpcmech corjugg corcat corsok legerailtank cordemon legsrailt4 corakt4 leggobt3 corkarganetht4 armlichet4 legmost3 armpwt4 armsptkt4 corcrwt4 corves armvang armbanth armthor corthermite armraz armrattet4 legeshotgunmech leegmech legeallterrainmech legpede armmeatball armmar armlun legeheatraymech legfortt4 corgolt4 corfblackhyt4 armfepocht4 corkorg legjav legkeres corkarg wallnut",
	"leghacv legaheattank legmed legavroc legmrv legavjam legavantinuke legvflak leginf",
	nil
)
editp_bo(
	"legaca",
	"epicbas epicantiair2 epicoly pulsinator t3builder epicsanctuary epicbasilica epicminiragna epicbeamer epicpluto decimator t5sanctuary epicbasilicaair everyexpe t2metalgenerator fountain epicwall",
	nil,
	nil
)
editp_bo(
	"legack",
	"epicbas epicantiair2 epicoly pulsinator t3builder epicsanctuary epicbasilica epicminiragna epicbeamer epicpluto decimator t5sanctuary epicbasilicaair everyexpe t2metalgenerator fountain epicwall",
	nil,
	nil
)
editp_bo(
	"legacv",
	"epicbas epicantiair2 epicoly pulsinator t3builder epicbasilicaair epicbasilica epicbeamer epicminiragna epicpluto epicsanctuary everyexpe decimator t5sanctuary t2metalgenerator fountain epicwall",
	nil,
	nil
)
editp_bo(
	"leganavyconsub",
	"epicbas epicantiair2 epicoly pulsinator t3builder epicsanctuary epicbasilica epicminiragna epicbeamer epicpluto decimator t5sanctuary epicbasilicaair everyexpe t2metalgenerator fountain epicwall",
	nil,
	nil
)
editp_bo("legapt3", "wallnut", nil, nil)
editp_bo("legca", "t1metalgenerator", nil, nil)
editp_bo("legch", "t1metalgenerator", nil, nil)
editp_bo("legck", "t1metalgenerator", nil, nil)
editp_bo("legcom", "t1metalgenerator", nil, nil)
editp_bo("legcv", "t1metalgenerator", nil, nil)
editp_bo("legnavyconship", "t1metalgenerator", nil, nil)
editp_bo("legspcon", "t1metalgenerator", nil, nil)
editp_bo(
	"t3builder",
	"epicbas epicantiair2 pulsinator epicoly t3builder corapt3 armapt3 legapt3 corgant leggant armshltx epicsanctuary epicminiragna epicbasilica armaap coraap armalab coralab armavp coravp legavp legaap legalab epicbeamer epicpluto legafust3 corafust3 armafust3 legadveconvt3 cormmkrt3 armmmkrt3 corgatet3 decimator t5sanctuary everyexpe epicbasilicaair t2metalgenerator fountain epicwall",
	nil,
	"epicbas epicantiair2 pulsinator epicoly t3builder corapt3 armapt3 legapt3 corgant leggant armshltx epicsanctuary epicminiragna epicbasilica armaap coraap legaap armalab coralab legalab armavp coravp legavp epicbeamer epicpluto legafust3 corafust3 armafust3 legadveconvt3 cormmkrt3 armmmkrt3 corgatet3 decimator t5sanctuary everyexpe epicbasilicaair t2metalgenerator fountain epicwall"
)
