local awful = require("awful")

local open_with_vim = function(prog)
    return function(args)
        if #args > 0 then
            local title = " +\"set title titlestring={}\""
            if args:match(':[0-9]+$') then
                if string.sub(args, 1, 1) == ':' then
                    args = 'localhost' .. args
                end
                local cmd = prog:gsub('{}',
                    ' --server ' .. args
                    .. " -- " .. title:gsub('{}', args))
                awful.spawn(cmd, { name = args })
            else
                local cmd = prog:gsub('{}',
                    title:gsub('{}', args)
                    .. " -- " .. args)
                awful.spawn(cmd, { name = args })
            end
        else
            awful.spawn(prog:gsub('{}', ''))
        end
    end
end

local env_path = "export NVIM_LEVEL=x SHELL=/usr/local/bin/nu TERM=screen-256color; "
              .. "export PATH=/opt/node/bin:/opt/go/bin:/opt/language-server/rust/bin:/opt/language-server/lua/bin:/opt/node/bin:$HOME/.local/bin:$PATH; "
              .. "export LS_ROOT=/opt/language-server; "

local ide = "bash -c '" .. env_path .. "/usr/local/bin/neovide --multigrid --maximized {}'"

-- awful.key({ meta }, "Return", rofi_neovide, { description = "enter development envrionment", group = "launcher" }),
local rofi_neovide = function()
    local history_file = os.getenv("HOME") .. "/.cache/awesome.sqlite"
    -- echo "create table if not exists rofi_nvim_history (cmd text primary key, count int default 1, recent datetime default (datetime('now', 'localtime')));" | sqlite3 ~/.cache/awesome.sqlite
    awful.spawn.easy_async_with_shell(
        "echo 'select cmd from rofi_nvim_history order by count desc limit 9;' " ..
        "| sqlite3 " .. history_file,
        function(history)
            awful.spawn.easy_async_with_shell(
                "echo \"new\n" .. history .. "\" | rofi -dmenu -p 'neovim open'",
                function(out)
                    local it = out:gsub("\n", '')
                    if it == "new" then
                        open_with_vim(ide)('')
                    elseif it == "" then
                    else
                        awful.spawn.with_shell(
                            "echo \"insert into rofi_nvim_history(cmd) values ('" .. it .. "') " ..
                            "on conflict(cmd) do update set count = count + 1, recent = datetime('now', 'localtime');\" " ..
                            "| sqlite3 " .. history_file
                        )
                        open_with_vim(ide)(it)
                    end
                end
            )
        end
    )
    --[[
    awful.prompt.run({ prompt = "Remote: " },
        awful.screen.focused().my_promptbox.widget,
        open_with_vim(ide))
    --]]
end
