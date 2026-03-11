#!/usr/bin/env bash
set -euo pipefail

MAIN="main"

# If already inside tmux, don't nest; just open a new window.
if [[ -n "${TMUX:-}" ]]; then
  exec tmux new-window
fi

# Ensure the main session exists.
if ! tmux has-session -t "$MAIN" 2>/dev/null; then
  exec tmux new-session -s "$MAIN"
fi

# Count attached clients on main.
clients="$(tmux list-clients -t "$MAIN" 2>/dev/null | wc -l | tr -d ' ')"

if [[ "$clients" -eq 0 ]]; then
  # Nobody is attached -> reuse main.
  exec tmux attach -t "$MAIN"
else
  # main is already in use -> create a temporary session that auto-destroys when unattached.
  S="tmp-$(date +%Y%m%d-%H%M%S)"
  exec tmux new-session -s "$S" \; set-option -t "$S" destroy-unattached on
fi

