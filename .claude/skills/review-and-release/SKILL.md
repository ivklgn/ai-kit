---
name: review-and-release
description: Sync README with current agents/skills, validate plugin conventions, sync the Codex plugin directory (plugins/ai-kit), bump version, and commit. Use when the user says "/review-and-release" or wants to prepare a release after adding, removing, or changing agents or skills.
model: sonnet
---

# Review and Release

Synchronize README.md with the current set of agents and skills, validate files follow plugin conventions, sync the Codex plugin directory, bump the patch version in both plugin manifests, and create a release commit.

## Step 1: Inventory Agents and Skills

Scan the filesystem to build the current state.

**Agents:**
```bash
ls agents/*.md
```

For each `.md` file, read the YAML frontmatter and extract `name` and `description`. Condense each description into a short README-style summary (under ~90 characters), matching the style of existing entries.

**Skills:**
```bash
ls skills/*/SKILL.md
```

For each `SKILL.md`, read the YAML frontmatter and extract `name` and `description`. Condense each description into a short README-style summary.

Store both inventories for use in subsequent steps.

## Step 2: Diff Against README

Read `README.md` and parse its three inline lists (backtick-separated names, alphabetical):

1. **`## Agents`** — `` `name` · `name` · … ``
2. **`## Skills`** — same format
3. **`## Commands`** — `` `/ai-kit:name` · … `` (one entry per `commands/*.md` file)

Compare the filesystem inventory against README and classify:

- **Added** — in filesystem but not in the README list
- **Removed** — in the README list but not in filesystem
- **Unchanged** — matches

If zero differences across agents and skills, report "README is already in sync" and skip to Step 3.

## Step 3: Validate Plugin Conventions

Check all agent and skill files against these rules:

### Agent files (`agents/*.md`)

1. Frontmatter present — starts with `---` and has closing `---`
2. Required fields — `name`, `description`, `tools`, `model` all present
3. Name matches filename — `name` field equals filename without `.md`
4. Model value — one of: `haiku`, `sonnet`, `opus`, `inherit`
5. Description is non-empty
6. Meaningful markdown body after frontmatter

### Codex agent manifests (`agents/*.toml`)

Codex discovers subagents from `.toml` files, so every Claude Code agent must have a matching Codex manifest.

1. Pairing — every `agents/*.md` has a sibling `agents/*.toml` (same basename), and every `agents/*.toml` has a sibling `agents/*.md`. Report any unpaired file.
2. Valid TOML — parses without error.
3. Required fields — `name`, `description`, `sandbox_mode`, `developer_instructions` all present and non-empty.
4. Name matches — `name` equals the filename without `.toml` and equals the `name` in the paired `.md`.
5. `sandbox_mode` value — one of: `read-only`, `workspace-write`. Use `read-only` when the paired `.md` `tools` contain no `Write`/`Edit`/`Bash`, otherwise `workspace-write`.
6. `developer_instructions` matches the paired `.md` markdown body (the prompt after frontmatter).

### Skill files (`skills/*/SKILL.md`)

1. Frontmatter present — starts with `---` and has closing `---`
2. Required fields — `name` and `description` present. Either `model` or `disable-model-invocation: true` must exist.
3. Name matches directory — `name` field equals parent directory name
4. Model value (if present) — one of: `haiku`, `sonnet`, `opus`
5. Description is non-empty
6. Meaningful markdown body after frontmatter

### Plugin manifests

Validate both `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json`:

1. Valid JSON
2. Required fields — `name`, `description`, `version` present
3. Version matches semver `X.Y.Z`
4. Both manifests have the same `version` value

### Codex interface

Validate `agents/openai.yaml`:

1. File exists
2. `interface.display_name` is present and non-empty

If any issues found, present them as a numbered list with file paths and **stop**. Do not proceed until issues are fixed.

## Step 4: Apply README Updates

If Step 2 found differences, update `README.md` using the Edit tool: rebuild each affected inline list (`## Agents`, `## Skills`, `## Commands`) sorted alphabetically, keeping the existing `` `name` · `name` `` format.

## Step 5: Bump Version

Increment the patch version (e.g., `2.0.4` → `2.0.5`) in **both** manifests so Claude Code and Codex stay aligned:

- `.claude-plugin/plugin.json`
- `.codex-plugin/plugin.json`

Use the Edit tool on each file.

## Step 6: Sync Codex Plugin Directory

The Codex marketplace manifest (`.agents/plugins/marketplace.json`) points at `plugins/ai-kit/`, not the repo root — Codex users get ONLY what is inside that directory. It must mirror the root on every release:

```bash
rsync -a --delete skills/ plugins/ai-kit/skills/
rsync -a --delete agents/ plugins/ai-kit/agents/
cp .codex-plugin/plugin.json plugins/ai-kit/.codex-plugin/plugin.json
```

Verify the sync:

```bash
diff -rq skills plugins/ai-kit/skills && diff -rq agents plugins/ai-kit/agents
```

Both diffs must be empty. Commands are intentionally not synced — the Codex plugin manifest declares only `skills` and `mcpServers`; `commands/` is Claude-only.

## Step 7: Present Summary

Before committing, show a clear summary:

```
## Release Summary

**Version:** X.Y.Z → X.Y.Z+1

**README changes:**
- Added agents: ...
- Removed agents: ...
- Added skills: ...
- Removed skills: ...
- Added commands: ...

**Codex sync:** plugins/ai-kit updated (N files changed) / already in sync.

**Validation:** All agents and skills pass convention checks.

**Files to commit:**
- README.md
- .claude-plugin/plugin.json
- .codex-plugin/plugin.json
- plugins/ai-kit/** (if the sync changed anything)
```

Only show sections with actual changes.

## Step 8: Commit

Stage and commit only the modified files:

```bash
git add README.md .claude-plugin/plugin.json .codex-plugin/plugin.json plugins/ai-kit
```

Commit with message format:

```
release: vX.Y.Z

- Updated README (added N agents, removed M agents, ...)
- Bumped Claude and Codex plugin versions to X.Y.Z
```

Do NOT use `git add -A` or `git add .`. After committing, run `git status` to confirm clean state and report the commit hash.
