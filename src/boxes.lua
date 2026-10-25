local log = require("src/util").log

local selectedBase = nil
local selectedBomb = nil

local M = {}

local TILE = 512 -- world units per tile
local YELLOW = 0xA5A500FF
local ORANGE = 0xFFA500FF
local RED = 0xFF0000FF
local GREEN = 0x00FF00FF

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

local function isUserInsideBox(radius, centerPos, targetLevel)
    local self = Player.GetEntity()

    if not self or not self.isValid or not self.coordGrid then
        return false
    end

    -- Must be on the same floor
    if self.coordGrid.level ~= targetLevel then
        return false
    end

    -- Get our own position
    local selfPos = self.coordGrid:ToCoordFine(true).position

    -- Distance from the selected player's position
    local dx = math.abs(selfPos.x - centerPos.x)
    local dz = math.abs(selfPos.z - centerPos.z)

    -- Convert tile radius to world units
    local radiusWorld = radius * TILE

    return dx <= radiusWorld and dz <= radiusWorld
end


local GRAPHICS = {
    RB = {
        ticks = 12,
        draw  = function(pos)
            local bonusDamage = 5.5 * TILE
            local splash = 2.5 * TILE
            drawSquare(pos, bonusDamage, YELLOW)
            drawSquare(pos, splash, RED)

            if isPlayerInsideBox(splash) then 
                drawSquare(pos, splash, RED- 161, true)
                return
            end
            if isPlayerInsideBox(bonusDamage) then 
                drawSquare(pos, bonusDamage, YELLOW- 161, true)
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
-- Half a tile in world units
local BASE = 1.5
local BOMB = 5.5

local function drawSelectedPlayer(username, colour, size)
    if not username or username == '' then
        return
    end

    for _, player in ipairs(PlayerList.All() or {}) do
        if player.isValid
            and player.displayName == username
            and player.coordGrid then

            local coord = player.coordGrid
            local pos = coord:ToCoordFine(true).position

            pos.y = World.GetGroundHeight(
                coord.level,
                pos.x,
                pos.z
            ) + 50
            drawSquare(pos, size * TILE, colour, false)
            -- Add fill when inside
            if isUserInsideBox(size, pos, coord.level) then
                drawSquare(pos, size * TILE, colour - 161, true)
            end

            return
        end
    end
end

function M.onDraw()
    -- Existing chat-triggered graphics
    if active ~= nil then
        local player = Player.GetEntity()

        if player and player.isValid then
            local coord = player.coordGrid
            local pos = coord:ToCoordFine(true).position

            pos.y = World.GetGroundHeight(
                coord.level,
                pos.x,
                pos.z
            ) + 50

            active.draw(pos)
        end
    end

    -- Draw selected players only after selection
    if selectedBase then
        drawSelectedPlayer(
            selectedBase,
            YELLOW,
            BASE 
        )
    end

    if selectedBomb then
        drawSelectedPlayer(
            selectedBomb,
            RED,
            BOMB
        )
    end
end



function M.drawSelectedPlayers(baseName, bombName)
    drawSelectedPlayer(baseName, YELLOW, BASE)
    drawSelectedPlayer(bombName, RED, BOMB)
end


function M.setBase(username)
    selectedBase = username
end

function M.setBomb(username)
    selectedBomb = username
end
return M