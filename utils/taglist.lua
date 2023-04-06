local wibox = require 'wibox'
local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'

local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                { raise = true }
            )
        end
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end))
local powerline_taglist = function(s)
    return awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        style = {
            shape = gears.shape.powerline
        },
        layout = {
            spacing = -12,
            spacing_widget = {
                color = '#dddddd',
                shape = gears.shape.powerline,
                widget = wibox.widget.separator
            },
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
                {
                    {
                        {
                            {
                                id = 'index_role',
                                widget = wibox.widget.textbox
                            },
                            margins = 1,
                            widget = wibox.container.margin
                        },
                        bg = '#dddddd',
                        shape = gears.shape.circle,
                        widget = wibox.container.background
                    },
                    {
                        {
                            id = 'icon_role',
                            widget = wibox.widget.imagebox
                        },
                        margins = 2,
                        widget = wibox.container.margin
                    },
                    {
                        id = 'text_role',
                        widget = wibox.widget.textbox
                    },
                    layout = wibox.layout.fixed.horizontal
                },
                left = 14,
                right = 7,
                widget = wibox.container.margin
            },
            id = 'background_role',
            widget = wibox.container.background,
            -- Add support for hover colors and an index label
            create_callback = function(self, c3, index, objects) --luacheck: no unused args
                self:get_children_by_id('index_role')[1].markup = '<b> ' .. c3.index .. ' </b>'
                self:connect_signal(
                    'mouse::enter',
                    function()
                        if self.bg ~= '#88b555' then
                            self.backup = self.bg
                            self.has_backup = true
                        end
                        self.bg = '#88b555'
                    end
                )
                self:connect_signal(
                    'mouse::leave',
                    function()
                        if self.has_backup then
                            self.bg = self.backup
                        end
                    end
                )
            end,
            update_callback = function(self, c3, index, objects) --luacheck: no unused args
                self:get_children_by_id('index_role')[1].markup = '<b> ' .. c3.index .. ' </b>'
            end
        },
        buttons = taglist_buttons
    }
end

local default_taglist = function(s)
    local taglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }
    return taglist
end

local mk_taglist = function(s, power)
    if power then
        return powerline_taglist(s)
    else
        return default_taglist(s)
    end
end

return mk_taglist
