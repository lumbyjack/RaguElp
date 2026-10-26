local M = {}

-- The game measures positions in world units. One tile is 512 of them
M.TILE = 512

function M.log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    print("[RaguElp] " .. table.concat(parts))
end

return M