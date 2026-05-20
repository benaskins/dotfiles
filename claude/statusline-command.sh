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

# Rate limit segments — between model and context
five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_h_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Format reset time as shorthand (e.g. "3pm", "11am")
format_reset() {
  local epoch="$1"
  [ -z "$epoch" ] && return
  # resets_at is unix epoch in seconds
  date -r "$epoch" '+%-I%p' 2>/dev/null | tr '[:upper:]' '[:lower:]'
}

rate_segment=""
if [ -n "$five_h" ] || [ -n "$seven_d" ]; then
  parts=""
  if [ -n "$five_h" ]; then
    reset_str=$(format_reset "$five_h_resets")
    parts="5h: $(printf '%.0f' "$five_h")%"
    [ -n "$reset_str" ] && parts="${parts} @${reset_str}"
  fi
  [ -n "$seven_d" ] && parts="${parts:+$parts }7d: $(printf '%.0f' "$seven_d")%"
  rate_segment=$(printf ' \033[97;35m %s \033[0m' "$parts")
fi

# Factory workers segment — detect running maestro/toolmaker/luthier processes
workers=""
while IFS= read -r line; do
  [ -z "$line" ] && continue
  role="${line%%:*}"
  pcwd="${line#*:}"
  name=$(basename "$pcwd" | sed 's/-[0-9]\{8\}-[0-9]\{6\}$//')
  workers="${workers:+$workers, }${name} [${role}]"
done < <(ps -eo pid,comm 2>/dev/null | awk '/[m]aestro|[t]oolmaker|[l]uthier/{print $1, $2}' | while read pid comm; do
  cwd=$(lsof -d cwd -a -p "$pid" -Fn 2>/dev/null | grep '^n/' | cut -c2-)
  [ -n "$cwd" ] && echo "${comm}:${cwd}"
done)

factory_segment=""
if [ -n "$workers" ]; then
  factory_segment=$(printf ' \033[30;48;5;220m %s \033[0m' "$workers")
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
left="${dir_segment}${branch_segment}${model_segment}${rate_segment}${factory_segment}${context_segment}"

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
