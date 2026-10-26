local BANNER_TICKS = 8 -- how long the banner stays up in server ticks

local M = {}

local label     = nil -- the on-screen text, created first time it's needed
local ticksLeft = 0

local function makeLabel()
    local layer = ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__PLUGIN_BUILD_LAYER_TOP)
    local text  = ui.Text.new(layer)
    text:SetSize(0, 40, 1.0, 0.0)
    text:SetPos(0, 0, 0.0, 0.2)
    text.clickthrough = true
    text.font = id.Font.MUSEO_SANS_24PT_REGULAR
    text.colour = Vector4.new(1.0, 0.85, 0.2, 1.0)
    text.isShadowed = true
    text:AlignTo(ui.AlignMode.CENTRE)
    return text
end

function M.show(message)
    label = label or makeLabel()
    label.content = message
    label.hidden = false
    label:MoveToFront()
    ticksLeft = BANNER_TICKS
end

function M.onMatch(rule)
    M.show(rule.show)
end

function M.onTick()
    if ticksLeft == 0 then return end
    ticksLeft = ticksLeft - 1
    if ticksLeft == 0 then
        label.hidden = true
    end
end

function M.shutdown()
    if not label then return end
    label:Destroy()
    label = nil
end

return M