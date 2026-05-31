---
name: review-and-release
description: Sync README with current agents/skills, validate plugin conventions, bump version, and commit. Use when the user says "/review-and-release" or wants to prepare a release after adding, removing, or changing agents or skills.
model: sonnet
---

# Review and Release

Synchronize README.md with the current set of agents and skills, validate files follow plugin conventions, bump the patch version in both plugin manifests, and create a release commit.

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

Read `README.md` and parse:

1. **Description line** — extract agent and skill counts from pattern: `N specialized subagents and M skills`.
2. **Agents table** — extract all rows from the `## Agents` table
3. **Skills table** — extract all rows from the `## Skills` table

Compare the filesystem inventory against README and classify:

- **Added** — in filesystem but not in README table
- **Removed** — in README table but not in filesystem
- **Description changed** — present in both but description no longer matches
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

If Step 2 found differences, update `README.md` using the Edit tool:

1. **Description line** — update counts: `{agent_count} specialized subagents and {skill_count} skills`.

2. **Agents table** — rebuild the full table sorted alphabetically by name:
   ```
   | [agent-name](agents/agent-name.md) | Short description |
   ```

3. **Skills table** — rebuild the full table sorted alphabetically by name:
   ```
   | [skill-name](skills/skill-name/SKILL.md) | Short description |
   ```

## Step 5: Bump Version

Increment the patch version (e.g., `2.0.4` → `2.0.5`) in **both** manifests so Claude Code and Codex stay aligned:

- `.claude-plugin/plugin.json`
- `.codex-plugin/plugin.json`

Use the Edit tool on each file.

## Step 6: Present Summary

Before committing, show a clear summary:

```
## Release Summary

**Version:** X.Y.Z → X.Y.Z+1

**README changes:**
- Added agents: ...
- Removed agents: ...
- Updated descriptions: ...
- Added skills: ...
- Removed skills: ...
- Counts updated: N → M agents, P → Q skills

**Validation:** All agents and skills pass convention checks.

**Files to commit:**
- README.md
- .claude-plugin/plugin.json
- .codex-plugin/plugin.json
```

Only show sections with actual changes.

## Step 7: Commit

Stage and commit only the modified files:

```bash
git add README.md .claude-plugin/plugin.json .codex-plugin/plugin.json
```

Commit with message format:

```
release: vX.Y.Z

- Updated README (added N agents, removed M agents, ...)
- Bumped Claude and Codex plugin versions to X.Y.Z
```

Do NOT use `git add -A` or `git add .`. After committing, run `git status` to confirm clean state and report the commit hash.
