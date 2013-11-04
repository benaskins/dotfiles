# completion
autoload -U compinit
compinit

# automatically enter directories without cd
setopt auto_cd

# use vim a9s an editor
export EDITOR='mvim -f -c "au VimLeave * !open -a Terminal"'

# aliases
if [ -e "$HOME/.aliases" ]; then
  source "$HOME/.aliases"
fi

# vi mode
bindkey -v

# use incremental search
bindkey ^R history-incremental-search-backward

# expand functions in the prompt
setopt prompt_subst

# prompt
export PS1='%n@m %c'

# ignore duplicate history entries
setopt histignoredups

# keep more history
export HISTSIZE=200

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
