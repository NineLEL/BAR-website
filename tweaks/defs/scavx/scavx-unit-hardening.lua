-- ScavX combat hardening: enable after custom-unit-pack-00 through 06.
-- Shared definitions also strengthen player-built versions of ScavX units.
-- Does not change squad counts, anger gates, targeting, weapon slots or effects.
do
  local extraCombat = {}
  for name in string.gmatch("busters decimator epicantiair2 epicbas epicbasilica epicbasilicaair epicbeamer epicminiragna epicoly epicpluto fatherbehe fountain kingchimera multiplicable nukinator pulsinator quincy ratteking thetyrannus titaniator walkingfort wallnut epicsanctuary t5sanctuary", "%S+") do
    extraCombat[name] = true
  end
  local seen = {}
  for name, u in pairs(UnitDefs) do
    if type(name) == "string" and type(u) == "table" and not seen[u] then
      -- Native scavenger variants, where available, plus every added ScavX
      -- combat definition. Never match raptors or player Mega definitions.
      local nativeScav = name:sub(-5) == "_scav" or name:sub(1, 5) == "scav_"
      local armed = type(u.weapons) == "table" and next(u.weapons) ~= nil
      if extraCombat[name] or (nativeScav and armed and not u.builder) then
        seen[u] = true
        u.customparams = u.customparams or {}
        -- Repeated command execution must not multiply stats a second time.
        if not u.customparams.scavx_hardened then
          u.customparams.scavx_hardened = 1
          if type(u.health) == "number" then
            u.health = u.health * 2
            u.autoheal = math.max(tonumber(u.autoheal) or 0, math.min(2500, u.health * 0.001))
          end
          if type(u.speed) == "number" and u.speed > 0 then u.speed = u.speed * 1.1 end
          if type(u.sightdistance) == "number" then u.sightdistance = u.sightdistance * 1.15 end
          local weaponsSeen = {}
          for _, w in pairs(u.weapondefs or {}) do
            if type(w) == "table" and not weaponsSeen[w] then
              weaponsSeen[w] = true
              for armor, damage in pairs(w.damage or {}) do
                if type(damage) == "number" then w.damage[armor] = damage * 1.6 end
              end
              if type(w.reloadtime) == "number" and w.reloadtime > 0 then
                w.reloadtime = w.reloadtime * 0.8
              end
              local shield = w.shield
              if type(shield) == "table" then
                for _, field in ipairs({ "power", "startingPower", "powerRegen" }) do
                  if type(shield[field]) == "number" then shield[field] = shield[field] * 1.5 end
                end
                if type(shield.power) == "number" then u.customparams.shield_power = shield.power end
              end
            end
          end
        end
      end
    end
  end
end
