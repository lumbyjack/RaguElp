local log   = require("src/util").log
local RULES = require("src/rules")

local IGNORE_PLAYER_CHAT = true   -- skip anything a player typed
local PROBE_MODE         = false   -- true = log every message (for detecting new rules)

local M = {}

-- Remove the game's formatting tags
local function stripTags(text)
    return (string.gsub(text or "", "<[^>]*>", ""))
end

-- The first rule who's `match` words appear in `text`, or nil.
local function findRule(text)
    local lower = string.lower(text)
    for _, rule in ipairs(RULES) do
        if rule.match and string.find(lower, string.lower(rule.match), 1, true) then
            return rule
        end
    end
    return nil
end

-- The rule a chat message trigger, plus the message
-- as plain text. nil if it triggers nothing.
function M.match(event)
    local text = stripTags(event.chatMessage)

    if PROBE_MODE then
        log(string.format("[probe] type=%s sender=%q text=%q", 
            tostring(event.chatType), event.senderNameSimple or "", text))
    end

    if event.chatType == ChatType.PLUGIN then return end

    local fromPlayer = (event.senderNameSimple or "") ~= ""
    if IGNORE_PLAYER_CHAT and fromPlayer then return nil end

    local rule = findRule(text)
    if not rule then return nil end
    return rule, text
end

return M