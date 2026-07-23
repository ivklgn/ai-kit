# test-health-check

An agent skill that **proves a test actually guards its behavior** — instead of trusting code coverage.

It runs a few targeted fault probes around the code under test to verify four properties:

- **Reachability** — the test really exercises the target behavior
- **Sensitivity** — the test fails under a plausible, contract-related break
- **Oracle validity** — assertions match the contract, not the implementation
- **Reliability** — the result is reproducible and isolated (not flaky / order-dependent)

Optional `--worktree` mode runs the whole cycle in a throwaway git worktree, so your real
working tree is never touched.

## Install (skill only, no plugin)

A skill is just a folder with a `SKILL.md`. No single directory is read by every client, but
`~/.agents/skills/` is picked up by **opencode, Codex, Cursor, and Copilot** — so one fetch
covers them; add a symlink for Claude Code.

**1. Fetch it:**

```bash
npx degit ivklgn/ai-kit/skills/test-health-check ~/.agents/skills/test-health-check
```

No `npx`? Use git:

```bash
git clone --depth 1 https://github.com/ivklgn/ai-kit.git /tmp/ai-kit \
  && cp -R /tmp/ai-kit/skills/test-health-check ~/.agents/skills/ \
  && rm -rf /tmp/ai-kit
```

**2. For Claude Code**, also symlink it (it reads `~/.claude/skills/`, not `~/.agents/`):

```bash
ln -s ~/.agents/skills/test-health-check ~/.claude/skills/test-health-check
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

Restart your agent and just ask, e.g.:

> Health-check the `cancels_unpaid_order` test with test-health-check, focused --worktree

Modes: `quick` (default) · `focused` · `deep` · `exhaustive`. Add `--fix` to also propose a minimal test patch.
