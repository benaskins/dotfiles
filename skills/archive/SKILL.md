---
name: archive
description: Use when archiving repos or projects. Never delete. Move to ~/dev/archive/ and check for active consumers first.
---

# Archive

Never delete, always archive. Move to `~/dev/archive/` so things can be
recovered.

## 1. Check before you move

Run `check.sh` from this skill's own directory. The invocation names it as the
skill's base directory, so call it by absolute path:

```
<base directory>/check.sh ~/dev/REPO
```

It answers the two questions this skill used to ask in prose, and answers them
the same way every time:

- **What would be lost.** Uncommitted changes, branches with unpushed commits,
  branches that were never pushed at all, stashes, and a missing origin remote.
  Every branch, not only the current one: a clean `main` beside an unpushed
  branch is the loss worth catching.
- **Who names it.** Every file outside the repo that mentions its name, grouped
  by directory.

Pass a second argument to search somewhere other than the repo's parent.

## 2. Read the consumers

A name match is a candidate, not a dependency. The script says so and does not
decide for you. Open the hits that look like imports, submodules, deploy config
or documentation that a reader would follow.

## 3. Move it

```
mv ~/dev/REPO ~/dev/archive/REPO
```

To recover: `mv ~/dev/archive/REPO ~/dev/REPO`.

## 4. Show that nothing broke

Build, or run the tests, of anything the consumer list named. Report the output.
The move is cheap to undo, so undo it rather than patch around a break.

$ARGUMENTS
