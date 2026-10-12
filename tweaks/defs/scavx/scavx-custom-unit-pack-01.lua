-- Imported from https://github.com/PixelAlien0/ScavX
-- Original module: tweakdefs1
-- Verified release source: ScavX_Commands_SunlessK (1).txt; local Mega build-menu extension retained.
-- Decoded and restored from the ScavX project payload.
-- Description: Clones Epic Pluto (legflak), Epic Sanctuary (corgatet3), Epic
-- Wall (legforti), Everything Experimental (leghavp), Father of All Behemoth
-- (corjugg), Fountain (legcluster), King Chimera (raptor_queen_epic),
-- Multiplicable (corgolt4), and Nukinator (legsrailt4).

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
		local s = "legflak"
		local n = "epicpluto"
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
			clone_set_name(u, "Epic Pluto", "Overdrived Anti Air")
			clone_sync_shield_visuals(u)
		end
	end
	do
		local s = "corgatet3"
		local n = "epicsanctuary"
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
			clone_set_name(u, "Epic Sanctuary", "Long Radius Overdrived Shield")
			clone_sync_shield_visuals(u)
		end
	end
	do
		local s = "legforti"
		local n = "epicwall"
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
			clone_set_name(u, "Epic Wall", "Good for funnelling ground units")
			clone_sync_shield_visuals(u)
		end
	end
	do
		local s = "leghavp"
		local n = "everyexpe"
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
			clone_set_name(u, "Everything Experimental", "???")
			clone_sync_shield_visuals(u)
			-- Both player-mega-air-pack.lua and player-mega-land-pack.lua precede ScavX consumers, including this clone.
			-- Add the Mega roster here so Everything Experimental always exposes it.
			local megaUnits = {
				"player_riftcolossus", "player_riftjump", "player_vortexwell",
				"player_aegisbreaker", "player_solardecimator", "player_skyfurnace", "player_stormsovereign",
				"player_pyroclast", "player_singularity", "player_aethersiege",
				"player_phantomleviathan", "player_archangel",
			}
			for _, megaName in ipairs(megaUnits) do
				if UnitDefs[megaName] then
					local alreadyListed = false
					for _, buildName in ipairs(u.buildoptions) do
						if buildName == megaName then
							alreadyListed = true
							break
						end
					end
					if not alreadyListed then
						u.buildoptions[#u.buildoptions + 1] = megaName
					end
				end
			end
		end
	end
	do
		local s = "corjugg"
		local n = "fatherbehe"
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
			clone_set_name(u, "Father of All Behemoth", "???")
			clone_swap_weapon(u, 1, "armannit3", "ata", "ata")
			clone_sync_shield_visuals(u)
		end
	end
	do
		local s = "legcluster"
		local n = "fountain"
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
			clone_set_name(u, "Fountain", "Long Range Concentrated Cannon")
			clone_swap_weapon(u, 1, "corgolt4", "corlevlr_weapon", "corlevlr_weapon")
			clone_sync_shield_visuals(u)
		end
	end
	do
		local s = "raptor_queen_epic"
		local n = "kingchimera"
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
			clone_set_name(u, "King Chimera", "King Chimera")
			clone_swap_weapon(u, 1, "armrattet4", "arm_bosscannon", "arm_bosscannon")
			clone_swap_weapon(u, 2, "corcrwt4", "kmaw", "kmaw")
			clone_swap_weapon(u, 3, "corcrwt4", "kmaw", "kmaw")
			clone_swap_weapon(u, 4, "corcrwt4", "kmaw", "kmaw")
			clone_swap_weapon(u, 5, "coresuppt3", "laser", "laser")
			clone_sync_shield_visuals(u)
		end
	end
	do
		local s = "corgolt4"
		local n = "multiplicable"
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
			clone_set_name(u, "Multiplicable", "???")
			clone_sync_shield_visuals(u)
		end
	end
	do
		local s = "legsrailt4"
		local n = "nukinator"
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
			clone_set_name(u, "Nukinator", "Heavy Nuke Sniper Spider")
			clone_swap_weapon(u, 1, "legsilo", "legicbm", "legicbm")
			clone_sync_shield_visuals(u)
		end
	end
end
