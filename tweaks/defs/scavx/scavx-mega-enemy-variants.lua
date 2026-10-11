-- Requires both player-mega-air-pack.lua and player-mega-land-pack.lua; both precede ScavX consumers.
-- Independent deep copies: no player build menus or shared weapon tables.
-- Squad eligibility is assigned by scavx-nightmare-hardmode-roster.lua.
do
  local function copy(v)
    if type(v) ~= "table" then return v end
    local out = {}
    for k, child in pairs(v) do out[k] = copy(child) end
    return out
  end
  -- ID, existing player source, displayed name, optional boss mechanic.
  local specs = {
    { "scavx_mega_riftcolossus", "player_riftcolossus", "Scav Rift Colossus" },
    { "scavx_mega_riftjump", "player_riftcolossus", "Scav Rift Jumper" },
    { "scavx_mega_vortexdominator", "player_vortexdominator", "Scav Vortex Dominator" },
    { "scavx_mega_vortexwell", "player_vortexdominator", "Scav Vortex Well" },
    { "scavx_mega_aegisbreaker", "player_aegisbreaker", "Scav Aegis Breaker" },
    { "scavx_mega_solardecimator", "player_solardecimator", "Scav Solar Decimator" },
    { "scavx_mega_skyfurnace", "player_skyfurnace", "Scav Sky Furnace" },
    { "scavx_mega_stormsovereign", "player_stormsovereign", "Scav Storm Sovereign" },
    { "scavx_mega_pyroclast", "player_pyroclast", "Scav Pyroclast" },
    { "scavx_mega_singularity", "player_singularity", "Scav Singularity" },
    { "scavx_mega_aethersiege", "player_aethersiege", "Scav Aether Siege" },
    { "scavx_mega_phantomleviathan", "player_phantomleviathan", "Scav Phantom Leviathan" },
    { "scavx_mega_archangel", "player_archangel", "Scav Archangel" },
    { "scavx_boss_dreadbreaker", "player_aegisbreaker", "Dreadbreaker", "shotgun" },
    { "scavx_boss_tempestregent", "player_singularity", "Tempest Regent", "emp" },
    { "scavx_boss_veilsovereign", "player_phantomleviathan", "Veil Sovereign", "phase" },
  }
  for _, spec in ipairs(specs) do
    local id, source, name, boss = spec[1], UnitDefs[spec[2]], spec[3], spec[4]
    if source and not UnitDefs[id] then
      local u = copy(source)
      local hp, damage, reload, speed, shield = 3, 2, 0.7, 1.2, 2.5
      if boss then hp, damage, reload, speed, shield = 10, 4, 0.55, 1.5, 5 end
      u.unitname, u.name = id, name
      u.description = boss and "Scav-only solo boss: " .. boss or "Scav-only enhanced Mega"
      u.maxthisunit, u.buildoptions, u.builder = nil, nil, false
      u.customparams = u.customparams or {}
      local cp = u.customparams
      for key in pairs(cp) do
        if key:sub(1, 4) == "i18n" or key:sub(1, 4) == "scav" or key:sub(1, 6) == "raptor" then cp[key] = nil end
      end
      cp.i18n_en_humanname, cp.i18n_en_tooltip = name, u.description
      cp.scavx_enemy_mega, cp.scavx_boss_type = 1, boss
      if type(u.health) == "number" then
        u.health = u.health * hp
        u.maxdamage = u.health
        u.autoheal = math.max(tonumber(u.autoheal) or 0, u.health * (boss and 0.002 or 0.001))
      end
      u.stealth = true
      for _, field in ipairs({ "speed", "maxacc", "maxdec", "turnrate" }) do
        if type(u[field]) == "number" then u[field] = u[field] * speed end
      end
      local seen = {}
      -- Only installed weapons: leave inherited unused and dummy definitions alone.
      for _, mount in pairs(u.weapons or {}) do
        local w = u.weapondefs and u.weapondefs[string.lower(mount.def or "")]
        if w and not seen[w] and mount.onlytargetcategory ~= "NONE" then
          seen[w] = true
          for armor, value in pairs(w.damage or {}) do
            if type(value) == "number" then w.damage[armor] = value * damage end
          end
          if type(w.reloadtime) == "number" and w.reloadtime > 0 then
            local volley = math.max(0, (tonumber(w.burst) or 1) - 1) * (tonumber(w.burstrate) or 0)
            w.reloadtime = math.max(w.reloadtime * reload, volley + 0.05, tonumber(w.beamtime) or 0)
          end
          if type(w.shield) == "table" then
            for _, field in ipairs({ "power", "startingPower", "powerRegen" }) do
              if type(w.shield[field]) == "number" then w.shield[field] = w.shield[field] * shield end
            end
            cp.shield_power, cp.shield_radius = w.shield.power, w.shield.radius
          end
          for _, field in ipairs({ "shieldpower", "shieldstartingpower", "shieldpowerregen" }) do
            if type(w[field]) == "number" then w[field] = w[field] * shield end
          end
          if w.shieldpower then cp.shield_power, cp.shield_radius = w.shieldpower, w.shieldradius end
          -- Keep the same supported muzzles; emphasize each boss's native mechanic.
          if boss == "shotgun" and w.projectilespershot then
            w.projectilespershot = 12
            if w.customparams then w.customparams.pellets = 24 end
            w.rgbcolor = "1 0.15 0.05"
          elseif boss == "emp" and w.paralyzer then
            w.paralyzetime = math.max(tonumber(w.paralyzetime) or 0, 15)
            w.rgbcolor = "0.6 0.2 1"
          end
        end
      end
      UnitDefs[id] = u
      if UnitDefNames then UnitDefNames[id] = u end
    end
  end
end
