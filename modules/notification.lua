local awesome = awesome
local naughty = require('naughty')

return function (conf, version)
    -- version < 4.4
    if version[1] < 4 or version[1] == 4 and version[2] < 4 then
        for _, preset in pairs(naughty.config.presets) do
            preset.position = "bottom_right"
        end
    else
        ruled.notification.connect_signal('request::rules', function()
            -- All notifications will match this rule.
            ruled.notification.append_rule {
                rule       = { },
                properties = {
                    screen           = awful.screen.preferred,
                    implicit_timeout = 5,
                    position         = "bottom_right",
                }
            }
        end)
    end

end
