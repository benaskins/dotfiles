---
name: label
description: Rename the Claude session and the tmux window in one shot so the status bar stays in sync.
---

# Label

Rename both the Claude Code session and the current tmux window to keep
them in sync.

## Usage

```
/label <name>
```

## Steps

1. The name is provided in `$ARGUMENTS`. If empty, ask the user what
   name they want.
2. Rename the tmux window (disable automatic-rename so it sticks):
   ```
   tmux set-option -w -t "${TMUX_PANE}" automatic-rename off
   tmux rename-window -t "${TMUX_PANE}" '<name>'
   ```
3. Tell the user to run `/rename <name>` themselves — it's a built-in
   UI command that cannot be invoked via the Skill tool.

$ARGUMENTS
