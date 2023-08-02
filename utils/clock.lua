-- Create a textclock widget
local awful = require 'awful'
local wibox = require 'wibox'
local gears = require 'gears'
local beautiful = require 'beautiful'


local tobitarray = function(r, t, len)
    for i = len - 1, 0, -1 do
        table.insert(r, (t & (1 << i)) ~= 0)
    end
end

local time_names = { 'y', 'm', 'd', 'w', 'H', 'M', 'S' }
local group_lines = { 2, 2, 2, 1, 2, 2, 2 }
local group_bits = {}
local init_bits = {}

local forced_num_cols = 3
local forced_num_rows = 0
for k, v in pairs(group_lines) do
    forced_num_rows = forced_num_rows + v
    group_bits[k] = v * forced_num_cols
end
local total = forced_num_rows * forced_num_cols

local group = {}
for k, v in ipairs(group_lines) do
    if k == 1 then
        group[k] = v * forced_num_cols
    else
        group[k] = v * forced_num_cols + group[k - 1]
    end
end

local gen_colors = function(conf)
    local color = {}
    local color_set = conf or { '#dde175', '#88b555' }
    for k = 1, #group do
        table.insert(color, color_set[k % #color_set + 1])
    end
    return color
end

return function(conf)
    local cached_time = {}
    for k, v in ipairs(time_names) do
        local t = tonumber(os.date('%' .. v))
        table.insert(cached_time, t)
        tobitarray(init_bits, t, group_bits[k])
    end

    local clock = {
        forced_num_cols = forced_num_cols,
        forced_num_rows = forced_num_rows,
        homogeneous     = false,
        expand          = true,
        forced_height   = 90,
        spacing         = 1,
        layout          = wibox.layout.grid
    }

    local color = gen_colors(conf)
    for i = 1, total do
        local c
        for k, v in ipairs(group) do
            if i <= v then
                c = color[k]
                break
            end
        end
        table.insert(clock, wibox.widget {
            checked      = init_bits[i],
            paddings     = 0,
            color        = c,
            border_color = '#555',
            border_width = 1,
            shape        = gears.shape.rectangle, -- rectangle octogon
            widget       = wibox.widget.checkbox
        })
    end
    local aclock = wibox.widget(clock)


    awful.tooltip {
        objects = { aclock },
        mode = 'outside',
        preferred_positions = { 'left', 'right' },
        preferred_alignments = 'middle',
        margins = 6,
        border_width = 2,
        bg = beautiful.tooltip_bg,
        timer_function = function()
            return '<b>' .. tostring(os.date('%Y-%m-%d %w %H:%M:%S %z')) .. '</b>'
        end
    }

    gears.timer {
        timeout   = 1,
        call_now  = true,
        autostart = true,
        callback  = function()
            local begin_bit = group[#group]
            local bits = {}
            for i = #time_names, 1, -1 do
                local t = tonumber(os.date('%' .. time_names[i]))
                if t == cached_time[i] then
                    break
                end
                cached_time[i] = t
                begin_bit = group[i - 1]
                for x = 0, group_bits[i] - 1, 1 do
                    table.insert(bits, 1, (t & (1 << x)) ~= 0)
                end
            end
            for i = begin_bit + 1, total, 1 do
                if clock[i].checked ~= bits[i - begin_bit] then
                    clock[i].checked = bits[i - begin_bit]
                end
            end
        end
    }

    return aclock
end
