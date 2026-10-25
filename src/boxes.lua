local log = require("src/util").log

local M = {}

local TILE = 512 -- world units per tile
local YELLOW = 0xA5A500FF
local ORANGE = 0xFFA500FF
local RED = 0xFF0000FF

-- A square around position
local function drawSquare(pos, half, colour, filled)
    local shape = {
        shapePositions = {
            Vector3.new(-half, 0, -half),
            Vector3.new( half, 0, -half),
            Vector3.new( half, 0,  half),
            Vector3.new(-half, 0,  half)
        },
        translation = pos,
        colour      = colour,
        lineWidth   = 2,
        ignoreDepth = true
    }
    if filled then
        shape.shapeTris = { 0, 1, 2,  0, 2, 3 }
    else
        shape.shapeLines = { 0, 1,  1, 2,  2, 3,  3, 0 }
    end
    ShapeList.Draw(shape)
end

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

local GRAPHICS = {
    RB = {
        ticks = 12,
        draw  = function(pos)
            local xl = 4.5 * TILE
            local large = 2.5 * TILE
            local small = 1.5 * TILE
            drawSquare(pos, xl, YELLOW)
            drawSquare(pos, large, ORANGE)
            drawSquare(pos, small, RED)

            if isPlayerInsideBox(small) then 
                drawSquare(pos, small, RED - 161, true)
                return
            end 
            if isPlayerInsideBox(large) then 
                drawSquare(pos, large, ORANGE- 161, true)
                return
            end
            if isPlayerInsideBox(xl) then 
                drawSquare(pos, xl, YELLOW- 161, true)
                return
            end
        end
    },
}

local active = nil -- GAPHICS drawn? nil for nothing
local ticksLeft = 0

function M.onMatch(rule, text)
    if rule.graphic == nil then
        return
    end
    local graphic = GRAPHICS[rule.graphic]
    if graphic == nil then
        log("boxes: no graphic called ", rule.graphic)
        return
    end
    active = graphic
    ticksLeft = graphic.ticks
end

function M.onTick()
    if ticksLeft > 0 then
        ticksLeft = ticksLeft - 1
        if ticksLeft == 0 then
            active = nil
        end
    end
end

function M.onDraw()
    if active == nil then
        return
    end

    local player = Player.GetEntity()
    if not player or not player.isValid then return end

    local coord = player.coordGrid
    local pos = coord:ToCoordFine(true).position
    pos.y = World.GetGroundHeight(coord.level, pos.x, pos.z) + 50

    active.draw(pos)
end

return M