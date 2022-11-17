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
            if outerkey ~= innerkey then 
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
                        d = GetV2Distance(outerzone.point, innerzone.point)
                    }
                    table.insert(self.connections, connection)
                end
            end
        end
    end

    for outerkey, outerconnection in pairs(self.connections) do 
        for innerkey, innerconnection in pairs(self.connections) do 
            if innerkey > outerkey and CmpConnection(outerconnection, innerconnection) ~= 0 then
                if GetIntersect(outerconnection.p1, outerconnection.p2, innerconnection.p1, innerconnection.p2) then
                    if outerconnection.d >= innerconnection.d then
                        innerconnection = nil
                    else
                        outerconnection = nil
                    end
                end
            end
        end
    end

    local lastvalue, n = #self.connections, #self.connections

    for i = 1, n do
        if self.connections[i - 1] == nil and i > 1 then
            break
        elseif self.connections[i] == nil then
            for u = lastvalue, 1, -1 do
                if u <= i then
                    break
                elseif self.connections[u] ~= nil then
                    self.connections[i] = self.connections[u]
                    self.connections[u] = nil
                    lastvalue = u
                end
            end
        end
    end

    trigger.action.outText("drawing connections", 10, false)
    for key, connection in pairs(self.connections) do
        trigger.action.lineToAll(-1, key, self.zones[connection.p1].point, self.zones[connection.p2].point, {1, 0, 0, 1}, 1, true)
    end
end
debug = false

function FindPath(start, stop, connections, zones)
    local selected, found = start, false
    local path = {}
    table.insert(path, start)
    while !found do
        local best = { con = nil, weight = -1}
        local weight
        for index, connection in ipairs(connections) do
            if connection.p1 == selected then
                weight = connection.d + GetV2Distance(zones[connection.p2].point, zones[stop].point)
                if weight < best.weight or best.weight == -1 and Find(path, connection.p2) == 0 then
                    best.weight = weight
                    best.con = index
                end
            elseif connection.p2 == selected then
                weight = connection.d + GetV2Distance(zones[connection.p1].point, zones[stop].point)
                if weight < best.weight or best.weight == -1 and Find(path, connection.p1) == 0 then
                    best.weight = weight
                    best.con = index
                end
            end
        end
        if best.con == nil then
            return nil
        end
        if best.p1 == selected then
            table.insert(path, connections[best.con].p2)
            selected = connections[best.con].p2
        else
            table.insert(path, connections[best.con].p1)
            selected = connections[best.con].p1
        end
        if connections[best.con].p1 == stop or connections[best.con].p2 == stop then
            found = true
        end
    end
    return path
end

function GetV2(A, B)
	return {x = B.x - A.x, z = B.z - A.z}
end

function GetV2Magnitude(V)
	return math.sqrt(V.x^2 + V.z^2)
end

function GetV2Distance(A, B)
    return GetV2Magnitude(GetV2(A, B))
end

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

function SubtractV2(V1, V2)
    return {x = V1.x - V2.x, z = V1.z - V2.z}
end

function AddV2(V1, V2)
    return {x = V1.x + V2.x, z = V1.z + V2.z}
end

function CmpConnection(C1, C2)
    local commonpoints = 0
    if C1.p1 == C2.p1 or C1.p1 == C2.p2 then
        commonpoints = commonpoints + 1
    end
    if C1.p2 == C2.p1 or C1.p2 == C2.p2 then
        commonpoints = commonpoints + 1
    end
    return commonpoints
end

function Find(table, value)
    for i = 1, #table do
        if table[i] == value then
            return i
        end
    end
    return 0
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


else
    DynamicBattle:generate('CombatZone')
end
