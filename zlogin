git_dirty() {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit (working directory clean)" ]] && echo "*" 
}

git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null)
  if [[ -n $ref ]]; then
    echo "(%{$fg_bold[green]%}${ref#refs/heads/}$(git_dirty)%{$reset_color%})"
  fi
}

# makes color constants available
autoload -U colors
colors

# enable colored output from ls, etc
export CLICOLOR=1

# expand functions in the prompt
setopt prompt_subst

# prompt
export PS1='[${SSH_CONNECTION+"%{$fg_bold[green]%}%n@%m":}%{$fg_bold[blue]%}%.%{$reset_color%}]$(git_prompt_info) '

export dev=~/Development
export cp=$dev/client_projects

# Quick links to client projects
for DIR in `ls $cp`
do
  export $DIR=$cp/$DIR
done

if [[ -s "$HOME/.rvm/scripts/rvm" ]]  ; then source "$HOME/.rvm/scripts/rvm" ; fi


### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
export PATH="./bin:$PATH"
