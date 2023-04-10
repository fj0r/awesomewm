local common_keys = require('modules.keys.common')
local tag_keys    = require('modules.keys.tag')
local global = function(conf, modkey, wallpaper)
    local ck = common_keys(conf, modkey, wallpaper)
    return { keys = tag_keys(conf, modkey, ck) }
end

return {
    client = require('modules.keys.client'),
    global = global
}
