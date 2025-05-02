# ~/.zshrc — Lamina shell config (iSH-style prompt)

# Homebrew path
eval "$(/opt/homebrew/bin/brew shellenv)"

# PATH
export PATH="$HOME/dev/aurelia/lamina/bin:$PATH"
export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"

autoload -Uz vcs_info

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
