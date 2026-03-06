# CLAUDE.md

Dotfiles for a Go + Swift + SvelteKit development environment on macOS (Apple Silicon).

Optimised for working on [lamina](https://github.com/benaskins/lamina-mono) — a personal compute cluster managed with `lamina` (workspace CLI) and `aurelia` (process supervisor).

## Stack

- **Languages:** Go, Swift (MLX), TypeScript (SvelteKit)
- **Task runner:** just
- **Containers:** OrbStack (not Docker Desktop or Colima)
- **AI:** Claude Code, Ollama
- **No Python** — deliberate choice for agentic development

## Conventions

- Take breaks every 45 minutes
- Conventional commits: `<type>: <description>`
- Secrets go in vault or keychain, never in dotfiles
