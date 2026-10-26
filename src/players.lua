local TILE = require("src/util").TILE

local M = {}

local LIFT = 50     -- raise ground points this much, avoid shapes being hidden in floor

-- You, or nil if your avatar is not loaded in yet.
function M.me()
    local me = Player.GetEntity()
    if me and me.isValid then
        return me
    end
    return nil
end

-- Every valid player around you, not including you.
function M.others()
    local me = M.me()
    local myUID = me and me.uid
    local others = {}
    for _, player in ipairs(PlayerList.All() or {}) do
        if player.isValid and player.uid ~= myUID then
            table.insert(others, player)
        end
    end
    return others
end

-- The player called `name`, or nil if they aren't around.
function M.find(name)
    if not name then return nil end
    for _, player in ipairs(M.others()) do
        if player.displayName == name then
            return player
        end
    end
    return nil
end

-- The names of everyone around you - A to Z, once each.
function M.nearbyNames()
    local names, seen = {}, {}
    for _, player in ipairs(M.others()) do
        local name = player.displayName
        if type(name) == "string" and name ~= "" and not seen[name] then
            seen[name] = true
            table.insert(names, name)
        end
    end
    table.sort(names, function(a, b) return a:lower() < b:lower() end)
    return names
end

-- The point on the ground under `player`, raised slightly. nil if they aren't valid.
function M.groundPoint(player)
    if not player or not player.isValid then return nil end
    local coord = player.coordGrid
    local pos   = coord:ToCoordFine(true).position
    pos.y = World.GetGroundHeight(coord.level, pos.x, pos.z) + LIFT
    return pos
end

-- True if a and b are on the same floor and within 
-- `tiles` of one another along both x and z
function M.isNear(a, b, tiles)
    if not a or not b then return false end
    if a.coordGrid.level ~= b.coordGrid.level then return false end
    local posA = a.coordGrid:ToCoordFine(true).position
    local posB = b.coordGrid:ToCoordFine(true).position
    local reach = tiles * TILE
    return math.abs(posA.x - posB.x) <= reach
       and math.abs(posA.z - posB.z) <= reach
end

-- True if any other player is within `tiles` of `player`.
function M.anyoneNear(player, tiles)
    for _, other in ipairs(M.other()) do
        if M.isNear(player, other, tiles) then
            return true
        end
    end
    return false
end

return M