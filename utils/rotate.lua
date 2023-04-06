local wibox = require("wibox")

local rotated_widget = function(sidebar)
    local dr = sidebar == 'right' and 'west' or 'east'
    return function(w)
        local c = wibox.container.rotate()
        c:set_direction(dr)
        c:set_widget(w)
        return c
    end
end

return rotated_widget
