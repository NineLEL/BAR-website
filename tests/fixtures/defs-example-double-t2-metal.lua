-- Example tweakdefs: double metal cost of all T2+ units.
-- Drop your own .lua files in tweaks/defs/ — toggle them in the Server library tab.
for name, ud in pairs(UnitDefs) do
  local tech = ud.customparams and ud.customparams.techlevel or 1
  if tech >= 2 then
    ud.metalcost = (ud.metalcost or 0) * 2
  end
end
