-- Imported from https://github.com/PixelAlien0/ScavX
-- Original module: tweakdefs
-- Decoded and restored from the ScavX project payload.
-- Description: Clones Buster (legkeres), Ground Decimator (corbuzz), Epic
-- Xyston (leglraa), Epic Bastion (scavbeacon_t4), Epic Basilica (armbrtha),
-- Basiliscia F3 (armbrtha), Epic Beamer (armbeamer), Epic Mini Ragnarok
-- (armminivulc), and Epic Olympus (leglrpc).

--ScavengerBuff(SunlessK)
-- Author: [Grump]SunlessK
-- Description: Scavenger Buff + Brand New Turrets
-- Generated with BAR Editor
-- ----------------------------------------------------
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
		local s = "legkeres"
		local n = "busters"
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
			clone_set_name(u, "Buster", "???")
			clone_swap_weapon(u, 2, "legbastion", "t2heatray", "t2heatray")
			clone_swap_weapon(u, 3, "legbastion", "t2heatray", "t2heatray")
			clone_sync_shield_visuals(u)
		end
	end
	do
		local s = "corbuzz"
		local n = "decimator"
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
			clone_set_name(u, "Ground Decimator", "The Ultimate Defence Turret - Type 1")
			clone_sync_shield_visuals(u)
		end
	end
	do
		local s = "leglraa"
		local n = "epicantiair2"
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
			clone_set_name(u, "Epic Xyston", "Homing Concentrated Energy Missile")
			clone_swap_weapon(u, 1, "armmercury", "arm_advsam", "arm_advsam")
			clone_sync_shield_visuals(u)
		end
	end
	do
		local s = "scavbeacon_t4"
		local n = "epicbas"
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
			clone_set_name(u, "Epic Bastion", "Epic Bastion")
			clone_swap_weapon(u, 1, "legbastion", "t2heatray", "t2heatray")
			clone_sync_shield_visuals(u)
		end
	end
	do
		local s = "armbrtha"
		local n = "epicbasilica"
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
			clone_set_name(u, "Epic Basilica", "Long Range Heavy Turret")
			clone_swap_weapon(u, 1, "meteor", "weapon", "weapon")
			clone_sync_shield_visuals(u)
		end
	end
	do
		local s = "armbrtha"
		local n = "epicbasilicaair"
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
			clone_set_name(u, "Basiliscia F3", "Counter for Heavy Armored Air Units")
			clone_swap_weapon(u, 1, "meteor", "weapon", "weapon")
			clone_sync_shield_visuals(u)
		end
	end
	do
		local s = "armbeamer"
		local n = "epicbeamer"
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
			clone_set_name(u, "Epic Beamer", "Continuous Concentrated Energy Beamer")
			clone_sync_shield_visuals(u)
		end
	end
	do
		local s = "armminivulc"
		local n = "epicminiragna"
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
			clone_set_name(u, "Epic Mini Ragnarok", "Fast Turret Gunner")
			clone_sync_shield_visuals(u)
		end
	end
	do
		local s = "leglrpc"
		local n = "epicoly"
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
			clone_set_name(u, "Epic Olympus", "Heavy Meteor Turret")
			clone_swap_weapon(u, 1, "armbrtha", "lrpc", "lrpc")
			clone_sync_shield_visuals(u)
		end
	end
end
