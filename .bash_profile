# ~/.bash_profile — login shells source this, then .bashrc
[ -f ~/.bashrc ] && . ~/.bashrc

# Rust
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# OrbStack
source ~/.orbstack/shell/init.bash 2>/dev/null || :
