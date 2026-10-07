#!/usr/bin/env bash
# Find earlier Claude Code sessions whose title matches each window name.
# Usage: find-sessions.sh [-d days] <name>...
# Prints: <name> <mtime> <cwd> <size> <transcript path>, newest first, at most 3 per name.
set -euo pipefail

days=14
if [[ "${1:-}" == "-d" ]]; then
  days="$2"
  shift 2
fi
[[ $# -gt 0 ]] || { echo "usage: find-sessions.sh [-d days] <name>..." >&2; exit 2; }

projects="$HOME/.claude/projects"

# GNU stat (Linux, WSL) accepts --version; BSD stat (macOS) does not.
if stat --version >/dev/null 2>&1; then
  mtime() { date -d "@$(stat -c %Y "$1")" "+%Y-%m-%d %H:%M"; }
  size() { stat -c %s "$1"; }
else
  mtime() { stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$1"; }
  size() { stat -f %z "$1"; }
fi
lower() { printf "%s" "$1" | tr "[:upper:]" "[:lower:]"; }
transcripts=$(find "$projects" -maxdepth 2 -name '*.jsonl' -mtime "-${days}" 2>/dev/null)

for name in "$@"; do
  while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    # The last customTitle wins: a session can be renamed part-way through.
    title=$(grep -o '"customTitle":"[^"]*"' "$f" | tail -1 | cut -d'"' -f4 || true)
    [[ "$(lower "$title")" == "$(lower "$name")" ]] || continue
    cwd=$(grep -o '"cwd":"[^"]*"' "$f" | tail -1 | cut -d'"' -f4 || true)
    printf '%s\t%s\t%s\t%s\t%s\n' "$name" "$(mtime "$f")" "${cwd:-unknown}" "$(size "$f")" "$f"
  done <<< "$transcripts" | sort -t$'\t' -k2 -r | head -3
done
