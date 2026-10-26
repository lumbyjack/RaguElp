local log     = require("src/util").log
local draw    = require("src/draw")
local players = require("src/players")

local M = {}

-- The two red bomb (RB) ranges marked around you, in tiles
local SPLASH_TILES = 2.5
local BONUS_TILES  = 5.5

-- Graphics a rule can ask for with graphic = "<name>"
--   ticks  = how long it stays up, in server ticks (0.6s each)
--   render = called every frame while it's up, with the ground point under you
local GRAPHICS = {
    RB = {
        ticks = 12,
        render = function(pos, me)
            draw.square(pos, BONUS_TILES, draw.YELLOW)
            draw.square(pos, SPLASH_TILES, draw.RED)
            if players.anyoneNear(me, SPLASH_TILES) then
                draw.square(pos, SPLASH_TILES, draw.translucent(draw.RED), true)
            elseif players.anyoneNear(me, BONUS_TILES) then
                draw.square(pos, BONUS_TILES, draw.translucent(draw.YELLOW), true)
            end
        end
    }
}

local active    = nil -- the GRAPHICS entry being shown, or nil for none
local ticksLeft = 0

function M.onMatch(rule)
    if not rule.graphic then return end
    local graphic = GRAPHICS[rule.graphic]
    if not graphic then
        log("boxes: no graphic called ", rule.graphic)
        return
    end
    active = graphic
    ticksLeft = graphic.ticks
end

function M.onTick()
    if ticksLeft == 0 then return end
    ticksLeft = ticksLeft - 1
    if ticksLeft == 0 then
        active = nil
    end
end

function M.onDraw()
    if not active then return end
    local me = players.me()
    local pos = players.groundPoint(me)
    if not pos then return end
    active.render(pos, me)
end

return M