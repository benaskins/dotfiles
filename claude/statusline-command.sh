#!/usr/bin/env bash

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Directory segment — white on blue (mirrors precmd ^ line)
dir_segment=$(printf '\033[97;44m ^ %s \033[0m' "$cwd")

# Hostname segment — white on teal
host_segment=$(printf '\033[97;36m  %s \033[0m' "$(hostname -s)")

# Model segment — white on dark blue
model_segment=""
if [ -n "$model" ]; then
  model_segment=$(printf '\033[97;34m  %s \033[0m' "$model")
fi

# Context usage segment — white on dark grey, only when data is available
context_segment=""
if [ -n "$used_pct" ]; then
  context_segment=$(printf '\033[97;90m  ctx: %s%% \033[0m' "$used_pct")
fi

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
  branch_segment=$(printf '\033[97;45m  %s \033[0m' "$branch")
fi

# Time segment — white on dark cyan
time_segment=$(printf '\033[97;36m  %s \033[0m' "$(date +%H:%M:%S)")

# Build output: directory, hostname, then branch (mirrors shell layout), then model + context
output="$dir_segment  $host_segment  $time_segment"
if [ -n "$branch_segment" ]; then
  output="$output  $branch_segment"
fi
if [ -n "$model_segment" ]; then
  output="$output  $model_segment"
fi
if [ -n "$context_segment" ]; then
  output="$output$context_segment"
fi

printf '%b\n' "$output"
