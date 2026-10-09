-- Extreme native Scavenger final boss, current v4 and legacy v2.
-- Source: BAR units/Scavengers/Boss/{scavengerbossv4,armscavengerbossv2}.lua
-- Preserve models, weapon slots, target categories and scripted sensor weapons.
-- No extra shield slot: the native scripts already use their supported mounts.
do
  local difficulties = { "veryeasy", "easy", "normal", "hard", "veryhard", "epic" }
  local families = { "scavengerbossv4_", "armscavengerbossv2_" }
  local combat = {
    machinegun = true, torpedo = true, shotgunarm = true,
    shoulderturrets = true, missilelauncher = true, eaterbeam = true,
    special_disintegratorxl = true, turbo_missilelauncher = true,
    turbo_napalm = true, turbo_machinegun = true, turbo_shoulderturrets = true,
    disintegratorxl = true, corkorg_laser = true,
  }
  for _, family in ipairs(families) do
    for _, difficulty in ipairs(difficulties) do
      local u = UnitDefs[family .. difficulty]
      if u then
        u.customparams = u.customparams or {}
        if not u.customparams.scavx_extreme_boss then
          u.customparams.scavx_extreme_boss = 1
          u.health = u.health * 12
          u.autoheal = math.max(tonumber(u.autoheal) or 0, u.health * 0.0005)
          u.speed = u.speed * 1.3
          u.maxacc = u.maxacc * 2
          u.maxdec = u.maxdec * 2
          u.turnrate = u.turnrate * 1.5
          u.sightdistance = math.max(u.sightdistance or 0, 3000)
          u.radardistance = math.max(u.radardistance or 0, 3500)
          u.sonardistance = math.max(u.sonardistance or 0, 2000)
          u.stealth = true
          u.customparams.paralyzemultiplier = 0.005
          local seen = {}
          for name, w in pairs(u.weapondefs or {}) do
            if combat[name] and not seen[w] then
              seen[w] = true
              for armor, damage in pairs(w.damage or {}) do
                if type(damage) == "number" then w.damage[armor] = damage * 4 end
              end
              if type(w.reloadtime) == "number" then
                -- Keep burst weapons' reloads at least as long as their volley.
                local volley = math.max(0, (w.burst or 1) - 1) * (w.burstrate or 0)
                w.reloadtime = math.max(w.reloadtime * 0.6, volley + 0.05)
              end
              -- Native shoulder artillery already has map-wide range.
              if type(w.range) == "number" and w.range < 10000 then
                w.range = w.range * 1.25
                if type(w.flighttime) == "number" then w.flighttime = w.flighttime * 1.25 end
              end
              if type(w.stockpiletime) == "number" then w.stockpiletime = w.stockpiletime * 0.5 end
              if type(w.energypershot) == "number" then w.energypershot = w.energypershot * 0.25 end
              local cp = w.customparams
              if cp and type(cp.area_onhit_damage) == "number" then
                cp.area_onhit_damage = cp.area_onhit_damage * 4
              end
            end
          end
        end
      end
    end
  end
end
