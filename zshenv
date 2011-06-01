# source local environment if available
if [ -e "$HOME/.zshenv.local" ]; then
  source "$HOME/.zshenv.local"
fi

export PATH=/usr/local/share/npm/bin:~/bin:/usr/local/bin:$PATH
export NODE_PATH=/usr/local/lib/node
