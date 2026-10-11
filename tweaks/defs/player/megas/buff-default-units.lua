local HEALTH_MULTIPLIER = 1.2
local DAMAGE_MULTIPLIER = 1.1

-- Stock land Experimental Gantry rosters from BAR's Armada, Cortex, and Legion defs.
local gantryUnits = {
  armshltx = {
    "armbanth",
    "armraz",
    "armmar",
    "armvang",
    "armlun",
    "armthor",
  },
  corgant = {
    "corkorg",
    "corkarg",
    "corjugg",
    "corshiva",
    "corcat",
    "corsok",
    "cordemon",
  },
  leggant = {
    "legeheatraymech",
    "legeallterrainmech",
    "legjav",
    "legelrpcmech",
    "legehovertank",
    "legerailtank",
    "legeshotgunmech",
    "legkeres",
  },
}

for _, unitNames in pairs(gantryUnits) do
  for _, unitName in ipairs(unitNames) do
    local unitDef = UnitDefs and UnitDefs[unitName]
    if unitDef then
      local customParams = unitDef.customparams
      if type(customParams) ~= "table" then
        customParams = {}
        unitDef.customparams = customParams
      end

      if not customParams.player_default_units_buff then
        customParams.player_default_units_buff = 1

        local health = unitDef.health or unitDef.maxdamage
        if type(health) == "number" then
          unitDef.health = health * HEALTH_MULTIPLIER
          if unitDef.maxdamage ~= nil then
            unitDef.maxdamage = health * HEALTH_MULTIPLIER
          end
        end

        local weaponDefs = unitDef.weapondefs
        if type(weaponDefs) == "table" then
          local buffedWeaponDefs = {}
          for weaponName, weaponDef in pairs(weaponDefs) do
            buffedWeaponDefs[weaponName] = weaponDef
          end

          for weaponName, weaponDef in pairs(weaponDefs) do
            if type(weaponDef) == "table" and type(weaponDef.damage) == "table" then
              -- Copy these tables so shared weapon definitions used by other units stay untouched.
              local buffedWeaponDef = {}
              for key, value in pairs(weaponDef) do
                buffedWeaponDef[key] = value
              end

              local buffedDamage = {}
              for armorType, value in pairs(weaponDef.damage) do
                buffedDamage[armorType] = type(value) == "number"
                  and value * DAMAGE_MULTIPLIER
                  or value
              end

              buffedWeaponDef.damage = buffedDamage
              buffedWeaponDefs[weaponName] = buffedWeaponDef
            end
          end
          unitDef.weapondefs = buffedWeaponDefs
        end
      end
    end
  end
end
