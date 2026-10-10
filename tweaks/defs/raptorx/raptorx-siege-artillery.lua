-- Ultra Nightmare siege variants. Alphabetical order loads this after the core
-- and before unit hardening. Native Raptor models/scripts retain weapon slot 1.
do
  local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do result[copy(key)] = copy(child) end
    return result
  end
  local weapons = {
    siege = { name = "Raptor Siege Howitzer", weapontype = "Cannon", range = 12800, reloadtime = 3.2, weaponvelocity = 3400, flighttime = 24, areaofeffect = 760, damage = { default = 48000, shields = 96000 }, explosiongenerator = "custom:genericshellexplosion-large", soundstart = "mortarhvy1", soundhit = "weapons/xplolarge1.wav" },
    cluster = { name = "Raptor Cluster Rain", weapontype = "Cannon", range = 9800, reloadtime = 2.4, weaponvelocity = 3100, flighttime = 20, burst = 10, burstrate = 0.1, areaofeffect = 420, sprayangle = 700, damage = { default = 10500, shields = 24000 }, explosiongenerator = "custom:genericshellexplosion-medium", soundstart = "mortar1", soundhit = "weapons/xplomed1.wav" },
    empmortar = { name = "Raptor Disruption Mortar", weapontype = "Cannon", range = 8200, reloadtime = 2.8, weaponvelocity = 2900, flighttime = 18, areaofeffect = 680, paralyzer = true, paralyzetime = 20, damage = { default = 30000, shields = 80000 }, rgbcolor = "0.2 0.75 1", explosiongenerator = "custom:exp_emp_large", soundstart = "mortarhvy1", soundhit = "weapons/lashit.wav", customparams = { disruption = true } },
  }
  local specs = {
    { unit = "raptorx_siegehowler", weapon = "siege" },
    { unit = "raptorx_clusterrain", weapon = "cluster" },
    { unit = "raptorx_disruptionmortar", weapon = "empmortar" },
  }
  for _, spec in ipairs(specs) do
    local unit = UnitDefs[spec.unit]
    if unit and unit.weapons and unit.weapons[1] then
      unit.weapondefs = unit.weapondefs or {}
      unit.weapondefs[spec.weapon] = copy(weapons[spec.weapon])
      unit.weapons[1].def = spec.weapon:upper()
      unit.sightdistance = math.max(tonumber(unit.sightdistance) or 0, weapons[spec.weapon].range)
      local health = tonumber(unit.health) or tonumber(unit.maxdamage) or 1
      unit.health = health * 4
      unit.maxdamage = unit.health
      unit.autoheal = math.max(tonumber(unit.autoheal) or 0, unit.health * 0.01)
    end
  end
end
