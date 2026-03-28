#!/usr/bin/env bash

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Directory segment — host-specific color (mirrors precmd ^ line and tmux bar)
host=$(hostname -s)
case "$host" in
  hestia) host_color='\033[30;48;5;208m' ;;  # black on orange
  limen)  host_color='\033[97;48;5;30m' ;;   # white on cyan
  *)      host_color='\033[97;44m' ;;         # white on blue (fallback)
esac
dir_segment=$(printf "${host_color} %s \033[0m\033[97;44m %s \033[0m" "$host" "$cwd")

# Git branch from the input (worktree or fallback to git)
branch=""
worktree_branch=$(echo "$input" | jq -r '.worktree.branch // empty')
if [ -n "$worktree_branch" ]; then
  branch="$worktree_branch"
else
  branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

branch_segment=""
if [ -n "$branch" ]; then
  branch_segment=$(printf ' \033[97;45m %s \033[0m' "$branch")
fi

# Model segment — white on dark blue
model_segment=""
if [ -n "$model" ]; then
  model_segment=$(printf ' \033[97;34m %s \033[0m' "$model")
fi

# Context usage segment — white on dark grey
context_segment=""
if [ -n "$used_pct" ]; then
  context_segment=$(printf ' \033[97;90m ctx: %s%% \033[0m' "$used_pct")
fi

# Time segment — white on dark cyan
time_str=$(date +%H:%M:%S)
time_segment=$(printf '\033[97;36m %s \033[0m' "$time_str")

# Build left side
left="${dir_segment}${branch_segment}${model_segment}${context_segment}"

# Calculate visible length of left side (strip ANSI escapes)
left_visible=$(printf '%b' "$left" | sed 's/\x1b\[[0-9;]*m//g')
left_len=${#left_visible}
time_len=$((${#time_str} + 2))  # +2 for padding spaces

# Pad to push time to right edge
cols=$(tput cols 2>/dev/null || echo 120)
pad=$((cols - left_len - time_len))
if [ "$pad" -lt 1 ]; then
  pad=1
fi

printf '%b%*s%b\n' "$left" "$pad" "" "$time_segment"
