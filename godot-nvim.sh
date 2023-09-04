#!/usr/bin/env bash

# https://github.com/niscolas/nvim-godot/blob/main/run.sh

term_exec="foot"
nvim_exec="nvim"
server_path="$HOME/.cache/nvim/godot-server.pipe"

start_server() {
    "$term_exec" -e "$nvim_exec" --listen "$server_path" "$1"
}

open_file_in_server() {
    "$term_exec" -e "$nvim_exec" --server "$server_path" --remote-send "<C-\><C-n>:n $1<CR>:call cursor($2)<CR>"
}

if ! [ -e "$server_path" ]; then
    start_server "$1"
else 
    open_file_in_server "$1" "$2"
fi
