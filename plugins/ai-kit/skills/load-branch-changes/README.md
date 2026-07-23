# load-branch-changes

A skill that **loads the current git branch's changes into context** — diff, commits, and
changed files vs. the base branch — and sets them as the working focus for the session.

Useful before review, summarizing what a branch does, or focusing the agent on just your work.

> Pure git, so it works in any repo. Loading it elsewhere than where you run the agent does
> nothing on its own — it acts when invoked in a session.

## Install (skill only, no plugin)

A skill is just a folder with a `SKILL.md`. No single directory is read by every client, but
`~/.agents/skills/` is picked up by **opencode, Codex, Cursor, and Copilot** — so one fetch
covers them; add a symlink for Claude Code.

**1. Fetch it:**

```bash
npx degit ivklgn/ai-kit/skills/load-branch-changes ~/.agents/skills/load-branch-changes
```

No `npx`? Use git:

```bash
git clone --depth 1 https://github.com/ivklgn/ai-kit.git /tmp/ai-kit \
  && cp -R /tmp/ai-kit/skills/load-branch-changes ~/.agents/skills/ \
  && rm -rf /tmp/ai-kit
```

**2. For Claude Code**, also symlink it (it reads `~/.claude/skills/`, not `~/.agents/`):

```bash
ln -s ~/.agents/skills/load-branch-changes ~/.claude/skills/load-branch-changes
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

> Load my branch changes with load-branch-changes
