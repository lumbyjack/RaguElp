local M = {}

local frames = 0

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
        lineWidth = 4,
        ignoreDepth = true
    })
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
        lineWidth = 4,
        ignoreDepth = true
    })
end

return M