local awful = require("awful")
local gears = require("gears")

return function()
    root.buttons(gears.table.join(
        awful.button({}, 3, function() my_mainmenu:toggle() end),
        awful.button({}, 4, awful.tag.viewnext),
        awful.button({}, 5, awful.tag.viewprev)
    ))
end
