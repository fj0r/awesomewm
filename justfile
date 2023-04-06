test:
    DISPLAY=:1.0 awesome -c ./rc.lua

init:
    Xephyr :1 -ac -br -noreset -screen 1152x720 &
