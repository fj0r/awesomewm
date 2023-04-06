local awful = require("awful")
local utils = require 'utils'

return function(conf)
    -- autorun
    for _, v in ipairs(conf.autorun) do
        awful.spawn.with_shell(v)
    end

    for _, v in ipairs(conf.autorun_once) do
        utils.run_once.run(v)
    end

end
