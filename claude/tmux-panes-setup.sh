#!/usr/bin/env bash
# SessionStart hook: ensure a workbench + document-viewer tmux pane exist
# in the current window. Idempotent — re-uses existing panes titled
# "claude-workbench-<tag>" / "claude-viewer-<tag>" if they're already there.
#
# Panes are namespaced by the Claude tmux pane id (TMUX_PANE, stripped of '%')
# so concurrent Claude sessions in other windows don't clobber each other's
# titles or /tmp pane-id files.
#
# Pane IDs are written to /tmp so Claude (and the tmux-pane skill) can
# drive them via `tmux send-keys` / `tmux capture-pane`.
#
# If not running inside tmux, exit silently — no-op.

set -euo pipefail

# Not in tmux? Nothing to do.
if [ -z "${TMUX:-}" ] || [ -z "${TMUX_PANE:-}" ]; then
  echo '{}'
  exit 0
fi

TAG="${TMUX_PANE#%}"
WORKBENCH_TITLE="claude-workbench-${TAG}"
VIEWER_TITLE="claude-viewer-${TAG}"
WORKBENCH_FILE="/tmp/claude-tmux-pane-${TAG}"
VIEWER_FILE="/tmp/claude-viewer-pane-${TAG}"

find_pane_by_title() {
  tmux list-panes -F '#{pane_id} #{pane_title}' 2>/dev/null \
    | awk -v t="$1" '$2 == t {print $1; exit}'
}

ensure_pane_alive() {
  local id="$1"
  [ -n "$id" ] && tmux list-panes -F '#{pane_id}' 2>/dev/null | grep -qx "$id"
}

# Reuse if a previous session in this window left them; otherwise re-create.
workbench=$(find_pane_by_title "$WORKBENCH_TITLE" || true)
viewer=$(find_pane_by_title "$VIEWER_TITLE" || true)

if ! ensure_pane_alive "$workbench"; then
  workbench=$(tmux split-window -v -d -p 40 -P -F '#{pane_id}')
  tmux select-pane -t "$workbench" -T "$WORKBENCH_TITLE"
  tmux send-keys -t "$workbench" "clear; echo \"${WORKBENCH_TITLE} — ready\"" Enter
fi

if ! ensure_pane_alive "$viewer"; then
  viewer=$(tmux split-window -h -d -t "$workbench" -P -F '#{pane_id}')
  tmux select-pane -t "$viewer" -T "$VIEWER_TITLE"
  tmux send-keys -t "$viewer" "clear; echo \"${VIEWER_TITLE} — ready\"" Enter
fi

echo "$workbench" > "$WORKBENCH_FILE"
echo "$viewer"    > "$VIEWER_FILE"

# Tell Claude about the panes via additionalContext.
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Two tmux panes are pre-configured for this session and ready to drive via 'tmux send-keys -t <id>' and 'tmux capture-pane -t <id> -p'. They are namespaced by this Claude pane (TMUX_PANE=${TMUX_PANE}, tag=${TAG}) so they don't collide with other concurrent Claude sessions:\n- Workbench (long-running processes, log tails, builds): pane_id=${workbench}, title='${WORKBENCH_TITLE}', also at ${WORKBENCH_FILE}\n- Document viewer (display files/markdown/diffs via bat/glow/less/cat): pane_id=${viewer}, title='${VIEWER_TITLE}', also at ${VIEWER_FILE}\nAlways use the pane_id values above (or the tag-suffixed /tmp paths) — do NOT look up panes by the bare title 'claude-workbench' / 'claude-viewer', and do not split new panes unless these are missing."
  }
}
EOF
