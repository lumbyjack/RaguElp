local log     = require("src/util").log
local players = require("src/players")

local M = {}

-- Panel's parts, made by build() at the end of this file.
local panel, baseList, bombList, countText

local nearby = {}   -- the names in the dropdowns, in the same order
local selected = {} -- selected.base and selected.bomb: the picked names

local function makeText(content, x, y, width, height)
    local text = ui.Text.new(panel)
    text:SetPos(x, y)
    text:SetSize(width, height)
    text.font = id.Font.MUSEO_SANS_15PT_REGULAR
    text.content = content
    return text
end

local function makeDropdown(x, y)
    local list = ui.List.new(panel)
    list:SetPos(x, y)
    list:SetSize(120, 35)
    list.stylesheetID = id.StyleSheet.DROPDOWN_DEFAULT
    list.dropdownMaxVisibleEntries = 10
    list.maxSelected = 1
    return list
end

-- When a name is picked from `list`, remember it as selected[role].
local function watchDropdown(list, role)
    list:Subscribe(ui.Hook.ONSELECTIONCHANGED, function(_, entryID, isSelected)
        if isSelected ~= true and isSelected ~= 1 then return end
        local name = nearby[tonumber(entryID)]
        if not name then return end
        selected[role] = name
        log("Selected ", role, ": ", name)
    end)
end

local function build()
    local window = ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__PLUGIN_BUILD_LAYER_TOP)
    panel = ui.GroupBox.new(window)
    panel.stylesheetID = id.StyleSheet.DEFAULT
    panel:SetHeaderLayout(0, 0, 0, 0, 0)
    panel:SetSize(200, 110)
    panel:SetPos(0, 0, 0.55, 0.25)

    makeText("Base:", 10,  8, 45, 26)
    makeText("Bomb:", 10, 48, 45, 26)
    baseList = makeDropdown(60,  2)
    bombList = makeDropdown(60, 42)
    countText = makeText("Nearby players: 0", 10, 80, 120, 14)

    watchDropdown(baseList, "base")
    watchDropdown(bombList, "bomb")
end

-- True if two lists hold the same names in the same order.
local function sameNames(a, b)
    if #a ~= #b then return false end
    for i = 1, #a do
        if a[i] ~= b[i] then return false end
    end
    return true
end

-- Empties `list`, then adds `names`. Each entry's ID is its position in `names`.
local function fill(list, names)
    list:Clear()
    for i, name in ipairs(names) do
        list:Add(name, i)
    end
end

-- Forgets a pick if that player has left
local function forgetLeavers(names)
    local present = {}
    for _, name in ipairs(names) do
        present[name] = true
    end
    for role, name in pairs(selected) do
        if not present[name] then
            selected[role] = nil
        end
    end
end

function M.onTick()
    local names = players.nearbyNames()
    if sameNames(names, nearby) then return end

    nearby = names
    fill(baseList, names)
    fill(bombList, names)
    countText.content = "Nearby players: " .. #names
    forgetLeavers(names)
end

function M.base() return selected.base end
function M.bomb() return selected.bomb end

function M.shutdown()
    if not panel then return end
    panel:Destroy()
    panel = nil
end

build()

return M