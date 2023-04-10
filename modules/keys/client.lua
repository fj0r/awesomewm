local awful = require("awful")
local gears = require("gears")

return function(meta)
    local keys = gears.table.join(
        awful.key({ meta, "Control" }, "Return",
            function(c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            { description = "toggle fullscreen", group = "client" }),
        awful.key({ meta, }, "c", function(c) c:kill() end,
            { description = "close", group = "client" }),
        awful.key({ meta, }, "f", awful.client.floating.toggle,
            { description = "toggle floating", group = "client" }),
        awful.key({ meta, }, "y", function(c) c:swap(awful.client.getmaster()) end,
            { description = "move to master", group = "client" }),
        awful.key({ meta, }, ";", function(c) c:move_to_screen() end,
            { description = "move to screen", group = "client" }),
        awful.key({ meta, }, "t", function(c) c.ontop = not c.ontop end,
            { description = "toggle keep on top", group = "client" }),
        awful.key({ meta, }, "m",
            function(c)
                c.maximized = not c.maximized
                c:raise()
            end,
            { description = "(un)maximize", group = "client" }),
        awful.key({ meta, "Control" }, "m",
            function(c)
                c.maximized_vertical = not c.maximized_vertical
                c:raise()
            end,
            { description = "(un)maximize vertically", group = "client" }),
        awful.key({ meta, "Shift" }, "u", function(c) c.urgent = true end,
            { description = "mark client urgent", group = "client" }),
        awful.key({ meta, "Shift" }, "m",
            function(c)
                c.maximized_horizontal = not c.maximized_horizontal
                c:raise()
            end,
            { description = "(un)maximize horizontally", group = "client" })
        --[[
        awful.key({ meta,           }, ",",
            function (c)
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                c.minimized = true
            end ,
            {description = "minimize", group = "client"}),
        awful.key({ meta, "Control" }, ",",
            function ()
                local c = awful.client.restore()
                -- Focus restored client
                if c then
                  c:emit_signal(
                      "request::activate", "key.unminimize", {raise = true}
                  )
                end
            end,
            {description = "restore minimized", group = "client"})
        --]]
    )

    local buttons = gears.table.join(
        awful.button({}, 1, function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
        end),
        awful.button({ meta }, 1, function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.move(c)
        end),
        awful.button({ meta }, 3, function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.resize(c)
        end)
    )
    return { keys = keys, buttons = buttons }
end
