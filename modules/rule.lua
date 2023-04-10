local beautiful = require("beautiful")
local awful = require("awful")

return function(conf, client)
    local my_rules = {
        -- All clients will match this rule.
        {
            rule = {},
            properties = {
                border_width = conf.theme.border.width or beautiful.border_width,
                border_color = beautiful.border_normal,
                focus = awful.client.focus.filter,
                raise = true,
                keys = client.keys,
                buttons = client.buttons,
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

    for _, rule in ipairs(conf.rules) do
        table.insert(my_rules, rule)
    end

    for k, v in ipairs(conf.tags) do
        for _, term in ipairs(v.apps or {}) do
            local rule = {}
            local count = 0
            for p in ipairs({ 'instance', 'class', 'name', 'role' }) do
                if term[p] then
                    rule[p] = term[p]
                    term[p] = nil
                    count = count + 1
                end
            end
            if count > 0 then
                term.screen = term.screen or 1
                term.tag = k
                table.insert(my_rules, {
                    rule = rule,
                    properties = term
                })
            end
        end
    end

    return my_rules
end
