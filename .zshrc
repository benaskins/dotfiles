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

# Docker environment management
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export BUILDKIT_PROGRESS=plain

# Function to start Colima with default settings
function colima-start() {
    colima start --cpu 4 --memory 8 --disk 100
}

# Function to stop Colima
function colima-stop() {
    colima stop
}

# Function to show Docker container status
function docker-status() {
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
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
