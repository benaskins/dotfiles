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
      echo "  --link-only    Only link dotfiles, skip brew/python setup"
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

echo "🔗 Linking dotfiles into ~/"
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Determine which files to link
if [[ ${#CUSTOM_FILES[@]} -gt 0 ]]; then
  FILES=("${CUSTOM_FILES[@]}")
  echo "📝 Linking custom files: ${FILES[*]}"
elif [[ "$MINIMAL" == true ]]; then
  FILES=(".tmux.conf" ".vimrc")
  echo "📝 Minimal setup: linking vim and tmux configs only"
else
  FILES=(".zshrc" ".aliases" ".git_aliases" ".tmux.conf" ".vimrc" ".python-version")
  echo "📝 Linking all dotfiles"
fi

# Create common directories (only if not minimal)
if [[ "$MINIMAL" == false ]]; then
  echo "📁 Creating common directories..."
  mkdir -p ~/dev
  mkdir -p ~/Downloads
  mkdir -p ~/.local/bin
  mkdir -p ~/.cache/zsh
fi

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

# Skip Homebrew and Python setup if --link-only or --minimal is specified
if [[ "$LINK_ONLY" == false && "$MINIMAL" == false ]]; then
  # Install Homebrew if not present
  if ! command -v brew &> /dev/null; then
      echo "🍺 Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      
      # Add Homebrew to PATH based on architecture
      if [[ $(uname -m) == 'arm64' ]]; then
          echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
          eval "$(/opt/homebrew/bin/brew shellenv)"
      else
          echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
          eval "$(/usr/local/bin/brew shellenv)"
      fi
  fi

  # Verify Homebrew installation
  if ! command -v brew &> /dev/null; then
      echo "❌ Homebrew installation failed. Please install it manually and run this script again."
      exit 1
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
else
  echo "✅ Done. Dotfiles linked successfully."
fi
