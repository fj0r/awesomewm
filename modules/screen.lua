local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local utils = require 'utils'
local get = require('utils.get')
local my_clock = utils.clock
local monitor = utils.monitor
-- Keyboard map indicator and switcher
local my_keyboardlayout = awful.widget.keyboardlayout()
local client = client
local screen = screen

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                { raise = true }
            )
        end
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end))


local wallpaper_setter = function(wallpaper)
    return function(s)
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

return function(conf, menu, wallpaper)
    local set_wallpaper = wallpaper_setter(wallpaper)

    local rotated_widget = utils.rotate(conf.sidebar.position)
    screen.connect_signal("property::geometry", set_wallpaper)

    local default_tag = nil
    local my_tags = {}
    local my_layouts = {}
    for k, v in ipairs(conf.tags) do
        table.insert(my_tags, v.name)
        table.insert(my_layouts, v.layout and #v.layout ~= 0
            and get(awful.layout.suit, v.layout)
            or awful.layout.suit.tile)
        if v.default then
            default_tag = k
        end
    end

    awful.screen.connect_for_each_screen(function(s)
        -- Wallpaper
        set_wallpaper(s)

        -- Each screen has its own tag table.
        -- awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
        awful.tag(my_tags, s, my_layouts)

        -- Create a promptbox for each screen
        s.my_promptbox = awful.widget.prompt()
        -- Create an imagebox widget which will contain an icon indicating which layout we're using.
        -- We need one layoutbox per screen.
        s.my_layoutbox = awful.widget.layoutbox(s)
        s.my_layoutbox:buttons(gears.table.join(
            awful.button({}, 1, function() awful.layout.inc(1) end),
            awful.button({}, 3, function() awful.layout.inc(-1) end),
            awful.button({}, 4, function() awful.layout.inc(1) end),
            awful.button({}, 5, function() awful.layout.inc(-1) end)))
        -- Create a taglist widget
        s.my_taglist = rotated_widget(utils.mk_taglist(s, conf.theme.powerline_taglist))

        -- Create a tasklist widget
        s.my_tasklist = rotated_widget(awful.widget.tasklist {
            screen  = s,
            filter  = awful.widget.tasklist.filter.currenttags,
            buttons = tasklist_buttons
        })

        -- Create the wibox
        conf.sidebar['screen'] = s
        s.my_wibox = awful.wibar(conf.sidebar)

        -- Add widgets to the wibox
        s.my_wibox:setup {
            layout = wibox.layout.align.vertical,
            { -- Left widgets
                layout = wibox.layout.fixed.vertical,
                s.my_layoutbox,
                s.my_taglist,
                rotated_widget(s.my_promptbox),
                my_clock(conf.theme.clock),
            },
            s.my_tasklist, -- Middle widget
            { -- Right widgets
                layout = wibox.layout.fixed.vertical,
                monitor(conf.monitor),
                rotated_widget(wibox.widget.systray()),
                my_keyboardlayout,
                menu.launcher,
            },
        }

        s.tags[default_tag or #s.tags]:view_only()
    end)
    -- }}}
end
