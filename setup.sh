#!/bin/bash

set -e

# Parse command line arguments
LINK_ONLY=false
MINIMAL=false
CUSTOM_FILES=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --link-only)
      LINK_ONLY=true
      shift
      ;;
    --minimal)
      MINIMAL=true
      shift
      ;;
    --files)
      shift
      while [[ $# -gt 0 && ! $1 =~ ^-- ]]; do
        CUSTOM_FILES+=("$1")
        shift
      done
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --link-only    Only link dotfiles, skip brew setup"
      echo "  --minimal      Link only .vimrc and .tmux.conf"
      echo "  --files FILE.. Link specific files only"
      echo "  -h, --help     Show this help"
      echo ""
      echo "Examples:"
      echo "  $0                               # Full setup"
      echo "  $0 --minimal                     # Link vim and tmux configs only"
      echo "  $0 --files .vimrc .tmux.conf     # Link specific files"
      echo "  $0 --link-only                   # Link all dotfiles but skip installs"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Determine which files to link
if [[ ${#CUSTOM_FILES[@]} -gt 0 ]]; then
  FILES=("${CUSTOM_FILES[@]}")
elif [[ "$MINIMAL" == true ]]; then
  FILES=(".tmux.conf" ".vimrc")
else
  FILES=(".zshenv" ".zshrc" ".aliases" ".git_aliases" ".tmux.conf" ".vimrc")
fi

echo "Linking dotfiles..."

# Create common directories (only if not minimal)
if [[ "$MINIMAL" == false ]]; then
  mkdir -p ~/dev
  mkdir -p ~/.local/bin
  mkdir -p ~/.cache/zsh

  # Link scripts into ~/.local/bin
  for script in "$DOTFILES_DIR"/scripts/*; do
    name="$(basename "$script")"
    target="$HOME/.local/bin/$name"
    if [ ! -e "$target" ]; then
      ln -s "$script" "$target"
      echo "  $name -> ~/.local/bin/"
    fi
  done

  # Link Claude Code config
  if [ -d "$DOTFILES_DIR/claude" ]; then
    mkdir -p "$HOME/.claude"
    for cfg in "$DOTFILES_DIR"/claude/*; do
      name="$(basename "$cfg")"
      target="$HOME/.claude/$name"
      if [ ! -e "$target" ]; then
        ln -s "$cfg" "$target"
        echo "  $name -> ~/.claude/"
      fi
    done
  fi
fi

for file in "${FILES[@]}"; do
  TARGET="$HOME/$file"
  SOURCE="$DOTFILES_DIR/$file"
  if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
    echo "  skip $file (exists)"
  else
    ln -s "$SOURCE" "$TARGET"
    echo "  link $file"
  fi
done

# Install Homebrew and packages if full setup
if [[ "$LINK_ONLY" == false && "$MINIMAL" == false ]]; then
  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  echo "Installing packages..."
  brew bundle

  # Set Go environment
  go env -w GOPRIVATE="github.com/benaskins/*"

  echo "Done. Reload with: source ~/.zshrc"
else
  echo "Done."
fi
