---
name: load-branch-changes
description: Load current git branch changes (diff, commits, changed files) into session context. Use when the user invokes /load-branch-changes to review, understand, or focus on the current branch's changes compared to the base branch.
model: haiku
---

# Load Branch Changes

Load the current branch's changes into context and set them as the working focus for the session.

## Step 1: Detect Base Branch

```bash
BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
if [ -z "$BASE" ]; then
  BASE=$(git rev-parse --verify main 2>/dev/null && echo main || echo master)
fi
echo "$BASE"
```

## Step 2: Collect Branch Information

Run all three commands using the detected `$BASE`:

**Changed files:**
```bash
git diff --name-only $BASE...HEAD
```

**Commit history:**
```bash
git log $BASE..HEAD --pretty=format:"%h %s"
```

**Full diff with stats:**
```bash
git diff $BASE...HEAD --patch-with-stat
```

## Step 3: Present Results

Display output in three labeled sections:

1. **Changed Files** — file list
2. **Commits** — commit log
3. **Diff** — full patch with stats

If no changes found, report that the branch has no changes relative to the base branch and stop.

## Step 4: Set Session Context

After presenting the results, treat these branch changes as the primary working context for the rest of the session. When the user references "the changes", "the diff", "these files", or similar — they mean the branch changes loaded here. Prioritize changed files and diff when answering questions, suggesting reviews, or proposing edits.
