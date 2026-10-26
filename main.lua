local log     = require("src/util").log
local matcher = require("src/matcher")
local debuffs = require("src/debuffs")
local banner  = require("src/banner")
local boxes   = require("src/boxes")
local markers = require("src/markers")
local picker  = require("src/picker")

log('RaguElp starting...')

-- Every module gets these calls, if it has a function with that name:
--  onMatch(rule, text) a rule fired
--  onTick()            every server tick (0.6s)
--  onDraw()            every frame
--  shutdown()          the plugin is unloading
local modules = { banner, boxes, markers, picker }

local function callAll(name, ...)
    for _, mod in ipairs(modules) do
        local handler = mod[name]
        if handler then handler(...) end
    end
end

if not Plugin.HasPermission(PluginPermissions.chatAccess) then
    log("RaguElp: RaguElp hasn't been granted, so no chat messages will arrive.")
end

Event.ChatMessage.Subscribe("raguElpChat", function(event)
    local rule, text = matcher.match(event)
    if not rule then return end
    log("Chat trigger: ", rule.show)
    callAll("onMatch", rule, text)
end)

Event.ServerLogic.Subscribe("raguElpTick", function()
    for _, rule in ipairs(debuffs.check()) do
        log("Debuff trigger: ", rule.show)
        callAll("onMatch", rule)
    end
    callAll("onTick")
end)

Event.Draw.Subscribe("raguElpDraw", function()
    callAll("onDraw")
end)

function PluginShutdown()
    callAll("shutdown")
end