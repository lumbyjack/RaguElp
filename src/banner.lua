local log = require("src/util").log

local BANNER_TICKS = 8

local M               = {}
local banner          = nil
local bannerTicksLeft = 0

function M.show(text)
    if banner == nil then
        local layer = ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__PLUGIN_BUILD_LAYER_TOP)
        banner = ui.Text.new(layer)
        banner:SetSize(0, 40, 1.0, 0.0)
        banner:SetPos(0, 0, 0.0, 0.2)
        banner.clickthrough = true
        banner.font = id.Font.MUSEO_SANS_24PT_REGULAR
        banner.colour = Vector4.new(1.0, 0.85, 0.2, 1.0)
        banner.isShadowed = true
        banner:AlignTo(ui.AlignMode.CENTRE)
    end

    banner.content = text
    banner.hidden = false
    banner:MoveToFront()
    bannerTicksLeft = BANNER_TICKS
end

function M.onMatch(rule, text)
    M.show(rule.show)
end

function M.onTick()
    if bannerTicksLeft > 0 then
        bannerTicksLeft = bannerTicksLeft - 1
        if bannerTicksLeft == 0 and banner ~= nil then
            banner.hidden = true
        end
    end
end

function M.shutdown()
    if banner ~= nil then
        banner:Destroy()
        banner = nil
    end
end

return M