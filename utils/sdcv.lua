awful.key({ modkey }, "d",
    function()
        info = true
        awful.prompt.run({
            fg_cursor = "black", bg_cursor = "orange", prompt = "<span color='#008DFA'>sdcv:</span>"
        },
            my_promptbox[mouse.screen].widget,
            function(word)
                local f = io.popen("sdcv -n " .. word)
                local fr = ""
                for line in f:lines() do
                    fr = fr .. line .. 'n'
                end
                f:close()
                naughty.notify({ title = "<span color='red'>" .. word .. "</span>:",
                    text = '<span font_desc="Sans 7">' .. fr .. '</span>', timeout = 5, width = 400,
                    screen = mouse.screen })
            end)
    end)
