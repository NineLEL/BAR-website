-- RaptorX artillery variants. Loaded after raptorx-custom-units.lua.
do
  local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do result[copy(key)] = copy(child) end
    return result
  end
  local weapons = {
    siege = { name = "Raptor Siege Howitzer", weapontype = "Cannon", range = 2700, reloadtime = 4.4, weaponvelocity = 720, areaofeffect = 340, damage = { default = 6800, shields = 2200 }, explosiongenerator = "custom:genericshellexplosion-large", soundstart = "mortarhvy1", soundhit = "weapons/xplolarge1.wav" },
    cluster = { name = "Raptor Cluster Rain", weapontype = "Cannon", range = 2200, reloadtime = 3.2, weaponvelocity = 880, burst = 7, burstrate = 0.12, areaofeffect = 145, sprayangle = 900, damage = { default = 1450, shields = 500 }, explosiongenerator = "custom:genericshellexplosion-medium", soundstart = "mortar1", soundhit = "weapons/xplomed1.wav" },
    empmortar = { name = "Raptor Disruption Mortar", weapontype = "Cannon", range = 2300, reloadtime = 3.6, weaponvelocity = 760, areaofeffect = 260, paralyzer = true, paralyzetime = 8, damage = { default = 2400, shields = 4400 }, rgbcolor = "0.2 0.75 1", explosiongenerator = "custom:exp_emp_large", soundstart = "mortarhvy1", soundhit = "weapons/lashit.wav", customparams = { disruption = true } },
  }
  local specs = {
    { unit = "raptorx_siegehowler", weapon = "siege" },
    { unit = "raptorx_clusterrain", weapon = "cluster" },
    { unit = "raptorx_disruptionmortar", weapon = "empmortar" },
  }
  for _, spec in ipairs(specs) do
    local unit = UnitDefNames and UnitDefNames[spec.unit]
    if unit then
      unit.weapondefs = unit.weapondefs or {}
      unit.weapondefs[spec.weapon] = copy(weapons[spec.weapon])
      unit.weapons = unit.weapons or {}
      if unit.weapons[1] then unit.weapons[1].def = spec.weapon:upper() end
    end
  end
end
