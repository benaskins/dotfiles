#!/usr/bin/env bash
# Report what an archive would lose, before anything moves.
#
# Read-only. It moves nothing and deletes nothing: the point is to answer the two
# questions the skill used to ask in prose, so the decision to archive is taken
# against facts rather than a recollection.
#
# Usage: check.sh <path-to-repo> [search-root]
#   search-root defaults to the parent of <path-to-repo>, which is normally ~/dev
set -euo pipefail

target="${1:?usage: check.sh <path-to-repo> [search-root]}"
[[ -d "$target" ]] || { echo "no such directory: $target" >&2; exit 1; }
target="$(cd "$target" && pwd)"
name="$(basename "$target")"
search_root="${2:-$(dirname "$target")}"
[[ -d "$search_root" ]] || { echo "no such search root: $search_root" >&2; exit 1; }

echo "== TARGET"
printf '%-12s %s\n' "name" "$name"
printf '%-12s %s\n' "path" "$target"

# --- unsaved work -----------------------------------------------------------

echo
echo "== UNSAVED WORK"
blockers=0

if ! git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not a git repository. Everything here exists only on this disk."
    blockers=$((blockers + 1))
else
    dirty="$(git -C "$target" status --porcelain 2>/dev/null || true)"
    if [[ -n "$dirty" ]]; then
        echo "Uncommitted changes ($(printf '%s\n' "$dirty" | grep -c .) path(s)):"
        printf '%s\n' "$dirty" | head -20
        blockers=$((blockers + 1))
    else
        echo "Working tree clean."
    fi

    # Every branch, not just the current one. Archiving on a clean main while an
    # unpushed branch sits beside it is the loss this check exists to prevent.
    unpushed="$(git -C "$target" for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads \
                | grep -v ' \[gone\]$' | grep '\[ahead' || true)"
    noupstream="$(git -C "$target" for-each-ref --format='%(refname:short) %(upstream)' refs/heads \
                | awk 'NF == 1 { print $1 }' || true)"
    if [[ -n "$unpushed" ]]; then
        echo "Branches with unpushed commits:"
        printf '%s\n' "$unpushed" | sed 's/^/  /'
        blockers=$((blockers + 1))
    fi
    if [[ -n "$noupstream" ]]; then
        echo "Branches that were never pushed:"
        printf '%s\n' "$noupstream" | sed 's/^/  /'
        blockers=$((blockers + 1))
    fi
    if [[ -z "$unpushed" && -z "$noupstream" ]]; then
        echo "Every branch is on a remote."
    fi

    stashes="$(git -C "$target" stash list 2>/dev/null | grep -c . || true)"
    if [[ "$stashes" -gt 0 ]]; then
        echo "$stashes stash entr(ies). A stash is invisible after a move."
        blockers=$((blockers + 1))
    fi

    if ! git -C "$target" remote get-url origin >/dev/null 2>&1; then
        echo "No origin remote. Nothing here is anywhere else."
        blockers=$((blockers + 1))
    fi
fi

# --- consumers ---------------------------------------------------------------

echo
echo "== CONSUMERS"
echo "searching $search_root for references to '$name'"
echo

# A hit is a candidate to read, not proof of a dependency. The repo's own
# directory is excluded, since a repo naming itself proves nothing.
#
# ripgrep when it is here: it honours .gitignore, so build output and vendored
# dependencies drop out without an exclude list, and a sweep of a large ~/dev went
# from 46s to under 2s. grep is the fallback and needs the exclusions spelled out.
if command -v rg >/dev/null 2>&1; then
    hits="$(rg --files-with-matches --fixed-strings --no-messages \
            --glob '!.git' --glob '!archive' \
            -- "$name" "$search_root" 2>/dev/null | grep -v "^$target/" || true)"
else
    hits="$(grep -rIl --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=vendor \
            --exclude-dir=target --exclude-dir=dist --exclude-dir=archive \
            -- "$name" "$search_root" 2>/dev/null | grep -v "^$target/" || true)"
fi

if [[ -z "$hits" ]]; then
    echo "No file outside the repo names it."
else
    # Grouped by the directory holding the hit, because "12 files in one place"
    # and "12 places" are different answers.
    dirs="$(printf '%s\n' "$hits" | sed -E "s|^${search_root}/||; s|/.*$||")"
    printf '%s\n' "$dirs" | sort | uniq -c | sort -rn | head -15 \
        | awk '{ printf "  %-40s %s file(s)\n", $2, $1 }'
    ndirs="$(printf '%s\n' "$dirs" | sort -u | grep -c .)"
    total="$(printf '%s\n' "$hits" | grep -c .)"
    echo
    echo "$total file(s) across $ndirs director(ies), shown by directory rather"
    echo "than by repo: a worktree of a repo that references the target is listed"
    echo "beside its main checkout, so the count of distinct repos is smaller."
fi

# --- verdict ------------------------------------------------------------------

echo
echo "== VERDICT"
if [[ "$blockers" -eq 0 ]]; then
    echo "Nothing unsaved. Whether the consumers above matter is still a judgement."
else
    echo "$blockers reason(s) not to move this yet, listed above."
    echo "An archive is a move, so this is recoverable, but the point of the check"
    echo "is to not have to recover."
fi
