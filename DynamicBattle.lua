DynamicBattle = {
    zones = {},
    -- zonename = 'CombatZone'
    connections = {}
}
--[[

connection = {
    p1 = zonesindex
    p2 = zonesindex
    d = distance
}

]]--

function DynamicBattle:generate(zonename)
    local zonenum = 1
    trigger.action.outText("creating zones", 10, false)
    while trigger.misc.getZone(zonename .. zonenum) ~= nil do
        table.insert(self.zones, trigger.misc.getZone(zonename .. zonenum))
        zonenum = zonenum + 1
    end
    trigger.action.outText(zonenum .. " zones found", 10, false)
    trigger.action.outText("creating connections", 10, false)
    for outerkey, outerzone in pairs(self.zones) do
        for innerkey, innerzone in pairs(self.zones) do
            if key ~= innerkey then 
                local present = false
                for key, value in pairs(self.connections) do
                    if (value.p1 == outerkey and value.p2 == innerkey) or (value.p2 == outerkey and value.p1 == innerkey) then
                        present = true
                    end
                end
                if not present then
                    local connection = {
                        p1 = outerkey,
                        p2 = innerkey,
                        d = getV2Distance(outerzone.point, innerzone.point)
                    }
                    table.insert(self.connections, connection)
                end
            end
        end
    end

    for key, connection in pairs(self.connections) do 

    end

    trigger.action.outText("drawing connections", 10, false)
    for key, connection in pairs(self.connections) do
        trigger.action.lineToAll(-1, key, self.zones[connection.p1].point, self.zones[connection.p2].point, {1, 0, 0, 1}, 1, true)
    end
debug = false

--[[
while trigger.misc.getZone(zonename .. zonenum) ~= nil do
    table.insert(zones, trigger.misc.getZone(zonename .. zonenum))
    zonenum = zonenum + 1
end
]]--
--https://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect

function DynamicBattle.findPath(start, stop, connections, path)
    local selected
    for key, connection in pairs(connections) do
        if connection.p1 == start or connection.p2 == start then
            if selected == nil then 
                selected = connection
            elseif selected.d >= connection.d then
                selected = connection
            end
        end
    end
end

function getV2(A, B)
	return {x = B.x - A.x, z = B.z - A.z}
end

function getV2Magnitude(V)
	return math.sqrt(V.x^2 + V.z^2)
end

function getV2Distance(A, B)
    return getV2Magnitude(getV2(A, B))
end

DynamicBattle:generate('CombatZone')
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
