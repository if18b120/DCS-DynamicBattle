DynamicBattle = {
    zones = {},
    -- zonename = 'CombatZone'
    connections = {}
}
debug = true
--[[

connection = {
    p1 = zonesindex
    p2 = zonesindex
    d = distance
}

]]--

function DynamicBattle:generate(zonename)
    local zonenum = 1
    -- trigger.action.outText("creating zones", 10, false)
    DebugPrint("creating zones")
--[[
    while trigger.misc.getZone(zonename .. zonenum) ~= nil do
        table.insert(self.zones, trigger.misc.getZone(zonename .. zonenum))
        zonenum = zonenum + 1
    end
]]--
    self.zones = {
        {point = {x = -247702.09375, y = 0, z = 624390.625}, radius = 500.7864074707},
        {point = {x = -245661.65625, y = 0, z = 623802.875}, radius = 1000.6583862305},
        {point = {x = -243927.359375, y = 0, z = 620314.5}, radius = 1300.5815429688},
        {point = {x = -241765.125, y = 0, z = 617048.375}, radius = 2300.3256835938},
        {point = {x = -248186.53125, y = 0, z = 615831.375}, radius = 900.68402099609},
        {point = {x = -248769.21875, y = 0, z = 609760.6875}, radius = 1400.5560302734},
        {point = {x = -251630.359375, y = 0, z = 610257.875}, radius = 900.68402099609},
        {point = {x = -254114, y = 0, z = 611357.5625}, radius = 600.76080322266},
        {point = {x = -255117.203125, y = 0, z = 607210.1875}, radius = 1000.6583862305},
        {point = {x = -252987.703125, y = 0, z = 606292.25}, radius = 800.70959472656},
        {point = {x = -250523.890625, y = 0, z = 606794.5}, radius = 1500.5303955078},
        {point = {x = -241161.953125, y = 0, z = 609933.4375}, radius = 1300.5815429688}
    }
    -- trigger.action.outText(zonenum .. " zones found", 10, false)
    DebugPrint(#self.zones .. " zones found")
    DebugPrint("creating connections")
    -- trigger.action.outText("creating connections", 10, false)
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
    local lastvalue, n = #self.connections, #self.connections
    DebugPrint(#self.connections .. " connections created")
    -- trigger.action.outText(#self.connections .. " connections created", 10, false)
    local delcount = 0
    for outerkey, outerconnection in pairs(self.connections) do
        for innerkey, innerconnection in pairs(self.connections) do
            if innerkey > outerkey and self.connections[innerkey] ~= nil and self.connections[outerkey] ~= nil and CmpConnection(outerconnection, innerconnection) == 0 then
                -- trigger.action.outText("valid to intersect compare", 10, false)
                if GetIntersect(self.zones[outerconnection.p1].point, self.zones[outerconnection.p2].point, self.zones[innerconnection.p1].point, self.zones[innerconnection.p2].point) then
                    -- trigger.action.outText(type(self.connections[outerkey]) .. type(outerconnection), 10, false)
                    -- trigger.action.outText(type(self.connections[innerkey]) .. type(innerconnection), 10, false)
                    -- trigger.action.outText("intersect detected", 10, false)
                    if outerconnection.d >= innerconnection.d then
                        self.connections[outerkey] = nil
                        -- trigger.action.outText(outerkey .. " deleted", 10, false)
                    else
                        self.connections[innerkey] = nil
                        -- trigger.action.outText(innerkey .. " deleted", 10, false)
                    end
                    delcount = delcount + 1
                end
            end
        end
    end
    -- trigger.action.outText(delcount .. " deleted", 10, false)
    DebugPrint(delcount .. " deleted")
    for i = 1, n do
        if self.connections[i] == nil then
            for u = lastvalue, 1, -1 do
                if u <= i then
                    break
                elseif self.connections[u] ~= nil then
                    -- trigger.action.outText("patching " .. u .. " to " .. i, 10, false)
                    self.connections[i] = self.connections[u]
                    self.connections[u] = nil
                    lastvalue = u
                    break
                end
            end
        end
    end
    lastvalue = n
    delcount = 0
    for index, connection in pairs(self.connections) do
        if self.connections[index] ~= nil then
            local path, distance = FindPath(connection.p1, connection.p2, self.connections, self.zones, false)
            -- trigger.action.outText(type(path), 10, false)
            DebugPrint(distance)
            DebugPrint(connection.d)
            DebugPrint(" ")
            if distance ~= nil and distance < connection.d * 1.5 then
                delcount = delcount + 1
                self.connections[index] = nil
            end
        end
    end
    -- trigger.action.outText(delcount .. " deleted", 10, false)
    DebugPrint(delcount .. " deleted")
    for i = 1, n do
        if self.connections[i] == nil then
            for u = lastvalue, 1, -1 do
                if u <= i then
                    break
                elseif self.connections[u] ~= nil then
                    -- trigger.action.outText("patching " .. u .. " to " .. i, 10, false)
                    self.connections[i] = self.connections[u]
                    self.connections[u] = nil
                    lastvalue = u
                    break
                end
            end
        end
    end
    -- trigger.action.outText(#self.connections .. " connections left", 10, false)
    DebugPrint(#self.connections .. " connections left")
    local drawid = 1
    -- trigger.action.outText("drawing", 10, false)
    -- for key, zone in pairs(self.zones) do
    --     drawid = drawid + key
    --     trigger.action.circleToAll(-1, drawid, zone.point, zone.radius, {1, 0, 0, 1}, {1, 0, 0, 0.2}, 1, true)
    -- end
    -- for key, connection in pairs(self.connections) do
    --     drawid = drawid + key
    --     trigger.action.lineToAll(-1, drawid, self.zones[connection.p1].point, self.zones[connection.p2].point, {1, 0, 0, 1}, 1, true)
    -- end
end

function FindPath(start, stop, connections, zones, directallowed)
    -- DebugPrint("start: " .. start .. ", stop: " .. stop)
    local selected, found = start, false
    local path = {}
    table.insert(path, start)
    local distance = 0
    while not found do
        local best = { con = nil, weight = -1, d = 0}
        local weight
        -- DebugPrint(#connections)
        for index, connection in pairs(connections) do
            -- DebugPrint("checking con " .. index)
            if directallowed or not ((connection.p1 == start and connection.p2 == stop) or (connection.p2 == start and connection.p1 == stop)) then
                if connection.p1 == selected then
                    -- DebugPrint("con valid")
                    weight = connection.d + GetV2Distance(zones[connection.p2].point, zones[stop].point)
                    if (weight < best.weight or best.weight == -1) and Find(path, connection.p2) == 0 then
                        best.weight = weight
                        best.con = index
                        best.d = connection.d
                    end
                elseif connection.p2 == selected then
                    -- DebugPrint("con valid")
                    weight = connection.d + GetV2Distance(zones[connection.p1].point, zones[stop].point)
                    if (weight < best.weight or best.weight == -1) and Find(path, connection.p1) == 0 then
                        best.weight = weight
                        best.con = index
                        best.d = connection.d
                    end
                end
            end
        end
        if best.con == nil then
            return nil
        end
        -- DebugPrint(selected)
        if connections[best.con].p1 == selected then
            table.insert(path, connections[best.con].p2)
            selected = connections[best.con].p2
        else
            table.insert(path, connections[best.con].p1)
            selected = connections[best.con].p1
        end
        distance = distance + best.d
        if connections[best.con].p1 == stop or connections[best.con].p2 == stop then
            found = true
        end
        -- local printpath = ""
        -- for i = 1, #path do
        --     printpath = printpath .. " " .. path[i]
        -- end
        -- DebugPrint(printpath .. " | " .. distance)
        -- DebugPrint("best con: " .. connections[best.con].p1 .. " " .. connections[best.con].p2)
        -- DebugPrint(printpath)
        -- DebugPrint(Find(path, 4))
        -- io.read()
    end
    -- local printpath = ""
    -- for i = 1, #path do
    --     printpath = printpath .. " " .. path[i]
    -- end
    -- DebugPrint(printpath .. " | " .. distance)
    return path, distance
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

function DebugPrint(message)
    if debug then
        if trigger ~= nil then
            trigger.action.outText(message, 10, false)
        else
            print(message)
        end
    else
    end
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
DynamicBattle:generate('CombatZone')

--[[

2022-11-18 10:30:20.067 INFO    SCRIPTING (Main): -247702.09375 0 624390.625 | 500.7864074707
2022-11-18 10:30:20.067 INFO    SCRIPTING (Main): -245661.65625 0 623802.875 | 1000.6583862305
2022-11-18 10:30:20.067 INFO    SCRIPTING (Main): -243927.359375 0 620314.5 | 1300.5815429688
2022-11-18 10:30:20.067 INFO    SCRIPTING (Main): -241765.125 0 617048.375 | 2300.3256835938
2022-11-18 10:30:20.067 INFO    SCRIPTING (Main): -248186.53125 0 615831.375 | 900.68402099609
2022-11-18 10:30:20.067 INFO    SCRIPTING (Main): -248769.21875 0 609760.6875 | 1400.5560302734
2022-11-18 10:30:20.067 INFO    SCRIPTING (Main): -251630.359375 0 610257.875 | 900.68402099609
2022-11-18 10:30:20.067 INFO    SCRIPTING (Main): -254114 0 611357.5625 | 600.76080322266
2022-11-18 10:30:20.068 INFO    SCRIPTING (Main): -255117.203125 0 607210.1875 | 1000.6583862305
2022-11-18 10:30:20.068 INFO    SCRIPTING (Main): -252987.703125 0 606292.25 | 800.70959472656
2022-11-18 10:30:20.068 INFO    SCRIPTING (Main): -250523.890625 0 606794.5 | 1500.5303955078
2022-11-18 10:30:20.068 INFO    SCRIPTING (Main): -241161.953125 0 609933.4375 | 1300.5815429688

]]--