local keys = require('modules.keys')

return {
    global           = keys.global,
    client           = keys.client,
    autorun          = require('modules.autorun'),
    handle_error     = require('modules.error'),
    theme            = require('modules.theme'),
    menu             = require('modules.menu'),
    select_wallpaper = require('modules.wallpaper'),
    rules            = require('modules.rule'),
    signal           = require('modules.signal'),
    screen           = require('modules.screen'),
    mouse            = require('modules.mouse'),
}
