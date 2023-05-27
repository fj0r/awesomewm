local beautiful = require("beautiful")
local gears = require("gears")
local client = client

return function(conf)
    -- {{{ Variable definitions
    -- Themes define colours, icons, font and wallpapers.
    beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
    beautiful.font = conf.theme.font
    beautiful.useless_gap = conf.theme.gap

    local normal_bg              = conf.theme.color.normal.bg or beautiful.bg_normal
    local normal_fg              = conf.theme.color.normal.fg or beautiful.fg_normal
    local focus_bg               = conf.theme.color.focus.bg or beautiful.bg_focus
    local focus_fg               = conf.theme.color.focus.fg or beautiful.fg_focus
    local urgent_bg              = conf.theme.color.urgent.bg or beautiful.bg_urgent
    local urgent_fg              = conf.theme.color.urgent.fg or beautiful.fg_urgent
    beautiful.bg_normal          = normal_bg
    beautiful.fg_normal          = normal_fg
    beautiful.bg_focus           = focus_bg
    beautiful.fg_focus           = focus_fg
    beautiful.taglist_bg_normal  = normal_bg
    beautiful.taglist_fg_normal  = normal_fg
    beautiful.taglist_bg_focus   = focus_bg
    beautiful.taglist_fg_focus   = focus_fg
    beautiful.tasklist_bg_normal = normal_bg
    beautiful.tasklist_fg_normal = normal_fg
    beautiful.tasklist_bg_focus  = focus_bg
    beautiful.tasklist_fg_focus  = focus_fg

    -- Enable sloppy focus, so that focus follows mouse.
    client.connect_signal("mouse::enter", function(c)
        c:emit_signal("request::activate", "mouse_enter", { raise = false })
    end)

    client.connect_signal("focus", function(c)
        c.border_color = focus_bg
    end)
    client.connect_signal("unfocus", function(c)
        if c.urgent then return end
        c.border_color = normal_bg
    end)
    client.connect_signal("property::urgent", function(c)
        c.border_color = urgent_bg
    end)
end
