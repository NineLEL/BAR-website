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
    siege = { name = "Raptor Siege Howitzer", weapontype = "Cannon", range = 9200, reloadtime = 6.5, weaponvelocity = 3000, flighttime = 20, areaofeffect = 420, damage = { default = 6000, shields = 12000 }, explosiongenerator = "custom:genericshellexplosion-large", soundstart = "mortarhvy1", soundhit = "weapons/xplolarge1.wav" },
    cluster = { name = "Raptor Cluster Rain", weapontype = "Cannon", range = 7600, reloadtime = 5.5, weaponvelocity = 2800, flighttime = 18, burst = 6, burstrate = 0.12, areaofeffect = 260, sprayangle = 800, damage = { default = 1200, shields = 3000 }, explosiongenerator = "custom:genericshellexplosion-medium", soundstart = "mortar1", soundhit = "weapons/xplomed1.wav" },
    empmortar = { name = "Raptor Disruption Mortar", weapontype = "Cannon", range = 6400, reloadtime = 6.0, weaponvelocity = 2600, flighttime = 16, areaofeffect = 380, paralyzer = true, paralyzetime = 8, damage = { default = 4000, shields = 10000 }, rgbcolor = "0.2 0.75 1", explosiongenerator = "custom:exp_emp_large", soundstart = "mortarhvy1", soundhit = "weapons/lashit.wav", customparams = { disruption = true } },
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
      unit.health = health * 1.5
      unit.maxdamage = unit.health
      unit.autoheal = math.max(tonumber(unit.autoheal) or 0, unit.health * 0.003)
    end
  end
end
