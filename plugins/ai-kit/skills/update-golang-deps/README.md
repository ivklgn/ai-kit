# update-golang-deps

A skill that **safely updates Go module dependencies, one semver tier at a time**, using the
native `go` toolchain (`go list`, `go get`, `go mod tidy`) plus `govulncheck` — no third-party
wrappers.

- Applies **patch** updates silently, **asks** before minor, **confirms each major** individually
- Cross-checks release notes (gh / Context7) and vulnerabilities before each batch
- Handles v2+ module path changes (`gopkg.in/…`, `github.com/…/v2`)

> Requires the Go toolchain and `govulncheck` available on `PATH`, and a `go.mod` project.

## Install (skill only, no plugin)

A skill is just a folder with a `SKILL.md`. No single directory is read by every client, but
`~/.agents/skills/` is picked up by **opencode, Codex, Cursor, and Copilot** — so one fetch
covers them; add a symlink for Claude Code.

**1. Fetch it:**

```bash
npx degit ivklgn/ai-kit/skills/update-golang-deps ~/.agents/skills/update-golang-deps
```

No `npx`? Use git:

```bash
git clone --depth 1 https://github.com/ivklgn/ai-kit.git /tmp/ai-kit \
  && cp -R /tmp/ai-kit/skills/update-golang-deps ~/.agents/skills/ \
  && rm -rf /tmp/ai-kit
```

**2. For Claude Code**, also symlink it (it reads `~/.claude/skills/`, not `~/.agents/`):

```bash
ln -s ~/.agents/skills/update-golang-deps ~/.claude/skills/update-golang-deps
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

> Update my Go modules with update-golang-deps
