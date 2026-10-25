local M = {}

function M.log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    print("[RaguElp] " .. table.concat(parts))
end

return M