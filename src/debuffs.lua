local RULES = require("src/rules")

local M = {}

local MAX_DEPTH = 4   -- how far down inside the debuff bar to look
local onBar = {}      -- the sprite IDs that were on the bar last tick

-- Adds the sprite ID of `component`, and of everything inside it, to `found`.
local function collectSprites(component, depth, found)
    if depth > MAX_DEPTH then return end

    local ok, sprite = pcall(function() return component.spriteID end)
    if ok and sprite then
        found[sprite] = true
    end

    local function visit(child)
        collectSprites(child, depth + 1, found)
    end
    pcall(function() component:IterateDynamicComponents(visit) end)
    pcall(function() component:IterateStaticComponents(visit) end)
end

-- Every sprite ID on the debuff bar right now, as a set: found[id] = true.
local function spritesOnBar()
    local found = {}
    local ok, bar = pcall(function()
        return ui.Interfaces:GetComponent(id.Component.DEBUFF_BAR__BUFF_RENDER_LAYER)
    end)
    if ok and bar then
        collectSprites(bar, 0, found)
    end
    return found
end

-- Call once per server tick. Returns the debuff rules whose icon has
-- just appeared (not ones that were already showing last tick).
function M.check()
    local now = spritesOnBar()
    local appeared = {}
    for _, rule in ipairs(RULES) do
        if rule.debuff and now[rule.debuff] and not onBar[rule.debuff] then
            table.insert(appeared, rule)
        end
    end
    onBar = now
    return appeared
end

return M