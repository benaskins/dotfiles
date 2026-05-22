---
name: tmux-pane
description: Drive the pre-configured workbench and document-viewer tmux panes alongside this conversation. Use for long-running processes, monitoring, parallel work, or displaying files for visual review.
---

# tmux-pane

Two tmux panes are pre-configured per Claude session by the SessionStart
hook (`~/.claude/tmux-panes-setup.sh`). They are namespaced by this
Claude pane's tmux id (`${TMUX_PANE#%}`) so concurrent Claude sessions
in other windows don't collide:

- **Workbench** — long-running processes, log tails, builds, tests.
  Title: `claude-workbench-<tag>`. Pane ID in `/tmp/claude-tmux-pane-<tag>`.
- **Viewer** — display files, markdown, diffs, images via `bat`, `glow`,
  `git diff`, `less`, etc.
  Title: `claude-viewer-<tag>`. Pane ID in `/tmp/claude-viewer-pane-<tag>`.

The SessionStart `additionalContext` in your system prompt always
contains the resolved `pane_id` values for this session — prefer those
over recomputing.

## Recover the pane IDs

```
TAG="${TMUX_PANE#%}"
WB=$(cat "/tmp/claude-tmux-pane-${TAG}")
VW=$(cat "/tmp/claude-viewer-pane-${TAG}")
```

Verify they're alive (scoped to this window only):
```
tmux list-panes -F '#{pane_id} #{pane_title}' \
  | grep -E "claude-workbench-${TAG}|claude-viewer-${TAG}"
```

Never look up panes by the bare titles `claude-workbench` /
`claude-viewer` — those don't exist any more, and matching across
windows would pull in another Claude session's panes.

If a pane is missing (e.g. user closed it, or you're not in tmux),
re-run the hook script: `~/.claude/tmux-panes-setup.sh`.

## Operate a pane

```
tmux send-keys -t "$WB" '<command>' Enter        # send a command
tmux capture-pane -t "$WB" -p -S -50             # read last 50 lines
tmux send-keys -t "$WB" C-c                       # interrupt
```

Same for `$VW`.

## When to use which

- **Workbench**: `tail -f`, `npm run dev`, `cargo watch`, `aws-vault exec ... just smoke-test`, anything that runs for a while.
- **Viewer**: `bat README.md`, `glow PRD-09.md`, `git diff main...HEAD`, `less <(curl ...)`. Use it to put a document in front of the user without dumping it into the transcript.

## Rules

- Always read pane output after sending a command to confirm it worked.
- Don't kill the panes — they're persistent across the session by design.
- Don't split new panes yourself; reuse what the hook gave you.
- If `$ARGUMENTS` are provided, run them in the workbench as the first command.

$ARGUMENTS
