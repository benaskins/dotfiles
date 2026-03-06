# dotfiles

Development environment for macOS on Apple Silicon. Optimised for working on [lamina](https://github.com/benaskins/lamina-mono).

## Setup

```bash
git clone https://github.com/benaskins/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
./setup.sh
```

This links dotfiles into `~`, links scripts into `~/.local/bin`, installs Homebrew, and runs `brew bundle`.

### Options

```bash
./setup.sh --link-only              # Link dotfiles, skip brew
./setup.sh --minimal                # Just .vimrc and .tmux.conf
./setup.sh --files .zshrc .aliases  # Specific files only
```

## What's in the box

| File | Purpose |
|------|---------|
| `.zshenv` | `AURELIA_ROOT`, `GOPRIVATE` |
| `.zshrc` | PATH, prompt, SSH agent, modular config loading |
| `.aliases` | Git, navigation, lamina, aurelia, docker shortcuts |
| `.git_aliases` | Branch naming helper |
| `.tmux.conf` | vi mode, C-a prefix |
| `.vimrc` | Tabs, search, clipboard, window nav |
| `Brewfile` | Go, just, neovim, OrbStack, ripgrep, and friends |

## Scripts

| Script | Purpose |
|--------|---------|
| `slop-guard` | Catch AI-generated filler words in source files |
| `spawn` | Open a lamina sub-repo in a tmux window with Claude Code |
| `tmux-default` | Create or attach to a default 4-pane tmux session |
| `brewfile-audit.sh` | Show installed formulae not declared in Brewfile |
