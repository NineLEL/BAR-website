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
    siege = { name = "Raptor Siege Howitzer", weapontype = "Cannon", range = 10200, reloadtime = 4.4, weaponvelocity = 3000, flighttime = 20, areaofeffect = 600, damage = { default = 28000, shields = 56000 }, explosiongenerator = "custom:genericshellexplosion-large", soundstart = "mortarhvy1", soundhit = "weapons/xplolarge1.wav" },
    cluster = { name = "Raptor Cluster Rain", weapontype = "Cannon", range = 7600, reloadtime = 3.2, weaponvelocity = 2700, flighttime = 16, burst = 7, burstrate = 0.12, areaofeffect = 320, sprayangle = 900, damage = { default = 6500, shields = 14000 }, explosiongenerator = "custom:genericshellexplosion-medium", soundstart = "mortar1", soundhit = "weapons/xplomed1.wav" },
    empmortar = { name = "Raptor Disruption Mortar", weapontype = "Cannon", range = 6000, reloadtime = 3.6, weaponvelocity = 2400, flighttime = 14, areaofeffect = 520, paralyzer = true, paralyzetime = 12, damage = { default = 18000, shields = 48000 }, rgbcolor = "0.2 0.75 1", explosiongenerator = "custom:exp_emp_large", soundstart = "mortarhvy1", soundhit = "weapons/lashit.wav", customparams = { disruption = true } },
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
    end
  end
end
