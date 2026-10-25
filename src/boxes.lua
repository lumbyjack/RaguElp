local M = {}

local frames = 0

local function isPlayerInsideBox(rad)
    local self = Player.GetEntity()
    if not self then return false end

    local center = self.coordGrid:ToCoordFine(true).position

    for _, player in ipairs(PlayerList.All()) do
        if player.isValid and player.uid ~= self.uid then
            local pos = player.coordGrid:ToCoordFine(true).position

            local dx = math.abs(pos.x - center.x)
            local dz = math.abs(pos.z - center.z)

            if player.coordGrid.level == self.coordGrid.level
                and dx <= rad 
                and dz <= rad  then
                return true
            end
        end
    end
    return false
end

function M.onMatch(rule, text)
    if rule.graphic == "RB" then
        frames = 0
    end
end

function M.onDraw()
    frames = frames + 1
    if frames >= 1200 then
        return
    end

    local player = Player.GetEntity()
    if not player or not player.isValid then return end

    local coord = player.coordGrid
    local pos = coord:ToCoordFine(true).position

    pos.y = World.GetGroundHeight(
        coord.level, pos.x, pos.z
    ) + 50

    local large = 2.5 * 512
    local small = 1.5 * 512
    ShapeList.Draw({
        shapePositions = {
            Vector3.new(-large, 0, -large),
            Vector3.new( large, 0, -large),
            Vector3.new( large, 0,  large),
            Vector3.new(-large, 0,  large)
        },
        shapeLines = {
            0, 1,
            1, 2,
            2, 3,
            3, 0
        },
        translation = pos,
        colour = 0xFFA500FF,
        lineWidth = 2,
        ignoreDepth = true
    })
    if isPlayerInsideBox(large) then
            ShapeList.Draw({
        shapePositions = {
            Vector3.new(-large, 0, -large),
            Vector3.new( large, 0, -large),
            Vector3.new( large, 0,  large),
            Vector3.new(-large, 0,  large)
        },
        shapeTris = {
            0, 1, 2,
            1, 2, 3,
            2, 3, 0
        },
        translation = pos,
        colour = 0xFFA50080,
        lineWidth = 2,
        ignoreDepth = true
    })
    end
    if isPlayerInsideBox(small) then
            ShapeList.Draw({
        shapePositions = {
            Vector3.new(-small, 0, -small),
            Vector3.new( small, 0, -small),
            Vector3.new( small, 0,  small),
            Vector3.new(-small, 0,  small)
        },
        shapeTris = {
            0, 1, 2,
            1, 2, 3,
            2, 3, 0
        },
        translation = pos,
        colour = 0xFF000080,
        lineWidth = 2,
        ignoreDepth = true
    })
    end
    ShapeList.Draw({
        shapePositions = {
            Vector3.new(-small, 0, -small),
            Vector3.new( small, 0, -small),
            Vector3.new( small, 0,  small),
            Vector3.new(-small, 0,  small)
        },
        shapeLines = {
            0, 1,
            1, 2,
            2, 3,
            3, 0
        },
        translation = pos,
        colour = 0xFF0000FF,
        lineWidth = 2,
        ignoreDepth = true
    })
end

return M