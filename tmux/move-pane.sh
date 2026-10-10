tmux join-pane -d -s "$1" -t "$2:$3" 2>/dev/null \
    || tmux break-pane -d -s "$1" -t "$2:$3"

