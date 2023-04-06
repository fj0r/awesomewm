return function(obj)
    local naughty = require("naughty")
    local inspect = require('say.inspect')
    naughty.notify {
        titel = 'inspect',
        timeout = 0,
        opacity = 0.5,
        --position = 'top_middle',
        bg = '#FBFFB9',
        fg = 'black',
        text = inspect(obj)
    }
end
