-- Player-buildable siege walls for the existing constructor menus.
do
local function copy(t)
  if type(t) ~= "table" then return t end
  local r = {}
  for k, v in pairs(t) do r[copy(k)] = copy(v) end
  return r
end
local BUILDERS = { "armack", "corack", "legack", "armacv", "coracv", "legacv", "armaca", "coraca", "legaca", "armacsub", "coracsub", "armcs", "corcs", "armch", "corch", "legch", "armcsa", "corcsa", "legnavyconship", "leganavyconsub", "legspcon" }
local LOCALES = { "en", "de", "fr", "es", "it", "ru", "zh", "cs", "hr", "lt" }
local TIERS = {
  [2] = { id = "reinforced", title = "Reinforced", metal = 650, energy = 6500, time = 12000, crush = 2000 },
  [3] = { id = "bastion", title = "Bastion", metal = 2300, energy = 32000, time = 44000, crush = 12000 },
  [4] = { id = "epic", title = "Epic", metal = 6500, energy = 105000, time = 120000, crush = 12000 },
}
-- Stats within each faction are { HP, idle HP/s, idle seconds }, ordered T2–T4.
local FACTIONS = {
  { id = "arm", source = "armfort", title = "Wall", stats = { { 24000, 100, 30 }, { 76000, 220, 30 }, { 165000, 400, 30 } } },
  { id = "cor", source = "corfort", title = "Bulwark", stats = { { 33000, 60, 45 }, { 105000, 130, 45 }, { 215000, 240, 45 } } },
  { id = "leg", source = "legforti", title = "Rampart", timeScale = 0.75, stats = { { 27000, 70, 40 }, { 86000, 150, 40 }, { 180000, 300, 40 } } },
}
local function installWall(level, faction)
  local tier = TIERS[level]
  local id = "player_" .. tier.id .. "wall_" .. faction.id
  if UnitDefs[id] == nil then
    local source = UnitDefs[faction.source]
    if source == nil then return end
    local stats = faction.stats[level - 1]
    local health, regen, delay = stats[1], stats[2], stats[3]
    local name = tier.title .. " " .. faction.title
    local tooltip = string.format("Siege wall: %d HP, %d crush resistance, no upkeep. Builders cannot repair it; it regenerates %d HP/s after %d seconds without damage.", health, tier.crush, regen, delay)
    local u = copy(source)
    u.unitname, u.name, u.description = id, name, tooltip
    u.health = health
    u.metalcost = tier.metal
    u.energycost = tier.energy
    u.buildtime = tier.time * (faction.timeScale or 1)
    u.maxthisunit = 500
    u.energyupkeep = 0
    u.crushresistance = tier.crush
    u.autoheal = 0
    u.idleautoheal = regen
    u.idletime = delay * 30
    u.hidedamage = false
    u.repairable = false
    u.customparams = u.customparams or {}
    u.customparams.techlevel = level
    u.customparams.objectify = nil
    if type(u.corpse) == "string" and u.featuredefs then
      local corpse = u.featuredefs[u.corpse:lower()] or u.featuredefs[u.corpse]
      if corpse then
        corpse.blocking = false
        corpse.resurrectable = 0
      end
    end
    for _, l in ipairs(LOCALES) do
      u.customparams["i18n_" .. l .. "_humanname"] = name
      u.customparams["i18n_" .. l .. "_tooltip"] = tooltip
    end
    UnitDefs[id] = u
  end
  if UnitDefNames ~= nil then UnitDefNames[id] = UnitDefs[id] end
  for _, b in ipairs(BUILDERS) do
    if level == 4 or b:sub(1, 3) == faction.id then
      local bu = UnitDefs[b]
      if bu ~= nil then
        bu.buildoptions = bu.buildoptions or {}
        local exists = false
        for _, x in ipairs(bu.buildoptions) do if x == id then exists = true break end end
        if not exists then bu.buildoptions[#bu.buildoptions + 1] = id end
      end
    end
  end
end
-- Keep the existing Epic block in order and append the faction-specific tiers.
for _, level in ipairs({ 4, 2, 3 }) do
  for _, faction in ipairs(FACTIONS) do installWall(level, faction) end
end
end
