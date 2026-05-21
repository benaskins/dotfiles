#!/usr/bin/env bash
# SessionStart hook: ensure a workbench + document-viewer tmux pane exist
# in the current window. Idempotent — re-uses existing panes titled
# "claude-workbench" / "claude-viewer" if they're already there.
#
# Pane IDs are written to /tmp so Claude (and the tmux-pane skill) can
# drive them via `tmux send-keys` / `tmux capture-pane`.
#
# If not running inside tmux, exit silently — no-op.

set -euo pipefail

# Not in tmux? Nothing to do.
if [ -z "${TMUX:-}" ]; then
  echo '{}'
  exit 0
fi

WORKBENCH_FILE=/tmp/claude-tmux-pane
VIEWER_FILE=/tmp/claude-viewer-pane

find_pane_by_title() {
  tmux list-panes -F '#{pane_id} #{pane_title}' 2>/dev/null \
    | awk -v t="$1" '$2 == t {print $1; exit}'
}

ensure_pane_alive() {
  local id="$1"
  [ -n "$id" ] && tmux list-panes -F '#{pane_id}' 2>/dev/null | grep -qx "$id"
}

# Reuse if a previous session left them; otherwise re-create.
workbench=$(find_pane_by_title 'claude-workbench' || true)
viewer=$(find_pane_by_title 'claude-viewer' || true)

if ! ensure_pane_alive "$workbench"; then
  workbench=$(tmux split-window -v -d -p 40 -P -F '#{pane_id}')
  tmux select-pane -t "$workbench" -T 'claude-workbench'
  tmux send-keys -t "$workbench" 'clear; echo "claude-workbench — ready"' Enter
fi

if ! ensure_pane_alive "$viewer"; then
  viewer=$(tmux split-window -h -d -t "$workbench" -P -F '#{pane_id}')
  tmux select-pane -t "$viewer" -T 'claude-viewer'
  tmux send-keys -t "$viewer" 'clear; echo "claude-viewer — ready"' Enter
fi

echo "$workbench" > "$WORKBENCH_FILE"
echo "$viewer"    > "$VIEWER_FILE"

# Tell Claude about the panes via additionalContext.
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Two tmux panes are pre-configured for this session and ready to drive via 'tmux send-keys -t <id>' and 'tmux capture-pane -t <id> -p':\n- Workbench (long-running processes, log tails, builds): pane_id=$workbench, also at $WORKBENCH_FILE\n- Document viewer (display files/markdown/diffs via bat/glow/less/cat): pane_id=$viewer, also at $VIEWER_FILE\nPanes are pre-titled 'claude-workbench' / 'claude-viewer' so the hook is idempotent — do not split new panes unless these are missing."
  }
}
EOF
