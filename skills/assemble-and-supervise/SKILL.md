---
name: assemble-and-supervise
description: Open a team of named Claude Code sessions in tmux windows, brief each one from the earlier session with the same name, and supervise them from this window. Use when Ben lists the windows he wants for the day.
---

# Assemble and supervise

This session becomes the supervisor. It opens one tmux window for each name
Ben gives. It starts Claude in each window with a brief built from the earlier
session that had the same name. Then it stays in its own window and watches
the team.

## Usage

```
/assemble-and-supervise triage release-manager incident design intake
```

If Ben gives no names, ask for them. If a name occurs two times, ask if he
wants two windows or a different name. Use one window for each name.

## Steps

### 1. Prepare the supervisor

1. If the repo has a `just whereami` recipe, run it and tell Ben the result.
   Otherwise run `git status` and `git worktree list`.
2. Rename this window. Do not let tmux rename it automatically:
   ```sh
   tmux set-option -w -t "$TMUX_PANE" automatic-rename off
   tmux rename-window -t "$TMUX_PANE" supervisor
   ```
   Tell Ben to run `/rename supervisor`. The Skill tool cannot run this
   command.
3. Do the checks that the SessionStart hooks ask for, for example token
   refreshes.

### 2. Find the earlier sessions

```sh
<skill-dir>/find-sessions.sh -d 14 <name>...
```

The script reads `~/.claude/projects`. For each name, it shows the three most
recent sessions with that title (it ignores case). It shows the date, the
working directory, the size and the transcript path.

- "Yesterday's" session is the most recent one that has content. Ignore a
  session that started in the last few minutes, because it is probably from
  this assembly.
- If a name has no match, look for a near match (for example `quick-fixes`
  for `quick-questions`, or `charter` for `requirements`). Tell Ben which
  session you used.
- If no session matches, the brief comes from the name only.

Show Ben the mapping as a table before you continue.

### 3. Write the briefs

Transcripts are large (up to 5 MB). Do not read them in this session. Send
one general-purpose agent to write all the briefs. Write them to
`~/.claude/briefs/<YYYY-MM-DD>/<name>.md`. Tell the agent to:

1. Use `jq` or `grep` to get the user messages and the assistant text from
   each transcript. Give the most weight to the last 30% of the session.
2. Make sure that each PR and issue is still open on GitHub. Write the
   status that is true today.
3. Keep each brief to about 40 lines, with these sections:
   - **Role:** one or two sentences.
   - **Working directory:** from the `cwd` field. If the work is in a
     different repo, use that repo.
   - **Open threads:** a numbered list. Give full PR URLs, issue numbers,
     branches, blockers and the person who blocks each one.
   - **Next actions:** as the earlier session left them.
   - **Standing rules:** do branch work in a worktree
     (`just worktree-add <slug>` if the repo has it, else `git worktree add`),
     because the main checkout is shared. Obey the repo's `AGENTS.md`. Do not merge, approve or publish.
     Tell the supervisor window when you are blocked.
4. Write "unclear" when a fact is not certain. Do not invent facts.
5. Report one line for each window and its working directory.

### 4. Open the windows

```sh
<skill-dir>/launch-windows.sh ~/.claude/briefs/<YYYY-MM-DD> <name>:<dir>...
```

The script opens each window in the background, so focus stays on the
supervisor. It turns off automatic rename and starts `claude -n <name>` with
an opening prompt. The prompt tells the session to read its brief, check its
state and give Ben a numbered status. Set `MODEL=opus` to choose a model.
The default is the account default. The script does not open a window when
it finds no brief or when a window with that name exists.

Each session's SessionStart hook opens its workbench and viewer panes. The
panes open in the session's own window only when the hook targets
`$TMUX_PANE` (benaskins/dotfiles#7). With an older hook, all the panes open in
the supervisor window. If this occurs, tell Ben to update his dotfiles.

### 5. Make sure that they started

Wait about 20 seconds. Then read the end of each pane:

```sh
tmux capture-pane -t "<session>:<name>" -p | grep -v '^\s*$' | tail -4
```

Each pane must show the Claude prompt and status line. If a window shows a
shell error, tell Ben.

### 6. Report

Give Ben a table with these columns: window number, name, working directory,
and the open threads that it carries. Tell him which model the sessions use,
and where the briefs are.

## Supervise

After the assembly, this window coordinates the team:

- **Roll-up on request.** Capture each pane and summarise. Put the items that
  are blocked on Ben first, and number the list.
- **Routing.** When a session asks for work that belongs to a different
  window, send it there:
  `tmux send-keys -t "<session>:<name>" "<message>" Enter`.
- **Escalation.** If a session reports that main is red, that a deploy is
  stuck or that there is a production problem, tell Ben immediately.
- Do not do the sessions' work in this window. Keep this context free for
  coordination.
