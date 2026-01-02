#!/usr/bin/env bash
# tmux shortcuts help display

cat << 'EOF'
┌─────────────────────────────────────────┬─────────────────────────────────────────┐
│ PREFIX-FREE (No C-b)                    │ PREFIX (C-b +)                          │
├─────────────────────────────────────────┼─────────────────────────────────────────┤
│ PANES & NAVIGATION                      │ PANES & NAVIGATION                      │
│ C-h/j/k/l  Navigate panes (vim)         │ h/j/k/l    Resize pane (repeatable)     │
│ M-\        Split horizontal             │ |          Split horizontal             │
│ M--        Split vertical               │ -          Split vertical               │
│ M-z        Zoom pane                    │ z          Zoom pane                    │
│ M-x        Kill pane (confirm)          │ x          Kill pane (confirm)          │
│                                         │ i          Display pane numbers         │
│                                         │ =          Even horizontal layout       │
│                                         │ +          Even vertical layout         │
│                                         │                                         │
│ WINDOWS                                 │ WINDOWS                                 │
│ M-1..9     Jump to window 1-9           │ 0-9        Select window 0-9            │
│ M-h / M-←  Previous window              │ p          Previous window              │
│ M-l / M-→  Next window                  │ n          Next window                  │
│ M-c        New window                   │ c          New window                   │
│ M-X        Kill window (confirm)        │ X          Kill window (confirm)        │
│                                         │ I          Display session info         │
│                                         │                                         │
│ SESSIONS                                │ SESSIONS                                │
│ M-s        Choose session               │ S          Choose session               │
│ M-k / M-j  Switch sessions (vim)        │ d          Detach from session          │
│                                         │ Q          Kill session (confirm)       │
│                                         │ $          Rename session               │
│                                         │                                         │
│ COPY MODE                               │ COPY MODE (vi)                          │
│ M-[        Enter copy mode              │ [          Enter copy mode              │
│ M-Esc      Enter copy mode (alt)        │ v          Begin selection              │
│                                         │ C-v        Rectangle selection          │
│                                         │ y          Copy & exit                  │
│                                         │ Esc        Cancel                       │
│                                         │ M-y/e      Scroll up/down (line)        │
│                                         │ M-u/d      Scroll up/down (half page)   │
│                                         │ M-b/f      Scroll up/down (full page)   │
│                                         │                                         │
│ PLUGINS                                 │ UTILITIES                               │
│ C-f        FZF launcher (prefix-free)   │ r          Reload config                │
│ C-s        Save session (resurrect)     │ C-y        Sync panes toggle            │
│ C-r        Restore session (resurrect)  │ t          Quick terminal (bottom)      │
│ g          Floax terminal toggle        │ T          htop window                  │
│ G          Floax menu                   │ f          Thumbs (hint copy)           │
│                                         │ u          FZF URL selector             │
│                                         │ ?          This help                    │
│                                         │ M-k        List all keys                │
│                                         │                                         │
│ HELP                                    │                                         │
│ M-?        This help (you are here!)   │                                         │
└─────────────────────────────────────────┴─────────────────────────────────────────┘
EOF

read -n 1 -s -r -p "Press any key to close..."
