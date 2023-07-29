## dependencies
- nvim
- wezterm
- rofi
- scrot
- wallpaper(~/Pictures/wallpaper)
- setxkbmap
- xcape
- i3lock-color / x11-utils

## todo
- monitor
    - [x] dual graph
        - [x] realtime tooltip
    - [x] clock tooltip
    - [x] disk
    - [x] margin
- keymap
    - [ ] shutdown, reboot whit timeout 10sec
    - [x] tap Super(xcape)
        - [x] !Super to exit rofi
            - `-kb-cancel '!Super+Control+Escape'"`
- overseer tag
    - [ ] rules
- rofi
    - [x] nvim

```lua
{
  rule = { class = "wm_kybrd_fcns.py" },
  properties = { floating = true },
  screen = awful.screen.focused,
  tags = { "1", "2", "3", "4", "5" }
},
```
