#!/bin/bash

echo "=== Environment ==="
echo "TERM: $TERM"
echo "COLORTERM: $COLORTERM"
echo "TMUX: ${TMUX:-not in tmux}"

echo -e "\n=== Color Support ==="
tput colors 2>/dev/null || echo "tput not available"

echo -e "\n=== Press keys to test (Ctrl-C to exit) ==="
echo "Try: Ctrl+Shift+F1, Ctrl+I, Tab, Ctrl+M, Enter"
cat -v
