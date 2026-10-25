
local log = require("src/util").log
local boxes = require("src/boxes")

local M = {}

local window = ui.Interfaces:GetComponent(
    id.Component.TOPLEVEL_V2__PLUGIN_BUILD_LAYER_TOP
)

local group = ui.GroupBox.new(window)
group.stylesheetID = id.StyleSheet.DEFAULT
group:SetHeaderLayout(0, 0, 0, 0, 0)
group:SetSize(200, 110)
group:SetPos(0, 0, 0.55, 0.25)

local function makeText(content, x, y, w, h)
    local t = ui.Text.new(group)
    t:SetPos(x, y)
    t:SetSize(w, h)
    t.font = id.Font.MUSEO_SANS_15PT_REGULAR
    t.content = content
    return t
end

local nearbyPlayers = {}
local selectedBomb = nil
local selectedBase = nil
local selectionChanged = false


makeText('Base:', 10, 8, 45, 26)
makeText('Bomb:', 10, 48, 45, 26)

local function makeDropdown(x, y)
    local list = ui.List.new(group)
    list:SetPos(x, y)
    list:SetSize(120, 35)
    list.stylesheetID = id.StyleSheet.DROPDOWN_DEFAULT
    list.dropdownMaxVisibleEntries = 10
    list.maxSelected = 1
    return list
end

local playerListBase = makeDropdown(60, 2)
local playerListBomb = makeDropdown(60, 42)

local playerCountText = makeText(
    'Nearby players: 0', 10, 80, 120, 14
)

local function refreshNearbyPlayers()
    local names = {}
    local seen = {}

    local selfEntity = PlayerList.Self()
    local selfUID = selfEntity and selfEntity.uid

    for _, player in ipairs(PlayerList.All() or {}) do
        if player.isValid and player.uid ~= selfUID then
            local name = player.displayName

            if type(name) == 'string'
                and name ~= ''
                and not seen[name] then

                seen[name] = true
                names[#names + 1] = name
            end
        end
    end

    table.sort(names, function(a, b)
        return a:lower() < b:lower()
    end)

    local changed = #names ~= #nearbyPlayers

    if not changed then
        for i, name in ipairs(names) do
            if nearbyPlayers[i] ~= name then
                changed = true
                break
            end
        end
    end

    if not changed then return end

    nearbyPlayers = names

    -- Populate BOTH dropdowns
    for i, name in ipairs(nearbyPlayers) do
        playerListBase:Add(name, i)
        playerListBomb:Add(name, i)
    end

    -- Reset selections if players have left
    local present = {}
    for _, name in ipairs(nearbyPlayers) do
        present[name] = true
    end

    if selectedBase and not present[selectedBase] then
        selectedBase = nil
        boxes.setBase(nil)
    end

    if selectedBomb and not present[selectedBomb] then
        selectedBomb = nil
        boxes.setBomb(nil)
    end

    playerCountText.content =
        'Nearby players: ' .. #nearbyPlayers
end

-- Base selection
playerListBase:Subscribe(
    ui.Hook.ONSELECTIONCHANGED,
    function(component, entryID, selected)
        if selected == true or selected == 1 then
            local index = tonumber(entryID)

            if index and nearbyPlayers[index] then
                selectedBase = nearbyPlayers[index]
                selectionChanged = true
                log('Selected Base: ' .. selectedBase)
                boxes.setBase(selectedBase)
            end
        end
    end
)

playerListBomb:Subscribe(
    ui.Hook.ONSELECTIONCHANGED,
    function(component, entryID, selected)
        if selected == true or selected == 1 then
            local index = tonumber(entryID)

            if index and nearbyPlayers[index] then
                selectedBomb = nearbyPlayers[index]
                selectionChanged = true
                log('Selected Bomb: ' .. selectedBomb)
                boxes.setBomb(selectedBomb)
            end
        end
    end
)

-- Scan immediately
refreshNearbyPlayers()

-- Refresh each server tick
Event.ServerLogic.Subscribe(
    'RS3ChatFilter_NearbyPlayers',
    refreshNearbyPlayers
)

-- Allow other modules to access selections
function M.GetBase()
    return selectedBase
end

function M.GetBomb()
    return selectedBomb
end
function M.HasSelectionChanged()
    return selectionChanged
end
return M
