local M = {}

M.script_path = function()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

M.read_file = function(path)
    local file = io.open(path, 'rb')
    local content = file:read("*a")
    file:close()
    return content
end

return M
