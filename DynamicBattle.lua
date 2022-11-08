local zones = {}
local zonename = 'CombatZone'
local zonenum = 1

while trigger.misc.getZone(zonename .. zonenum) ~= nil do
    table.insert(zones, trigger.misc.getZone(zonename .. zonenum))
    zonenum = zonenum + 1
end

--https://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect