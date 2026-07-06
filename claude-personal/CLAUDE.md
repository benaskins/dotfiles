# CLAUDE.md — personal account

This is the **personal** Claude Code account, isolated from the work account via
`CLAUDE_CONFIG_DIR=~/.claude-personal`. It has its own login, sessions, memory,
and skills — nothing here is shared with the work account on the default
`~/.claude`.

## Context

- Personal projects only. Do not assume work repos, work credentials, or work
  vocabulary apply.
- macOS on Apple Silicon. Go-first, Swift for macOS apps, TypeScript for Workers.
  No Python.

## Conventions

- Conventional commits: `<type>: <description>`
- Secrets go in vault or keychain, never in dotfiles or source.
- Check repo state before starting work; never assume state from a prior session.
