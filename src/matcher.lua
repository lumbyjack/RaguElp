local log   = require("src/util").log
local RULES = require("src/rules")

local IGNORE_PLAYER_CHAT = true
local PROBE_MODE         = true

local M = {}

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

-- Return matching rule with santisied text, or nil.
function M.match(event)
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

    if rule == nil then
        return nil
    end
    return rule, text
end

return M