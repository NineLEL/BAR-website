-- Player-buildable epic walls: 15 million HP, deliberately very expensive.
-- Added to T2 constructor menus, same access policy as other player turret packs.
do
local function copy(t)
  if type(t) ~= "table" then return t end
  local r = {}
  for k, v in pairs(t) do r[copy(k)] = copy(v) end
  return r
end
local BUILDERS = { "armack", "corack", "legack", "armacv", "coracv", "legacv", "armaca", "coraca", "legaca", "armacsub", "coracsub", "armcs", "corcs", "armch", "corch", "legch", "armcsa", "corcsa", "legnavyconship", "leganavyconsub", "legspcon" }
local WALLS = {
  { dst = "player_epicwall_arm", src = "armfort", nm = "Epic Wall", tip = "15-million-HP experimental wall. Nearly immovable; costly and slow to build." },
  { dst = "player_epicwall_cor", src = "corfort", nm = "Epic Bulwark", tip = "15-million-HP experimental wall. Nearly immovable; costly and slow to build." },
  { dst = "player_epicwall_leg", src = "legforti", nm = "Epic Rampart", tip = "15-million-HP experimental wall. Nearly immovable; costly and slow to build." },
}
for _, p in ipairs(WALLS) do
  local s = UnitDefs[p.src]
  if s ~= nil and UnitDefs[p.dst] == nil then
    local u = copy(s)
    u.unitname, u.name, u.description = p.dst, p.nm, p.tip
    u.health = 15000000
    u.metalcost = 25000
    u.energycost = 500000
    u.buildtime = 500000
    u.maxthisunit = 20
    u.energyupkeep = 250
    u.customparams = u.customparams or {}
    u.customparams.techlevel = 4
    for _, l in ipairs({ "en", "de", "fr", "es", "it", "ru", "zh", "cs", "hr", "lt" }) do
      u.customparams["i18n_" .. l .. "_humanname"] = p.nm
      u.customparams["i18n_" .. l .. "_tooltip"] = p.tip
    end
    UnitDefs[p.dst] = u
    if UnitDefNames ~= nil then UnitDefNames[p.dst] = u end
    for _, b in ipairs(BUILDERS) do
      local bu = UnitDefs[b]
      if bu ~= nil then
        bu.buildoptions = bu.buildoptions or {}
        local exists = false
        for _, x in ipairs(bu.buildoptions) do if x == p.dst then exists = true break end end
        if not exists then bu.buildoptions[#bu.buildoptions + 1] = p.dst end
      end
    end
  end
end
end
