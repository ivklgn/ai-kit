---
title: "Adding a skill to ai-kit"
status: accepted
tags:
  - "conventions"
  - "skills"
---

## What

Adding one skill to this repository crosses three instruments that know nothing about each other: the built-in `skill-creator` writes portable skills, Archcore holds the rules that bind this repo, and `/review-and-release` owns the README lists, the `plugins/ai-kit` mirror, and both manifest versions. The harness at `@.claude/skills/new-skill/SKILL.md` sequences them and carries the conventions `skill-creator` cannot know.

The last four skills were added in this shape: `1764536` (recap), `21dea13` (ask-me), `ca5c2a1` (compatibility-audit), `0569779` (explain-branch-changes).

## When

The user asks for a new capability packaged as a skill, or invokes `/new-skill`. Not this pattern: editing an existing skill's body, renaming one, or adding a subagent — an agent is a synced `agents/<name>.md` + `agents/<name>.toml` pair with its own conventions.

## Steps

1. Read the repo's stack rule and scan `skills/` for a skill that already covers the job.
2. Collect the brief: job, triggers, model, command, bundled resources, origin, output language.
3. Draft `skills/<name>/SKILL.md` through `skill-creator`, skipping its packaging step.
4. Add `model:` to the frontmatter, matching the value chosen in the brief.
5. Write `commands/<name>.md` from the fixed template when the skill is a fired action.
6. Run the license track when the skill text came from outside this repository.
7. Record an `adr` when the design settled a convention that binds later work.
8. Run `/review-and-release` and report the version and commit hash.

## Example

`recap`, commit `1764536`. Brief: re-orient in a long session; triggers "recap", "where are we"; `model: sonnet`; command yes; no bundled resources; original text; English. Produced `skills/recap/SKILL.md` (64 lines) and `commands/recap.md` (15 lines). `/review-and-release` then added both names to the README `## Skills` and `## Commands` lists, mirrored the skill into `plugins/ai-kit/skills/recap/`, and bumped both manifests. No Archcore document — the skill introduced no new convention.

## Pitfalls

1. The author MUST NOT edit `plugins/ai-kit/skills/`; `rsync -a --delete` overwrites that tree at every release.
2. The author MUST NOT run `quick_validate.py` or `package_skill.py`; both reject `model:` as an unexpected frontmatter key.
3. The author MUST NOT hand-edit the README `## Skills` list or either manifest version; `/review-and-release` owns them.
4. The author MUST NOT add a skill-level `README.md` by default; this repo adds one only for skills meant for standalone `npx degit` install.
5. WHEN the skill is domain expertise the model triggers on its own, the author MAY skip the command file.
