#!/bin/bash

set -e
echo "🔗 Linking dotfiles into ~/"
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Create common directories
echo "📁 Creating common directories..."
mkdir -p ~/dev
mkdir -p ~/Downloads
mkdir -p ~/.local/bin
mkdir -p ~/.cache/zsh

# Link dotfiles
FILES=(".zshrc" ".aliases" ".git_aliases" ".tmux.conf" ".vimrc" ".python-version")

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

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install packages from Brewfile
echo "📦 Installing packages from Brewfile..."
brew bundle

# Setup Python environment
echo "🐍 Setting up Python environment..."
pyenv install 3.12.0
pyenv global 3.12.0
pyenv rehash

# Install Python tools
echo "🔧 Installing Python tools..."
pipx install black
pipx install flake8
pipx install mypy
pipx install poetry

# Create Python configuration files
echo "📝 Creating Python configuration files..."
cat > ~/.flake8 << EOL
[flake8]
max-line-length = 88
extend-ignore = E203
exclude = .git,__pycache__,build,dist
EOL

cat > ~/.mypy.ini << EOL
[mypy]
python_version = 3.12
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True
EOL

echo "✅ Done. Reload with: source ~/.zshrc"
