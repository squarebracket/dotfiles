#!/bin/bash

function add_to_sessions() {
    local _CURRENT_TMUX_SESSION=$(tmux display-message -p "#S")
    local _CURRENT_TMUX_ENV=$(tmux show-environment ENVIRONMENT)
    echo "$_CURRENT_TMUX_SESSION" > /tmp/curtmux
    echo "$_CURRENT_TMUX_ENV" > /tmp/curtmuxenv
    for session in $(tmux list-sessions -F "#S"); do
        if [ "$session" != "$_CURRENT_TMUX_SESSION" ] && \
            [ "$(tmux show-environment -t $session ENVIRONMENT)" = "$_CURRENT_TMUX_ENV" ]; then
            echo "$session $(tmux show-environment -t $session ENVIRONMENT) $1" >> /tmp/sess
            #tmux link-window -s "$_CURRENT_TMUX_SESSION:$1" -t "$session"
        fi
    done
}

#tmux new-window -n "$1" "$2"

add_to_sessions "$1"
