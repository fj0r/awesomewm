local get = function(obj, path)
    local o = obj
    for k in string.gmatch(path, "[^%s%.]+") do
        o = o[k]
    end
    return o
end

return get
