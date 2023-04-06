local beautiful = require("beautiful")
local awful = require("awful")
local gears = require("gears")

return function(conf, modkey, clientkeys)
    local clientbuttons = gears.table.join(
        awful.button({}, 1, function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
        end),
        awful.button({ modkey }, 1, function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.move(c)
        end),
        awful.button({ modkey }, 3, function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.resize(c)
        end)
    )

    return {
        -- All clients will match this rule.
        {
            rule = {},
            properties = {
                border_width = conf.theme.border.width or beautiful.border_width,
                border_color = beautiful.border_normal,
                focus = awful.client.focus.filter,
                raise = true,
                keys = clientkeys,
                buttons = clientbuttons,
                screen = awful.screen.preferred,
                placement = awful.placement.no_overlap + awful.placement.no_offscreen
            }
        },

        {
            rule = { class = 'MPlayer' },
            properties = {
                floating = true,
                ontop = true,
                placement = awful.placement.centered
            }
        },

        -- Floating clients.
        {
            rule_any = conf.floating,
            properties = {
                floating = true,
                ontop = true,
                placement = awful.placement.centered
            }
        },

        -- Add titlebars to normal clients and dialogs
        {
            rule_any = {
                type = { "normal", "dialog" }
            },
            properties = { titlebars_enabled = false }
        },

        -- Set Firefox to always map on the tag named "2" on screen 1.
        -- { rule = { class = "Firefox" },
        --   properties = { screen = 1, tag = "2" } },
    }
end
