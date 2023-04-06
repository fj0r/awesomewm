local hotkeys_popup = require("awful.hotkeys_popup")
local beautiful = require("beautiful")
local awful = require("awful")
local menubar = require("menubar")

return function(conf)
    local terminal = conf.terminal or "x-terminal-emulator"
    local editor = conf.editor or os.getenv("EDITOR")
    local editor_cmd = terminal .. " -e " .. editor
    -- {{{ Menu
    -- Create a launcher widget and a main menu
    local my_awesomemenu = {
        { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
        { "manual", terminal .. " -e man awesome" },
        { "edit config", editor_cmd .. " " .. awesome.conffile },
        { "restart", awesome.restart },
        { "quit", function() awesome.quit() end },
    }

    local menu_awesome = { "awesome", my_awesomemenu, beautiful.awesome_icon }
    local menu_terminal = { "open terminal", terminal }

    my_mainmenu = awful.menu {
        items = {
            menu_awesome,
            menu_terminal,
        }
    }

    local my_launcher = awful.widget.launcher {
        image = beautiful.awesome_icon,
        menu = my_mainmenu
    }

    -- Menubar configuration
    menubar.utils.terminal = terminal -- Set the terminal for applications that require it
    -- }}}

    return {
        launcher = my_launcher
    }
end
