local tag_keys = require('modules.keys.tag')
local global = function(conf, modkey, wallpaper)
    local common = require('modules.keys.common')(conf, modkey, wallpaper)
    return { keys = tag_keys(conf, modkey, common.keys), buttons = common.buttons }
end

return {
    client = require('modules.keys.client'),
    global = global
}
