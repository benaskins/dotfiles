#!/bin/bash

set -e
echo "🔗 Linking dotfiles into ~/"
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

FILES=(".zshrc" ".aliases" ".git_aliases" ".tmux.conf" ".vimrc")

for file in "${FILES[@]}"; do
  TARGET="$HOME/$file"
  SOURCE="$DOTFILES_DIR/$file"
  if [ -e "$TARGET" ]; then
    echo "⚠️  Skipping $file (already exists)"
  else
    echo "🔗 Linking $file"
    ln -s "$SOURCE" "$TARGET"
  fi
done

echo "✅ Done. Reload with: source ~/.zshrc"
