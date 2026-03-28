# ~/.bashrc

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

# Go
export GOPRIVATE="github.com/benaskins/*"

# Aurelia
export AURELIA_ROOT="$HOME/dev/hestia-core-infrastructure"
export SUDO_ASKPASS="$HOME/.local/bin/sudo-askpass"

# Prompt
__prompt_command() {
  local host
  host=$(hostname -s)
  local host_bg
  case "$host" in
    hestia) host_bg="\033[97;48;5;208m" ;;
    limen)  host_bg="\033[97;48;5;30m" ;;
    *)      host_bg="\033[97;44m" ;;
  esac
  echo -e "${host_bg} ^ ${host} $(pwd) \033[0m"
  local branch
  branch=$(git branch --show-current 2>/dev/null)
  if [ -n "$branch" ]; then
    echo -e "\033[97;45m ⋯ ${branch} \033[0m"
  fi
}
PROMPT_COMMAND=__prompt_command
PS1=" v "

# Completion
if [ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]; then
  . "/opt/homebrew/etc/profile.d/bash_completion.sh"
fi

# SSH agent
if [ -z "$SSH_AUTH_SOCK" ] || [ ! -S "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" > /dev/null
fi
ssh-add -l &>/dev/null || ssh-add --apple-load-keychain 2>/dev/null

# Modular config
[ -f ~/.aliases ] && . ~/.aliases
[ -f ~/.bashrc.local ] && . ~/.bashrc.local
