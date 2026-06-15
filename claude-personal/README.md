# claude-personal

Seed config for a **personal** Claude Code account that runs fully isolated from
the work account on the same machine.

## How isolation works

Claude Code relocates its entire config root when `CLAUDE_CONFIG_DIR` is set:
credentials, sessions, history, memory, skills, and the global `CLAUDE.md` all
live under that directory. On macOS the Keychain credential entry is namespaced
by a hash of the config-dir path (`Claude Code-credentials-<hash>`), so the two
accounts hold **separate logins** and can run at the same time in different
terminals.

| Account  | Config dir          | Invoke with        |
|----------|---------------------|--------------------|
| Work     | `~/.claude`         | `claude`           |
| Personal | `~/.claude-personal`| `claude-personal`  |

## Seed, not symlink

`setup.sh` **copies** the files in this folder into `~/.claude-personal/` only if
that file doesn't already exist. They are starting points — once the personal
account is live it owns its own config, and Claude Code writes back to those
files (survey state, etc.), so they are intentionally not symlinked to the repo.

The live `~/.claude-personal/` directory (credentials, sessions, history) is
never committed.

## What `setup.sh` lays down

Beyond the seed config, `setup.sh` wires the personal account with only the
**non-project-specific** skills and config — nothing from the work account
comes across:

- **Config:** `settings.json` (opus, high effort, docker/ssh permissions,
  slop-guard + go-build + tmux-panes hooks, statusline, plugins) and `.lsp.json`
  (Go / gopls with staticcheck).
- **Scripts:** `statusline-command.sh`, `tmux-panes-setup.sh` (symlinked from
  `../claude/`).
- **Skills (symlinked):** `archive`, `tmux-pane`, `label` from this repo, plus
  `audit`, `brainstorm`, `debug`, `deploy`, `ground`, `iterate`, `triage`,
  `verify` from the [`humanpowers`](https://github.com/benaskins/humanpowers)
  portable skill library (if cloned at `~/dev/humanpowers`).

Work project-specific skills are not linked here — they stay on the work
account only.

## First-time login

```bash
claude-personal      # launches with CLAUDE_CONFIG_DIR=~/.claude-personal
/login               # browser OAuth — sign in with the personal account
```
