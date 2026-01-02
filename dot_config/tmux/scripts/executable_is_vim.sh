#!/usr/bin/env bash
# Check if current tmux pane is running vim or nvim
# Used for C-h/j/k/l navigation (vim uses these for split navigation)

pane_current_command="$(tmux display-message -p '#{pane_current_command}')"

# Check if the process is vim or nvim
if [[ "$pane_current_command" =~ (^|\/)g?(view|n?vim?x?)(diff)?$ ]]; then
  exit 0
else
  exit 1
fi
