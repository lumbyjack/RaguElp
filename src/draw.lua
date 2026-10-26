local TILE = require("src/util").TILE

local M = {}

-- Colours are 0xRRGGBBAA: red, green, blue then opacity (AA).
M.YELLOW = 0xA5A500FF
M.RED    = 0xFF0000FF

local SEE_THROUGH = 0x5E    -- opacity for filled squares: 0x00 invisible, 0xFF solid
local LINE_WIDTH  = 2

-- The same colour, but see-through: keeps RRGGBB, swaps AA for SEE_THROUGH.
function M.translucent(colour)
    return (colour & 0xFFFFFF00) | SEE_THROUGH
end

-- A square centered on `pos`, reaching `tiles` out in each direction.
-- An outline, or filled in if `filled` is true.
function M.square(pos, tiles, colour, filled)
    local half = tiles * TILE
    local shape = {
        shapePositions = {
            Vector3.new(-half, 0, -half),
            Vector3.new( half, 0, -half),
            Vector3.new( half, 0,  half),
            Vector3.new(-half, 0,  half)
        },
        translation = pos,
        colour      = colour,
        lineWidth   = LINE_WIDTH,
        ignoreDepth = true
    }
    if filled then
        shape.shapeTris = { 0, 1, 2,  0, 2, 3 }
    else
        shape.shapeLines = { 0, 1,  1, 2,  2, 3,  3, 0 }
    end
    ShapeList.Draw(shape)
end

return M