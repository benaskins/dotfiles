---
name: archive
description: Use when archiving repos or projects. Never delete — move to ~/dev/archive/ and verify no active consumers.
---

# Archive

Never delete, always archive. Move to `~/dev/archive/` so things can be recovered.

1. Check for consumers — other repos or services that depend on this one
2. Check for uncommitted work and unpushed commits
3. `mv ~/dev/REPO ~/dev/archive/REPO`
4. `/verify` nothing broke — test builds, check dependency graphs

To recover: `mv ~/dev/archive/REPO ~/dev/REPO`

$ARGUMENTS
