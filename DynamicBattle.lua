local zones = {}
local zonename = 'CombatZone'
local zonenum = 1

debug = false

--[[
while trigger.misc.getZone(zonename .. zonenum) ~= nil do
    table.insert(zones, trigger.misc.getZone(zonename .. zonenum))
    zonenum = zonenum + 1
end
]]--
--https://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect

function GetIntersect(S1P1, S1P2, S2P1, S2P2)
    local V1 = GetV2(S1P1, S1P2)
    local V2 = GetV2(S2P1, S2P2)
    if GetV2Cross(V1, V2) ~= 0 then
        local t = GetV2Cross(SubtractV2(S2P1, S1P1), V2) / GetV2Cross(V1, V2)
        if t >= 0 and t <= 1 then
            local u = GetV2Cross(SubtractV2(S2P1, S1P1), V1) / GetV2Cross(V1, V2)
            if u >= 0 and u <= 1 then
                return true
            end
        end
    end
    return false
end

function GetV2Cross(V1, V2)
    return V1.x * V2.z - V1.z * V2.x
end

function GetV2(P1, P2)
    return {x = P2.x - P1.x, z = P2.z - P1.z}
end

function SubtractV2(V1, V2)
    return {x = V1.x - V2.x, z = V1.z - V2.z}
end

function AddV2(V1, V2)
    return {x = V1.x + V2.x, z = V1.z + V2.z}
end

if debug then
    assert(GetIntersect({x = 1, z = 1}, {x = 10, z = 10}, {x = 0, z = 0}, {x = 9, z = 10}) == false)
    assert(GetIntersect({x = 1, z = 1}, {x = 10, z = 10}, {x = 10, z = 0}, {x = 0, z = 10}) == true)
    assert(GetIntersect({x = 1, z = 1}, {x = 10, z = 10}, {x = 0, z = 1}, {x = 9, z = 10}) == false)
    assert(GetIntersect({x = 1, z = 1}, {x = 10, z = 10}, {x = 0, z = 1}, {x = 9, z = 9}) == true)
    assert(GetIntersect({x = 1, z = 1}, {x = 10, z = 10}, {x = 2, z = 0}, {x = 12, z = 12}) == false)
    assert(GetIntersect({x = 1, z = 1}, {x = 10, z = 10}, {x = 2, z = 0}, {x = 9, z = 10}) == true)
    assert(GetIntersect({x = 10, z = 1}, {x = 1, z = 10}, {x = 2, z = 0}, {x = 12, z = 12}) == true)
    assert(GetIntersect({x = 10, z = 1}, {x = 1, z = 10}, {x = 12, z = 2}, {x = 2, z = 12}) == false)
end
