-- Ultra Nightmare: mobile Raptor combat only, after clone and siege creation.
-- HP floors let frontlines survive ultra-turret volleys without infinite swarms.
-- Bosses are tough, not EMP-immune; original scripts/targeting/effects stay intact.
-- RaptorX clone HP rises 12% and damage rises 5% per 10 anger, based on squad unlock tier.
do
  local elites = {}
  for name in string.gmatch("raptorx_latebehemoth raptorx_lateskyreaper raptorx_broodlord raptorx_acidstorm raptorx_siegehowler raptorx_clusterrain raptorx_disruptionmortar", "%S+") do elites[name] = true end
  local apex = {}
  for name in string.gmatch("raptorx_apex_colossus raptorx_spectre_overlord raptorx_queen_ascendant", "%S+") do apex[name] = true end
  local seen = {}
  for name, u in pairs(UnitDefs) do
    if type(name) == "string" and type(u) == "table" and not seen[u] then
      local raptor = name:sub(1, 7) == "raptor_" or name:sub(1, 8) == "raptorx_"
      local mobile = type(u.speed) == "number" and u.speed > 0
      local armed = type(u.weapons) == "table" and next(u.weapons) ~= nil
      -- Specialist bosses own their health, regeneration, cooldowns and rarity.
      if raptor and mobile and armed and not u.builder and not (u.customparams and u.customparams.raptorx_miniboss) then
        seen[u] = true
        u.customparams = u.customparams or {}
        local customUnit = name:sub(1, 8) == "raptorx_"
        local squadData = u.customparams
        local minimumAnger = tonumber(squadData.raptorsquadminanger) or 0
        local angerTier = math.min(10, math.floor(minimumAnger / 10))
        local angerScale = customUnit and (1.12 ^ angerTier) or 1
        local damageAngerScale = customUnit and (1.05 ^ angerTier) or 1
        if squadData.raptorcustomsquad and not squadData.raptorx_squadweight_adjusted then
          local weight = tonumber(squadData.raptorsquadweight)
          if weight then
            local bias = customUnit and 2 or 0.5
            if minimumAnger < 25 then
              bias = customUnit and 1.25 or 0.8
            end
            squadData.raptorsquadweight = math.max(1, math.floor(weight * bias + 0.5))
          end
          squadData.raptorx_squadweight_adjusted = 1
        end
        if not u.customparams.raptorx_ultra_hardened then
          u.customparams.raptorx_ultra_hardened = 1
          local hp, damage, reload, speed, floor = 3, 0.85, 1.00, 1.03, 8000
          if u.canfly then floor = 25000 end
          if name:find("_t4_", 1, true) or elites[name] then
            hp, damage, reload, speed, floor = 10, 1.15, 0.95, 1.03, 200000
          end
          if name:find("matriarch", 1, true) or name:find("queen", 1, true) or apex[name] then
            hp, damage, reload, speed, floor = 16, 1.35, 0.92, 1.0, 2500000
          end
          if apex[name] then floor = 8000000 end
          if customUnit then
            hp, damage, reload, speed, floor = hp * 1.15, damage * 1.05, reload * 0.98, speed * 1.02, floor * 1.15
          end
          local health = tonumber(u.health) or tonumber(u.maxdamage) or 1
          u.health = math.max(health * hp, floor) * angerScale
          u.maxdamage = u.health
          u.autoheal = math.max(tonumber(u.autoheal) or 0, math.min(25000, u.health * 0.001))
          u.speed = u.speed * speed
          for _, field in ipairs({ "maxacc", "maxdec", "turnrate" }) do
            if type(u[field]) == "number" then u[field] = u[field] * speed end
          end
          local weaponsSeen = {}
          for _, w in pairs(u.weapondefs or {}) do
            if type(w) == "table" and not weaponsSeen[w] then
              weaponsSeen[w] = true
              for armor, value in pairs(w.damage or {}) do
                if type(value) == "number" then w.damage[armor] = value * damage * damageAngerScale end
              end
              if type(w.reloadtime) == "number" and w.reloadtime > 0 then
                local volley = math.max(0, ((tonumber(w.burst) or 1) - 1) * (tonumber(w.burstrate) or 0))
                w.reloadtime = math.max(w.reloadtime * reload, volley + 0.05)
              end
            end
          end
        end
      end
    end
  end
end
