# ~/.zshrc

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# PATH
export PATH="$HOME/.local/bin:$HOME/dev/dotfiles/scripts:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"

# Claude Code
export CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false

# Docker (OrbStack)
export DOCKER_BUILDKIT=1

# Shell
autoload -Uz vcs_info
autoload -Uz compinit && compinit
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR

precmd() {
  vcs_info
  echo "\033[97;44m ^ $(hostname -s) $(pwd) \033[0m"
  if [[ -n ${vcs_info_msg_0_} ]]; then
    echo "\033[97;45m ⋯ ${vcs_info_msg_0_} \033[0m"
  fi
}

zstyle ':vcs_info:git:*' formats ' %b'
setopt prompt_subst
PROMPT=" v "

# SSH agent
if [ -z "$SSH_AUTH_SOCK" ] || [ ! -S "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" > /dev/null
fi
ssh-add -l &>/dev/null || ssh-add --apple-load-keychain 2>/dev/null

# Modular config
[ -f ~/.aliases ] && source ~/.aliases
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

fpath+=~/.zfunc
export PATH="$HOME/.local/bin:$PATH"
