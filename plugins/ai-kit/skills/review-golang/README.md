# review-golang

A skill that runs a **comprehensive Go code review on your git-changed files** — correctness,
idioms, concurrency, error handling, and test quality — instead of a generic pass.

- Reviews only what changed (`git diff` staged + unstaged `.go` files)
- Test files are checked for test quality, not mixed into the main review
- Pulls current library docs via Context7 when available

> **Note:** in the ai-kit plugin this skill hands off to the dedicated `golang-pro` subagent and
> Context7 MCP. Standalone they're optional — the review still runs inline without them.
> Requires a Go repository with changes.

## Install (skill only, no plugin)

A skill is just a folder with a `SKILL.md`. No single directory is read by every client, but
`~/.agents/skills/` is picked up by **opencode, Codex, Cursor, and Copilot** — so one fetch
covers them; add a symlink for Claude Code.

**1. Fetch it:**

```bash
npx degit ivklgn/ai-kit/skills/review-golang ~/.agents/skills/review-golang
```

No `npx`? Use git:

```bash
git clone --depth 1 https://github.com/ivklgn/ai-kit.git /tmp/ai-kit \
  && cp -R /tmp/ai-kit/skills/review-golang ~/.agents/skills/ \
  && rm -rf /tmp/ai-kit
```

**2. For Claude Code**, also symlink it (it reads `~/.claude/skills/`, not `~/.agents/`):

```bash
ln -s ~/.agents/skills/review-golang ~/.claude/skills/review-golang
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

> Review my Go changes with review-golang
