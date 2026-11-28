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
    siege = { name = "Raptor Siege Howitzer", weapontype = "Cannon", range = 7800, reloadtime = 7.5, weaponvelocity = 2800, flighttime = 20, areaofeffect = 320, damage = { default = 3600, shields = 7200 }, explosiongenerator = "custom:genericshellexplosion-large", soundstart = "mortarhvy1", soundhit = "weapons/xplolarge1.wav" },
    cluster = { name = "Raptor Cluster Rain", weapontype = "Cannon", range = 6400, reloadtime = 6.75, weaponvelocity = 2600, flighttime = 18, burst = 5, burstrate = 0.14, areaofeffect = 200, sprayangle = 900, damage = { default = 720, shields = 1800 }, explosiongenerator = "custom:genericshellexplosion-medium", soundstart = "mortar1", soundhit = "weapons/xplomed1.wav" },
    empmortar = { name = "Raptor Disruption Mortar", weapontype = "Cannon", range = 5400, reloadtime = 8.0, weaponvelocity = 2500, flighttime = 16, areaofeffect = 300, paralyzer = true, paralyzetime = 6, damage = { default = 1900, shields = 4800 }, rgbcolor = "0.2 0.75 1", explosiongenerator = "custom:exp_emp_large", soundstart = "mortarhvy1", soundhit = "weapons/lashit.wav", customparams = { disruption = true } },
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
      unit.health = health * 1.25
      unit.maxdamage = unit.health
      unit.autoheal = math.max(tonumber(unit.autoheal) or 0, unit.health * 0.0015)
    end
  end
end
