---
name: reset-permissions
description: Reset accumulated permissions in .claude/settings.local.json. Use when the user says "/reset-permissions" or asks to clear, reset, or clean up Claude Code permissions. Supports full reset (default) or selective reset keeping read-only permissions (--keep-read).
model: haiku
---

# Reset Permissions

Clear accumulated `permissions.allow` entries from `.claude/settings.local.json` in the current project.

## Modes

- **No arguments** — full reset, clear all permissions
- **`--keep-read`** — remove only write/action permissions, keep read-only

## Step 1: Read Current Settings

```bash
cat .claude/settings.local.json
```

If the file doesn't exist or has no `permissions.allow` entries, report that there are no permissions to reset and stop.

## Step 2: Classify Permissions

For `--keep-read` mode, classify each permission in the `allow` array:

**Read-only (KEEP):**
- `WebFetch(*)`, `WebSearch`
- `Read(*)`, `Glob(*)`, `Grep(*)`
- Bash with read commands: `find`, `ls`, `cat`, `head`, `tail`, `tree`, `diff`, `grep`, `rg`, `wc`, `file`, `stat`, `du`, `df`, `which`, `type`, `env`, `printenv`, `echo`
- Bash with git read commands: `git status`, `git log`, `git diff`, `git show`, `git branch`, `git tag`, `git remote`, `git blame`, `git ls-files`, `git ls-tree`, `git describe`, `git rev-parse`, `git shortlog`, `git reflog`, `git stash list`
- Commands ending with `--list`, `--help`, `--version`

**Write/action (REMOVE):**
- Everything else: `Bash(mkdir:*)`, `Bash(chmod:*)`, `Bash(rm:*)`, `Bash(git add:*)`, `Bash(git commit:*)`, `Bash(git push:*)`, `Bash(git:*)` (blanket git), `Edit(*)`, `Write(*)`, install/build scripts, etc.

## Step 3: Apply Changes

Use the Edit tool to update `.claude/settings.local.json`:

- **Full reset**: replace the `allow` array contents with `[]`
- **`--keep-read`**: replace the `allow` array with only the read-only entries

Preserve all other fields in the file (`deny`, `enabledPlugins`, etc.) unchanged.

## Step 4: Report Results

Show the user:
1. How many permissions were removed (list them with `-` prefix)
2. For `--keep-read`: how many were kept (list them with `+` prefix)
3. Confirm the file was updated
