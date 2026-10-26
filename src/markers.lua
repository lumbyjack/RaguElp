local draw    = require("src/draw")
local players = require("src/players")
local picker  = require("src/picker")

local M = {}

-- How far each marker reaches from the player it's around, in tiles.
local BASE_TILES = 1.5
local BOMB_TILES = 5.5

-- A square around the player called `name`, filled in while you're inside it.
local function drawMarker(name, colour, tiles)
    local player = players.find(name)
    local pos    = players.groundPoint(player)
    if not pos then return end

    draw.square(pos, tiles, colour)
    if players.isNear(players.me(), player, tiles) then
        draw.square(pos, tiles, draw.translucent(colour), true)
    end
end

function M.onDraw()
    drawMarker(picker.base(), draw.YELLOW, BASE_TILES)
    drawMarker(picker.bomb(), draw.RED, BOMB_TILES)
end

return M