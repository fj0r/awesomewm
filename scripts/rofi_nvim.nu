#!/usr/bin/env nu

# rofi -show nvim -modi "nvim:rofi_nvim.nu"

$env.LS_ROOT = '/opt/language-server'
source ~/Configuration/nushell/scripts/__env.nu

# https://github.com/davatorium/rofi/blob/next/doc/rofi-script.5.markdown
def set_opt [mode option] {
    print $"(char -i 0)($mode)(char us)($option)"
}

let history_file = $"($env.HOME)/.cache/rofi.sqlite"

if not ($history_file | path exists) {
    "create table if not exists nvim_history (
        cmd text primary key,
        count int default 1,
        recent datetime default (datetime('now', 'localtime'))
    );" | sqlite3 $history_file
}

def --env open [prog arg] {
    $env.NVIM_LEVEL = 'x'
    source ~/.nu
    if $prog == 'neovide' {
        mut cmd = []
        if $arg =~ ':[0-9]+$' {
            mut addr = ''
            if ($arg | str starts-with ':') {
                $addr = $"localhost($arg)"
            } else {
                $addr = $arg
            }
            $cmd = [--server $addr -- $"+\"set title titlestring=($addr)\""]
        } else if $arg == ':' {
            $cmd = [$"+\"set title titlestring=world\""]
        } else {
            $cmd = [$"+\"set title titlestring=($arg)\"" -- $arg]
        }
        neovide --multigrid --maximized $cmd
    }
}

def main [input?: string] {
    if ($input | is-empty) {
        let opts = ('select cmd from nvim_history order by count desc limit 9;'
                   | sqlite3 $history_file
                   | lines)
        if not ($env.HOME in $opts) {
            print $env.HOME
        }
        for i in $opts {
            print $i
        }
    } else if ($input | str starts-with '<') {
        print $"$env.ROFI_RETV: ($env.ROFI_RETV)"
        print 'PATH:'
        for p in $env.PATH {
            print $p
        }
    } else if ($input | str starts-with '>') {
    } else {
        $"insert into nvim_history\(cmd\) values \('($input)'\)
        on conflict\(cmd\) do
        update set count = count + 1,
                   recent = datetime\('now', 'localtime'\);"
        | sqlite3 $history_file
        open neovide $input
    }
}
