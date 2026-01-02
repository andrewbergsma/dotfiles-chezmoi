#!/usr/bin/env bash
# Check if current tmux pane is running vim, nvim, or yazi
# Used for Alt-based bindings that should not interfere with these apps

pane_current_command="$(tmux display-message -p '#{pane_current_command}')"

# Check if the process is vim, nvim, or yazi
if [[ "$pane_current_command" =~ (^|\/)g?(view|n?vim?x?)(diff)?$ ]] || \
   [[ "$pane_current_command" == "yazi" ]]; then
  exit 0
else
  exit 1
fi
