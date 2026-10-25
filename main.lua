local function log(...)
    local parts = {}
    for i = 1, select("#", ... ) do
        parts[i] = tostring(select(i, ...))
    end
    print("[RaguElp] " .. table.concat(parts))
end

log('RaguElp starting...')

-- SETTINGS
local RULES = {
    { match = "has sent a bomb after you", show = "Bomb on you", graphic = "RB" }
}

local IGNORE_PLAYER_CHAT = true

local SHOW_BANNER = true
local ADD_CHAT_LINE = false
local BANNER_TICKS = 8
local PROBE_MODE = false


-- HELPER FUNCS
local function stripTags(text)
    return (string.gsub(text or "", "<[^>]*>", ""))
end

local function findRule(text)
    local lower = string.lower(text)
    for _, rule in ipairs(RULES) do
        if string.find(lower, string.lower(rule.match), 1, true) then
            return rule
        end
    end
    return nil
end


-- BANNER
local banner = nil
local bannerTicksLeft = 0

local function showBanner(text)
    if banner == nil then
        local layer = ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__PLUGIN_BUILD_LAYER_TOP)
        banner = ui.Text.new(layer)
        -- Full screen width, 40 tall, a fifth of the way down. The text is
        -- centred inside it, so the banner is centred without using
        -- SetPos's self-offset arguments (they pushed it right, not left).
        banner:SetSize(0, 40, 1.0, 0.0)
        banner:SetPos(0, 0, 0.0, 0.2)
        banner.clickthrough = true  -- don't block clicks on the game underneath
        banner.font = id.Font.MUSEO_SANS_24PT_REGULAR
        banner.colour = Vector4.new(1.0, 0.85, 0.2, 1.0)
        banner.isShadowed = true
        banner:AlignTo(ui.AlignMode.CENTRE)
    end

    banner.content = text
    banner.hidden = false
    banner:MoveToFront()
    bannerTicksLeft = BANNER_TICKS

    -- DEBUG: remove once the banner shows
    log("banner debug: hidden=", banner.hidden, "visibleGlobal=", banner.visibleGlobal,
        "width=", banner.width, "height=", banner.height, "x=", banner.x, "y=", banner.y,
        "layerWidth=", banner.parent.width, "layerHeight=", banner.parent.height)
end
-- BOX
local frames = 0

local function drawBox()
    frames = frames + 1
    if frames >= 180 then
        Event.Draw.Unsubscribe("playerBox")
        return
    end
    local player = Player.GetEntity()
    if not player or not player.isValid then return end

    local coord = player.coordGrid
    local pos = coord:ToCoordFine(true).position

    pos.y = World.GetGroundHeight(
        coord.level, pos.x, pos.z
    ) + 50

    local half = 2.5 * 512

    ShapeList.Draw({
        shapePositions = {
            Vector3.new(-half, 0, -half),
            Vector3.new( half, 0, -half),
            Vector3.new( half, 0,  half),
            Vector3.new(-half, 0,  half)
        },
        shapeLines = {
            0, 1,
            1, 2,
            2, 3,
            3, 0
        },
        translation = pos,
        colour = 0x00FF00FF,
        lineWidth = 4,
        ignoreDepth = true
    })
end

local function onServerTick()
    if bannerTicksLeft > 0 then
        bannerTicksLeft = bannerTicksLeft - 1
        if bannerTicksLeft == 0 and banner ~= nil then
            banner.hidden = true
        end
    end
end

-- CHAT REACT
local function publish(message)
    log("Chat trigger:", message)
    if SHOW_BANNER then
        showBanner(message)
    end
    if ADD_CHAT_LINE then
        Chat.AddMessage(message)
    end
end
local function publishGraphic(graphic)
    if graphic == "RB" then
        drawBox()
    end
end
local function onChatMessage(event)
    local text = stripTags(event.chatMessage)

    if PROBE_MODE then
        log(string.format("[probe] type=%s sender=%q text=%q", tostring(event.chatType), event.senderNameSimple or "", text))
    end

    if event.chatType == ChatType.PLUGIN then
        return
    end

    if IGNORE_PLAYER_CHAT and (event.senderNameSimple or "") ~= "" then
        return
    end

    local rule = findRule(text)

    if rule ~= nil then
        publish(rule.show)
        publishGraphic(rule.graphic)
    end
end

-- WIRING
if not Plugin.HasPermission(PluginPermissions.chatAccess) then
    log("Chat Triggers: chatAccess hasn't been granted, so no chat messages will arrive.")
end

Event.ChatMessage.Subscribe("chatTriggers", onChatMessage)
Event.ServerLogic.Subscribe("chatTriggersBannerTick", onServerTick)
Event.Draw.Subscribe("playerBox", drawBox)

-- DEBUG: show a test banner as soon as the plugin loads. Remove once it works.
showBanner("Chat Triggers loaded")

function PluginShutdown()
    if banner ~= nil then
        banner:Destroy()
        banner = nil
    end
end