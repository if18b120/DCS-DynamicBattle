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
end

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