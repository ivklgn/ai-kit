# reset-permissions

A skill that **clears accumulated permission entries** from a project's
`.claude/settings.local.json` — a full reset by default, or `--keep-read` to drop only
write/action permissions while keeping read-only ones.

> **Claude Code–specific.** This skill operates on Claude Code's `.claude/settings.local.json`
> permission model. The install mechanism below works in any SKILL.md-aware client, but the skill
> is only meaningful inside Claude Code.

## Install (skill only, no plugin)

A skill is just a folder with a `SKILL.md`. For Claude Code, place it in `~/.claude/skills/`:

```bash
npx degit ivklgn/ai-kit/skills/reset-permissions ~/.claude/skills/reset-permissions
```

No `npx`? Use git:

```bash
git clone --depth 1 https://github.com/ivklgn/ai-kit.git /tmp/ai-kit \
  && cp -R /tmp/ai-kit/skills/reset-permissions ~/.claude/skills/ \
  && rm -rf /tmp/ai-kit
```

Per-project instead of global? Put the folder in `.claude/skills/` inside your repo.

> Other SKILL.md clients (opencode, Codex, Cursor, Copilot) read `~/.agents/skills/` — you *can*
> install it there, but it has nothing to act on outside Claude Code.

## Use

Restart Claude Code and ask, e.g.:

> Reset my project permissions with reset-permissions

Add `--keep-read` to keep read-only permissions.
