# audit-website

A skill for an **automated technical website audit** via the `squirrel` CLI (squirrelscan). It
crawls a live or local site and checks 230+ rules across SEO, performance, security, technical,
content, and 16 other categories, returning an LLM-optimized report with a health score, broken
links, meta-tag analysis, and actionable fixes (optional confirm-first fix loop).

> **Prerequisite:** the `squirrel` CLI must be installed and on your `PATH`. See
> [squirrelscan](https://squirrelscan.com).
>
> For a manual SEO strategy review without a crawler, use the **seo-audit** skill instead.

## Install (skill only, no plugin)

A skill is just a folder with a `SKILL.md`. No single directory is read by every client, but
`~/.agents/skills/` is picked up by **opencode, Codex, Cursor, and Copilot** — so one fetch
covers them; add a symlink for Claude Code.

**1. Fetch it:**

```bash
npx degit ivklgn/ai-kit/skills/audit-website ~/.agents/skills/audit-website
```

No `npx`? Use git:

```bash
git clone --depth 1 https://github.com/ivklgn/ai-kit.git /tmp/ai-kit \
  && cp -R /tmp/ai-kit/skills/audit-website ~/.agents/skills/ \
  && rm -rf /tmp/ai-kit
```

**2. For Claude Code**, also symlink it (it reads `~/.claude/skills/`, not `~/.agents/`):

```bash
ln -s ~/.agents/skills/audit-website ~/.claude/skills/audit-website
```

| Client      | Global skills directory                                                 |
|-------------|-------------------------------------------------------------------------|
| Claude Code | `~/.claude/skills/`                                                      |
| opencode    | `~/.agents/skills/` · `~/.claude/skills/` · `~/.config/opencode/skills/` |
| Codex CLI   | `~/.agents/skills/` · `~/.codex/skills/`                                 |
| Cursor      | `~/.agents/skills/` · `~/.cursor/skills/`                                |
| Copilot     | `~/.agents/skills/` · `~/.copilot/skills/`                               |

Per-project instead of global? Use the project-local equivalent (`.agents/skills/`,
`.claude/skills/`, `.cursor/skills/`, `.github/skills/`, …).

## Use

Restart your agent and ask, e.g.:

> Audit https://example.com with audit-website
