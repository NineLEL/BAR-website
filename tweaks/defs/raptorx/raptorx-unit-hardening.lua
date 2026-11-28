-- Ultra Nightmare: mobile Raptor combat only, after clone and siege creation.
-- Larger squads and higher HP floors ramp up pressure as the roster unlocks.
-- Bosses are tough, not EMP-immune; original scripts/targeting/effects stay intact.
-- RaptorX clone HP rises 7% and damage rises 2% per 10 anger, based on squad unlock tier.
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
        local squadMinimumAnger = tonumber(squadData.raptorsquadminanger)
        local minimumAnger = squadMinimumAnger or 0
        local angerTier = math.min(10, math.floor(minimumAnger / 10))
        local angerScale = customUnit and (1.07 ^ angerTier) or 1
        local damageAngerScale = customUnit and (1.02 ^ angerTier) or 1
        -- BAR uses squad size as a spawn cap; keep solo encounters at one.
        if squadData.raptorcustomsquad and not squadData.raptorx_squadweight_adjusted then
          local weight = tonumber(squadData.raptorsquadweight)
          if weight then
            local bias = customUnit and 1.40 or 0.80
            if minimumAnger < 25 then
              bias = customUnit and 0.90 or 1.00
            end
            squadData.raptorsquadweight = math.max(1, math.floor(weight * bias + 0.5))
          end
          local amount = tonumber(squadData.raptorsquadunitsamount)
          if amount and amount > 1 then
            local sizeMultiplier = u.canfly and 1.25 or 1.35
            squadData.raptorsquadunitsamount = math.floor(amount * sizeMultiplier + 0.5)
          end
          squadData.raptorx_squadweight_adjusted = 1
        end
        if not u.customparams.raptorx_ultra_hardened then
          u.customparams.raptorx_ultra_hardened = 1
          local tierOne = name:find("_t1_", 1, true)
          local early = minimumAnger < 25 or tierOne
          local hp, damage, reload, speed, floor = 2.8, 0.78, 0.97, 1.00, 3200
          if u.canfly then floor = 4800 end
          if tierOne or (squadMinimumAnger and squadMinimumAnger < 25) then
            hp, damage, reload, speed, floor = 1.40, 0.65, 1.03, 0.96, 0
          elseif early then
            -- Native units without squad metadata have no known unlock tier here.
            hp, damage, reload, speed, floor = 1.65, 0.68, 1.00, 0.97, 0
          end
          if name:find("_t4_", 1, true) or elites[name] then
            hp, damage, reload, speed, floor = 8.5, 0.94, 0.96, 1.00, (u.canfly and 60000 or 120000)
          end
          if name:find("matriarch", 1, true) or name:find("queen", 1, true) or apex[name] then
            hp, damage, reload, speed, floor = 14, 1.00, 0.94, 0.98, 1750000
          end
          if apex[name] then floor = 5500000 end
          if customUnit then
            hp, damage, reload, speed, floor = hp * 1.06, damage * 0.95, reload * 1.00, speed * 1.00, floor * 1.06
          end
          local health = tonumber(u.health) or tonumber(u.maxdamage) or 1
          u.health = math.max(health * hp, floor) * angerScale
          u.maxdamage = u.health
          local regen = early and 0 or math.min(12000, u.health * 0.0005)
          u.autoheal = math.max(tonumber(u.autoheal) or 0, regen)
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
