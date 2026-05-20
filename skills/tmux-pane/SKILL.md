---
name: tmux-pane
description: Split the current tmux window vertically and operate a second shell in the new pane. Use for long-running processes, monitoring, or parallel work.
---

# tmux-pane

Open a second tmux pane and operate it freely alongside this conversation.

## Setup

1. Split and capture the new pane ID in one step:
   ```
   tmux split-window -v -P -F '#{pane_id}'
   ```
2. Title the pane so it's identifiable:
   ```
   tmux select-pane -t <pane_id> -T 'claude-workbench'
   ```
3. Write the pane ID to a state file so it survives context compaction:
   ```
   echo <pane_id> > /tmp/claude-tmux-pane
   ```

## Recovering the pane

If you lose track of the pane ID (e.g. after context compaction), recover it:
```
cat /tmp/claude-tmux-pane
```

To verify it's still alive:
```
tmux list-panes -F '#{pane_id} #{pane_title} #{pane_current_command}' | grep claude-workbench
```

If the pane is gone, re-run Setup.

## Operating the pane

Send commands:
```
tmux send-keys -t <pane_id> '<command>' Enter
```

Read output:
```
tmux capture-pane -t <pane_id> -p -S -50
```
(`-S -50` captures the last 50 lines. Adjust as needed.)

Send Ctrl-C to interrupt:
```
tmux send-keys -t <pane_id> C-c
```

Close when done:
```
tmux kill-pane -t <pane_id> && rm -f /tmp/claude-tmux-pane
```

## Rules

- Always read the pane output after sending a command to confirm it worked.
- Use this pane for things that benefit from running alongside the conversation: servers, file watchers, log tails, test loops, builds.
- Do NOT close the pane unless the user asks or the work is done.
- If $ARGUMENTS are provided, run them as the first command in the new pane.

$ARGUMENTS
