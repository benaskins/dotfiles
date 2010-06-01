export PATH=~/bin:$PATH

# source local environment if available
if [ -e "$HOME/.zshenv.local" ]; then
  source "$HOME/.zshenv.local"
fi
