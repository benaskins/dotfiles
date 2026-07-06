#!/usr/bin/env bash
set -euo pipefail

# brew-maintenance.sh — keep Homebrew and the dev toolchain fresh.
#
# Idempotent and safe to run on a schedule (e.g. weekly). Runs the full
# Homebrew hygiene cycle: refresh definitions, sync against the Brewfile,
# upgrade everything, run the doctor, prune unused deps and stale versions,
# then report any installed formulae that drifted from the Brewfile.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREWFILE="${REPO_DIR}/Brewfile"

section() {
  printf '\n\033[1;34m==> %s\033[0m\n' "$1"
}

if ! command -v brew >/dev/null 2>&1; then
  echo "error: Homebrew not found on PATH" >&2
  exit 1
fi

section "brew update — refreshing formula definitions"
brew update

if [[ -f "${BREWFILE}" ]]; then
  section "brew bundle — installing anything declared but missing"
  brew bundle --file "${BREWFILE}"
else
  echo "warning: no Brewfile at ${BREWFILE}; skipping bundle" >&2
fi

section "brew upgrade — upgrading installed formulae and casks"
brew upgrade

section "brew doctor — checking for problems"
# doctor exits non-zero when it finds issues; surface them without aborting.
brew doctor || echo "(brew doctor reported issues above — review them)"

section "brew autoremove — removing unused dependencies"
brew autoremove

section "brew cleanup — pruning stale versions and caches"
brew cleanup --prune=all

if [[ -x "${REPO_DIR}/scripts/brewfile-audit.sh" ]]; then
  section "brewfile drift — installed leaves not declared in Brewfile"
  drift="$(cd "${REPO_DIR}" && ./scripts/brewfile-audit.sh)"
  if [[ -n "${drift}" ]]; then
    echo "${drift}"
    echo "(consider adding these to the Brewfile, or 'brew uninstall' them)"
  else
    echo "none — Brewfile matches installed leaves"
  fi
fi

section "done — dev environment is fresh"
