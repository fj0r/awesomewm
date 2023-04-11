local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require('gears')
local say = require('say')

local attach_tooltip = function(obj, fun)
    return awful.tooltip {
        objects = { obj },
        mode = 'outside',
        preferred_positions = { 'left', 'right' },
        preferred_alignments = 'middle',
        margins = 6,
        border_width = 2,
        bg = beautiful.tooltip_bg,
        timer_function = fun
    }
end

local function new_dual(config)
    local widgets = {}
    for k = #config.metrics, 1, -1 do
        local v = config.metrics[k]
        local g = wibox.widget {
            max_value = config.max_value or 100,
            scale = config.scale,
            color = v.color,
            widget = wibox.widget.graph,
            opacity = 0.5,
            width = 60,
        }
        table.insert(widgets, k % 2 == 1 and g or wibox.container.mirror(g, { vertical = true }))
        v.src {
            settings = function()
                g:add_value(v.value())
            end
        }
    end
    widgets.layout = wibox.layout.stack
    local m = wibox.widget(widgets)

    attach_tooltip(m, function()
        local text = ''
        local len = #config.metrics
        for k, v in ipairs(config.metrics) do
            local sep = k == len and '' or '\n'
            text = text .. v.format(v.value()) .. sep
        end
        return text
    end)
    return m
end

local cpu_mem = function()
    return new_dual {
        metrics = {
            {
                color = '#728639',
                src = lain.widget.cpu,
                value = function() return cpu_now.usage end,
                format = function(v) return 'cpu: <b>' .. v .. '</b>%' end,
            },
            {
                color = '#1071b0',
                src = lain.widget.mem,
                value = function() return mem_now.perc end,
                format = function(v) return 'mem: <b>' .. v .. '</b>%(<b>' .. mem_now.used .. '</b>M)' end,
            }
        }
    }
end


local two_digit = function(f)
    return math.ceil(f * 100) / 100
end
local GB = 1024 * 1024
local MB = 1024
local format_net = function(txt, total)
    return function(v)
        local value = v
        local unit = 'K'
        if v > GB then
            value = v / GB
            unit = 'G'
        elseif v > MB then
            value = v / MB
            unit = 'M'
        end
        return txt .. ': <b>' .. two_digit(value) .. unit .. '</b>/' .. total
    end
end

local net = function(config)
    local bandwidth = config.bandwidth or 10
    return new_dual {
        max_value = bandwidth * MB,
        metrics = {
            {
                color = '#08787f',
                reflection = true,
                src = lain.widget.net,
                value = function() return net_now.received + 0 end,
                format = format_net('down', bandwidth .. 'M')
            },
            {
                color = '#ff964f',
                src = lain.widget.net,
                value = function() return net_now.sent + 0 end,
                format = format_net('up', bandwidth .. 'M')
            }
        }
    }
end


local color_generator = function(colors)
    return function(value, total, reverse)
        local ix = math.ceil(value / (total / #colors))
        if reverse then
            ix = #colors - ix + 1
        end
        return colors[ix]
    end
end

local color_rank = color_generator {
    '#d81159', '#af4034', '#fdd692', '#c5e99b', '#5cab7d'
}

local function new_pie(config)
    local c = wibox.widget {
        checked       = false,
        bg            = '#888',
        color         = beautiful.bg_normal,
        border_color  = beautiful.bg_normal,
        border_width  = 6,
        paddings      = 3,
        shape         = gears.shape.circle,
        widget        = wibox.widget.checkbox
    }
    local m = wibox.widget {
        colors = {},
        min_value = 0,
        max_value = config.max_value or 100,
        rounded_edge = false,
        start_angle = 0,
        thickness = 2,
        bg = '#888',
        border_width = 0,
        border_color = '#fff',
        widget = wibox.container.arcchart,
        align = "center",
        valign = "center",
        values = {}
    }
    config.src {
        settings = function()
            local s = config.status()
            if s == 1 then
                c.checked = true
            else
                c.checked = false
            end
            local v = config.value()
            if v == 0 then
                local cl = config.invalid_color or 'black'
                m.colors = { cl }
                c.color = cl
            else
                local cl = color_rank(v, 100)
                m.colors = { cl }
                c.color = cl
            end
            m.values = { v }
        end
    }
    attach_tooltip(m, function()
        return config.format(config.value())
    end)
    return wibox.widget {
        c,
        m,
        layout = wibox.layout.stack
    }
end

local battery = function()
    return new_pie {
        color = '#ffd8b1',
        invalid_color = 'black',
        src = lain.widget.bat,
        status = function() return bat_now.ac_status end,
        value = function() return bat_now.perc == 'N/A' and 0 or bat_now.perc end,
        format = function(v) return v > 0 and 'BATTERY: <b>' .. v .. '</b>%' or 'NO BATTERY' end
    }
end

local function new_fschart(config)
    local fs_text = wibox.widget {
        text   = config.text,
        align  = "center",
        valign = "center",
        widget = wibox.widget.textbox,
    }
    local fs_chart = wibox.widget {
        fs_text,
        colors       = config.colors,
        values       = {},
        max_value    = 100,
        min_value    = 0,
        rounded_edge = false,
        start_angle  = 0,
        thickness    = 3,
        bg           = "#888",
        border_width = 0,
        border_color = "#000000",
        widget       = wibox.container.arcchart,
        align        = "center",
        valign       = "center",
    }
    return fs_chart
end

local fstab = function(exclude_prefix)
    local fs = {}
    local p = io.popen("cat /etc/fstab | grep -v '^#' | awk '{print $2}'")
    for f in p:lines() do
        for _, e in ipairs(exclude_prefix or {}) do
            if string.sub(f, 1, string.len(e)) == e then
                goto continue
            end
        end
        table.insert(fs, f)
        ::continue::
    end
    return fs
end

local fsw = function(config)
    local refs = {}
    local x = {
        layout = wibox.layout.fixed.vertical,
        align = 'center',
        valign = 'center',
    }
    local partitions = type(config.partitions) == "table"
        and config.partitions
        or fstab { '/boot', '/dev', '/proc', 'swap', 'none' }

    for _, v in ipairs(partitions) do
        local y = new_fschart {
            values = {},
            colors = {},
            default_color = config.default_colors or '#666',
        }
        table.insert(x, wibox.container.margin(y, 2, 2, 1, 1))
        refs[v] = y
        attach_tooltip(y, function() return refs[v].tooltip end)
    end
    lain.widget.fs {
        settings = function()
            for _, v in ipairs(partitions) do
                local p = fs_now[v]
                refs[v].values = { p.percentage }
                refs[v].tooltip = '<b>' ..
                    v .. '</b>: ' .. two_digit(p.free) .. p.units .. ' free, ' .. p.percentage .. '%'
                local c = color_rank(p.percentage, 100, true)
                refs[v].colors = { c }
            end
        end
    }
    return wibox.widget(x)
end

local rotate = function(w)
    local c = wibox.container.rotate()
    c:set_direction('west')
    c:set_widget(w)
    return c
end

return function(config)
    return wibox.widget {
        layout = wibox.layout.fixed.vertical,
        wibox.container.margin(rotate(cpu_mem()), 0, 0, 2, 1),
        wibox.container.margin(rotate(net(config)), 0, 0, 0, 2),
        wibox.container.margin(battery(), 2, 2, 1, 1),
        fsw(config),
    }
end
