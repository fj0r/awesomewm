local beautiful = require("beautiful")

local random_wallpaper = function(conf)
    local wallpaper_list = {}
    if conf.theme.wallpaper then
        local p = io.popen('find "' .. conf.theme.wallpaper .. '" -type f')
        for f in p:lines() do
            table.insert(wallpaper_list, f)
        end
    end
    math.randomseed(os.time())

    return function()
        if #wallpaper_list > 0 then
            local s = #wallpaper_list
            return wallpaper_list[math.random(s)]
        end
    end
end


return function(conf)
    local rw = random_wallpaper(conf)

    -- local wp = wallpaper_list[math.random(#wallpaper_list)]
    -- gears.wallpaper.maximized(wp, screen)
    local wallpaper
    if conf.theme.wallpaper then
        wallpaper = rw()
    else
        wallpaper = beautiful.wallpaper
    end

    return wallpaper
end
