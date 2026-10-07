#!/usr/bin/env bash
# Open one tmux window per session, in the supervisor's tmux session, and start
# Claude in each with its brief.
# Usage: launch-windows.sh <briefs-dir> <name>:<dir> [<name>:<dir>...]
# Set MODEL to pass --model to every session.
set -euo pipefail

[[ $# -ge 2 ]] || { echo "usage: launch-windows.sh <briefs-dir> <name>:<dir>..." >&2; exit 2; }
[[ -n "${TMUX_PANE:-}" ]] || { echo "not inside tmux" >&2; exit 1; }

briefs="$1"
shift
session=$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}')
today=$(date +%F)
model_flag=""
if [[ -n "${MODEL:-}" ]]; then
  model_flag="--model $(printf %q "$MODEL") "
fi

for spec in "$@"; do
  name="${spec%%:*}"
  dir="${spec#*:}"
  if [[ ! -f "$briefs/$name.md" ]]; then
    echo "skip $name: no brief at $briefs/$name.md" >&2
    continue
  fi
  if tmux list-windows -t "$session" -F '#W' | grep -qx "$name"; then
    echo "skip $name: window already exists" >&2
    continue
  fi
  if [[ ! -d "$dir" ]]; then
    echo "skip $name: no directory $dir" >&2
    continue
  fi
  # -d keeps focus on the supervisor; each session's pane hook targets its own window.
  tmux new-window -d -t "${session}:" -n "$name" -c "$dir"
  tmux set-option -w -t "${session}:${name}" automatic-rename off
  prompt="You are the '${name}' session, supervised by the 'supervisor' tmux window. Today is ${today}. Read your brief at ${briefs}/${name}.md, check the repo and worktree state (just whereami and just worktree-tidy if the repo has them, report only), verify the open threads against GitHub, then give Ben a short numbered status and wait for direction."
  tmux send-keys -t "${session}:${name}" "claude ${model_flag}-n $(printf %q "$name") $(printf %q "$prompt")" Enter
  echo "launched $name in $dir"
done
