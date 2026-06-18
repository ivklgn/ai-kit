# 12-factor-apps

A skill that runs a **12-Factor App compliance analysis** on any codebase — scoring how portable,
scalable, and continuously-deployable an app is against the original methodology, with concrete
findings per factor.

Use it to evaluate application architecture, audit SaaS apps, or review cloud-native services.

> Ported from the `12-factor-apps` skill by **anderskev** (clawhub.ai), released under MIT-0;
> methodology by Adam Wiggins ([12factor.net](https://12factor.net)). See `ATTRIBUTION.md`.

## Install (skill only, no plugin)

A skill is just a folder with a `SKILL.md`. No single directory is read by every client, but
`~/.agents/skills/` is picked up by **opencode, Codex, Cursor, and Copilot** — so one fetch
covers them; add a symlink for Claude Code.

**1. Fetch it:**

```bash
npx degit ivklgn/ai-kit/skills/12-factor-apps ~/.agents/skills/12-factor-apps
```

No `npx`? Use git:

```bash
git clone --depth 1 https://github.com/ivklgn/ai-kit.git /tmp/ai-kit \
  && cp -R /tmp/ai-kit/skills/12-factor-apps ~/.agents/skills/ \
  && rm -rf /tmp/ai-kit
```

**2. For Claude Code**, also symlink it (it reads `~/.claude/skills/`, not `~/.agents/`):

```bash
ln -s ~/.agents/skills/12-factor-apps ~/.claude/skills/12-factor-apps
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

> Check this codebase against the 12 factors with 12-factor-apps
