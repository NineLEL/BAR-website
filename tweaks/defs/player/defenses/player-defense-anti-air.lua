-- Standalone direct-damage T3 AA. Chassis use their stock slot-1 scripts.
do
  local U = UnitDefs
  local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for k, v in pairs(value) do result[k] = copy(v) end
    return result
  end

  -- Fresh weapon and mount tables: only the chassis and its assets are inherited.
  local flak = {
    weapontype = "Cannon", burnblow = true, gravityaffected = "true", mygravity = 0.01,
    accuracy = 650, cylindertargeting = 1, predictboost = 1, stages = 0,
    soundstart = "flakfire", soundhitwet = "splslrg",
  }
  local missile = {
    weapontype = "MissileLauncher", tracks = true, turnrate = 99000,
    burnblow = true, cylindertargeting = 1, trajectoryheight = 0.12,
    smoketrail = true, smoketrailcastshadow = false, castshadow = false,
    texture1 = "null", smokecolor = 0.9, soundhitwet = "splslrg",
  }

  -- Ranges are elmos; reload and burst intervals are in seconds (30 sim frames/s).
  -- Reload starts on the first shot, so the two salvos fit entirely within their reload.
  local factions = {
    { prefix = "arm", units = {
      {
        id = "silencearray", src = "armmercury", name = "Silence Array",
        tip = "Heavy anti-air laser bolts for bombers and gunships. No splash.",
        metal = 7200, energy = 125000, build = 105000, hp = 11500, damage = 7200,
        bad = "LIGHTAIRSCOUT", weapon = {
          weapontype = "LaserCannon", range = 1750, reloadtime = 3,
          -- Recoil rounds LaserCannon range down to a multiple of per-frame speed.
          -- 2100 elmos/s gives exactly 70 elmos/frame and 1750 elmos in 25 frames.
          weaponvelocity = 2100, burnblow = false, heightmod = 1, predictboost = 1,
          impactonly = true, areaofeffect = 0, collidenontarget = false,
          duration = 0.085, thickness = 4, rgbcolor = "0.25 0.75 1",
          soundstart = "railgun3", soundhit = "impact", explosiongenerator = "custom:plasmahit-sparkonly",
        },
      },
      {
        id = "skywardlance", src = "armflak", name = "Skyward Lance",
        tip = "Rapid precision beams for fast aircraft.",
        metal = 6800, energy = 115000, build = 95000, hp = 10000, damage = 540,
        muzzle = "custom:barrelshot-greenblaster", weapon = {
          weapontype = "BeamLaser", range = 1400, reloadtime = 0.3,
          beamtime = 0.034, beamttl = 3, minintensity = 1, cylindertargeting = 1,
          impactonly = true, areaofeffect = 0, rgbcolor = "0.30 1 0.65", thickness = 3,
          soundstart = "beamershot2", explosiongenerator = "custom:laserhit-beamer",
        },
      },
    } },
    { prefix = "cor", units = {
      {
        id = "thunderscreen", src = "corflak", name = "Thunder Screen",
        tip = "Wide airburst flak for clustered raids.",
        metal = 8200, energy = 150000, build = 120000, hp = 15000, damage = 3600,
        base = flak, weapon = {
          range = 1250, reloadtime = 1.5, areaofeffect = 320, edgeeffectiveness = 0.5,
          weaponvelocity = 1600, cegtag = "flaktrailaa", explosiongenerator = "custom:flak", soundhit = "flakhit2",
        },
      },
      {
        id = "dreadlance", src = "corscreamer", name = "Dreadlance",
        tip = "Long-range heavy tracking missiles with a small blast radius.",
        metal = 10500, energy = 205000, build = 145000, hp = 13500, damage = 4000,
        bad = "LIGHTAIRSCOUT", base = missile, weapon = {
          range = 2550, reloadtime = 2, areaofeffect = 64, edgeeffectiveness = 0.25,
          startvelocity = 1400, weaponvelocity = 1850, weaponacceleration = 1000, flighttime = 2.7,
          model = "corscreamermissile.s3o", cegtag = "missiletrailaa-large",
          explosiongenerator = "custom:genericshellexplosion-medium-aa",
          texture2 = "smoketrailaaflak", smokeperiod = 2, smokesize = 9, smoketime = 20,
          soundstart = "aarocket", soundhit = "impact",
        },
      },
    } },
    { prefix = "leg", units = {
      {
        id = "stormguard", src = "legflak", name = "Storm Guard",
        tip = "Short, rapid flak salvos with tight airbursts.",
        metal = 7900, energy = 145000, build = 116000, hp = 12500, damage = 840,
        base = flak, weapon = {
          range = 1350, reloadtime = 0.9, burst = 3, burstrate = 0.1,
          areaofeffect = 104, edgeeffectiveness = 0.65, accuracy = 350,
          weaponvelocity = 2400, cegtag = "flaktrailaamg", explosiongenerator = "custom:flakshard",
          soundhit = "flakhit",
        },
      },
      {
        id = "skyspearbattery", src = "leglupara", name = "Skyspear Battery",
        tip = "Staggered salvos of smaller guided anti-air missiles.",
        metal = 9300, energy = 175000, build = 132000, hp = 11500, damage = 900,
        base = missile, muzzle = "custom:barrelshot-medium-aa", weapon = {
          range = 2250, reloadtime = 1.6, burst = 4, burstrate = 0.2,
          areaofeffect = 48, edgeeffectiveness = 0.2,
          startvelocity = 1000, weaponvelocity = 1650, weaponacceleration = 900, flighttime = 2.7,
          model = "legsmallrocket.s3o", cegtag = "missiletrailaa",
          explosiongenerator = "custom:genericshellexplosion-small-aa",
          texture2 = "smoketrailaa", smokeperiod = 7, smokesize = 4.2, smoketime = 10,
          soundstart = "packolau", soundhit = "packohit",
        },
      },
    } },
  }

  local function register(faction, spec)
    local id = "player_" .. faction .. "_" .. spec.id
    local u = U[id]
    if not u then
      local src = U[spec.src]
      if not src then return end
      u = copy(src)
      local w = copy(spec.base or {})
      for k, v in pairs(spec.weapon) do w[k] = v end
      w.name, w.damage = spec.name, { default = 0, vtol = spec.damage }
      w.turret, w.noselfdamage, w.canattackground = true, true, false
      w.stockpile, w.paralyzer, w.energypershot, w.metalpershot = false, false, 0, 0
      w.avoidfriendly, w.avoidfeature, w.collidefriendly, w.collidefeature = false, false, false, false
      w.craterareaofeffect, w.cratermult, w.craterboost, w.impulsefactor = 0, 0, 0, 0
      u.weapondefs = { aa = w }
      local mount = { def = "aa", onlytargetcategory = "VTOL", fastautoretargeting = true }
      mount.badtargetcategory = spec.bad
      -- Recoil value 1 holds shots outside the arc rather than firing straight ahead (2).
      if w.burst then mount.burstcontrolwhenoutofarc = 1 end
      u.weapons = { mount }
      if spec.muzzle then
        -- The stock COB emits index 0 (Lua index 1) in FireWeapon1.
        u.sfxtypes = u.sfxtypes or {}
        u.sfxtypes.explosiongenerators = u.sfxtypes.explosiongenerators or {}
        u.sfxtypes.explosiongenerators[1] = spec.muzzle
      end
      u.unitname, u.name = id, spec.name
      u.metalcost, u.energycost, u.buildtime = spec.metal, spec.energy, spec.build
      u.health, u.maxdamage = spec.hp, spec.hp
      -- BAR's air LOS resolution is 8 * 2^4: round up rather than losing a cell to truncation.
      u.airsightdistance = math.max(u.airsightdistance or 0, math.ceil(w.range / 128) * 128)
      local cp = u.customparams or {}
      u.customparams = cp
      cp.techlevel = 3
      for _, lang in ipairs({ "en", "de", "fr", "es", "it", "ru", "zh", "cs", "hr", "lt" }) do
        cp["i18n_" .. lang .. "_humanname"] = spec.name
        cp["i18n_" .. lang .. "_tooltip"] = "T3 anti-air. " .. spec.tip
      end
      U[id] = u
      if UnitDefNames then UnitDefNames[id] = u end
    elseif u.unitname ~= id then
      return -- Do not teach a conflicting, unrelated definition.
    end

    for _, suffix in ipairs({ "nanotct3", "nanotct4" }) do
      local builder = U[faction .. suffix]
      if builder then
        local options = builder.buildoptions or {}
        builder.buildoptions = options
        local found = false
        for _, option in ipairs(options) do
          if option:lower() == id then found = true break end
        end
        if not found then options[#options + 1] = id end
      end
    end
  end

  for _, faction in ipairs(factions) do
    for _, spec in ipairs(faction.units) do register(faction.prefix, spec) end
  end
end
