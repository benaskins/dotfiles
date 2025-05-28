# Dotfiles

My personal dotfiles for macOS development setup.

## Features

- Python development environment with pyenv
- Modern shell configuration with zsh
- Git configuration and aliases
- Development tools and utilities
- VS Code and Neovim editor setup

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Run the setup script:
   ```bash
   ./setup.sh
   ```

3. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

## Python Development

This setup uses pyenv for Python version management and virtual environments. Key features:

- Python 3.12.0 as the default version
- Virtual environment management with pyenv-virtualenv
- Poetry for dependency management
- Black for code formatting
- Flake8 for linting
- MyPy for type checking

### Common Python Commands

```bash
# Create a new virtual environment
mkvenv

# Activate existing virtual environment
activate

# Deactivate virtual environment
deactivate

# Upgrade all pip packages
pip-upgrade
```

## Shell Features

- Custom prompt with git integration
- Improved tab completion
- Directory navigation with zoxide
- Fuzzy finding with fzf
- Better directory listing with exa

## Included Tools

- Git with delta for better diffs
- Neovim for text editing
- VS Code for development
- Raycast for quick access
- Rectangle for window management
- Arc browser

## Maintenance

To update all packages:
```bash
brew update && brew upgrade
```

To update Python packages:
```bash
pip-upgrade
```

## License

MIT 