# ~/.zshrc — Lamina shell config (iSH-style prompt)

# Homebrew path
eval "$(/opt/homebrew/bin/brew shellenv)"

# PATH
export PATH="$HOME/dev/aurelia/lamina/bin:$PATH"
export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"

# Python environment management
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Function to create and activate a new virtual environment
function mkvenv() {
    python -m venv .venv
    source .venv/bin/activate
}

# Function to activate existing virtual environment
function activate() {
    if [ -d ".venv" ]; then
        source .venv/bin/activate
    else
        echo "No .venv directory found"
    fi
}

# Function to deactivate virtual environment
function deactivate() {
    if [ -n "$VIRTUAL_ENV" ]; then
        command deactivate
    else
        echo "No virtual environment active"
    fi
}

# Shell improvements
autoload -Uz vcs_info
autoload -Uz compinit && compinit
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR

precmd() {
  vcs_info
  echo "\033[97;44m ^ $(pwd) \033[0m"
  if [[ -n ${vcs_info_msg_0_} ]]; then
    echo "\033[97;45m ⋯ ${vcs_info_msg_0_} \033[0m"
  fi
}

zstyle ':vcs_info:git:*' formats ' %b'
setopt prompt_subst
PROMPT=" v "

# Load modular config
[ -f ~/.aliases ] && source ~/.aliases
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
[ -f ~/.git_aliases ] && source ~/.git_aliases
