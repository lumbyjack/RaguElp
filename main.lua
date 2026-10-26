local log     = require("src/util").log
local matcher = require("src/matcher")
local banner  = require("src/banner")
local boxes   = require("src/boxes")
local markers = require("src/markers")
local picker  = require("src/picker")

log('RaguElp starting...')

local outputs = { banner, boxes, markers, picker }

local function callAll(name, ...)
    for _, out in ipairs(outputs) do
        if out[name] then
            out[name](...)
        end
    end
end

if not Plugin.HasPermission(PluginPermissions.chatAccess) then
    log("RaguElp: RaguElp hasn't been granted, so no chat messages will arrive.")
end


Event.ChatMessage.Subscribe("raguElpChat", function(event)
    local rule, text = matcher.match(event)
    if rule == nil then return end
    log("Chat trigger: ", rule.show)
    callAll("onMatch", rule, text)
end)

Event.ServerLogic.Subscribe("raguElpTick", function(event)
    callAll("onTick")
end)

Event.Draw.Subscribe("raguElpDraw", function()
    callAll("onDraw")
end)

function PluginShutdown()
    callAll("shutdown")
end