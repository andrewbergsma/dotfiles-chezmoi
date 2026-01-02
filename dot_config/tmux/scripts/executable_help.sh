#!/usr/bin/env bash
# tmux shortcuts help display

cat << 'EOF'
┌─────────────────────────────────────────┬─────────────────────────────────────────┐
│ PREFIX-FREE (No C-b)                    │ PREFIX (C-b +)                          │
├─────────────────────────────────────────┼─────────────────────────────────────────┤
│ PANES & NAVIGATION                      │ PANES & WINDOWS                         │
│ C-h/j/k/l  Navigate panes (vim)         │ h/j/k/l    Resize pane (repeatable)     │
│ M-\        Split horizontal             │ |          Split horizontal             │
│ M--        Split vertical               │ -          Split vertical               │
│ M-z        Zoom pane                    │ z          Zoom pane                    │
│ M-x        Kill pane (confirm)          │ x          Kill pane (confirm)          │
│                                         │ =          Even horizontal layout       │
│ WINDOWS                                 │ +          Even vertical layout         │
│ M-1..9     Jump to window 1-9           │ X          Kill window (confirm)        │
│ M-h        Previous window              │ i          Display pane numbers         │
│ M-l        Next window                  │ I          Display session info         │
│ M-c        New window                   │                                         │
│                                         │                                         │
│ SESSIONS                                │ WINDOWS (cont)                          │
│ M-s        Choose session               │ c          New window                   │
│ M-↑        Previous session             │ n          Next window                  │
│ M-↓        Next session                 │ p          Previous window              │
│ M-X        Kill window (confirm)        │ 0-9        Select window 0-9            │
│ COPY MODE                               │                                         │
│ M-[        Enter copy mode              │ SESSIONS                                │
│ M-Esc      Enter copy mode (alt)        │ S          Choose session               │
│                                         │ N          New session (prompt)         │
│ PLUGINS                                 │ Q          Kill session (confirm)       │
│ C-f        FZF launcher                 │ d          Detach from session          │
│ C-s        Save session (resurrect)     │ $          Rename session               │
│ C-r        Restore session (resurrect)  │                                         │
│ F          Thumbs (hint copy)           │ COPY MODE (vi)                          │
│ u          FZF URL selector             │ [          Enter copy mode              │
│ g          Floax terminal toggle        │ v          Begin selection              │
│ G          Floax menu                   │ C-v        Rectangle selection          │
│                                         │ y          Copy & exit                  │
│                                         │ Esc        Cancel                       │
│                                         │                                         │
│ HELP                                    │ UTILITIES                               │
│ M-?        This help (you are here!)   │ r          Reload config                │
│                                         │ C-y        Sync panes toggle            │
│                                         │ t          Quick terminal (bottom)      │
│                                         │ T          htop window                  │
│                                         │ ?          This help                    │
│                                         │ M-k        List all keys                │
└─────────────────────────────────────────┴─────────────────────────────────────────┘
EOF

read -n 1 -s -r -p "Press any key to close..."
