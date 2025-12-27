#!/usr/bin/env bash
# tmux shortcuts help display

cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                           TMUX SHORTCUTS                                    ║
╠════════════════════════════════════════════════════════════════════════════╣
║  PREFIX = Ctrl+b                                                            ║
╠════════════════════════════════════════════════════════════════════════════╣
║  WINDOWS & PANES                                                            ║
║  ─────────────────                                                          ║
║  |         Split horizontal      -         Split vertical                   ║
║  c         New window            n/p       Next/prev window                 ║
║  0-9       Select window         z         Toggle zoom                      ║
║  =         Even horizontal       +         Even vertical                    ║
║  x         Kill pane             X         Kill window                      ║
║  i         Display panes         I         Display info                     ║
╠════════════════════════════════════════════════════════════════════════════╣
║  SESSIONS                                                                   ║
║  ─────────────────                                                          ║
║  S         Choose session        N         New session                      ║
║  Q         Kill session          d         Detach                           ║
║  $         Rename session                                                   ║
╠════════════════════════════════════════════════════════════════════════════╣
║  PLUGINS                                                                    ║
║  ─────────────────                                                          ║
║  F         Thumbs (copy)         u         FZF URL                          ║
║  g         Floax toggle          G         Floax menu                       ║
║  Ctrl+f    FZF launcher          Ctrl+s    Save session                     ║
║  Ctrl+r    Restore session                                                  ║
╠════════════════════════════════════════════════════════════════════════════╣
║  UTILITIES                                                                  ║
║  ─────────────────                                                          ║
║  r         Reload config         Ctrl+y    Sync panes toggle                ║
║  t         Quick terminal        T         htop window                      ║
║  ?         This help             Alt+?     Key list                         ║
╠════════════════════════════════════════════════════════════════════════════╣
║  COPY MODE (vi)                                                             ║
║  ─────────────────                                                          ║
║  [         Enter copy mode       v         Begin selection                  ║
║  y         Copy & exit           Escape    Cancel                           ║
║  Ctrl+v    Rectangle mode                                                   ║
╚════════════════════════════════════════════════════════════════════════════╝
EOF

read -n 1 -s -r -p "Press any key to close..."
