# ivklgn

22 specialized subagents and 5 skills, packaged for **Claude Code** and the **OpenAI Codex CLI** from a single shared source tree. Skills work identically on both hosts; subagents are Claude-first today, with Codex compatibility planned.

## Installation — Claude Code

```bash
# Add the marketplace
/plugin marketplace add ivklgn/ai

# Install the plugin
/plugin install ivklgn
```

Or via `settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "ivklgn-ai": {
      "source": {
        "source": "github",
        "repo": "ivklgn/ai"
      }
    }
  },
  "enabledPlugins": {
    "ivklgn@ivklgn-ai": true
  }
}
```

Local development:

```bash
claude --plugin-dir .
```

## Installation — Codex CLI

`codex plugin marketplace add` accepts `owner/repo[@ref]`, a git URL, or a local directory:

```bash
# From GitHub
codex plugin marketplace add ivklgn/ai

# Or from a local clone
git clone https://github.com/ivklgn/ai.git ~/ivklgn-ai
codex plugin marketplace add ~/ivklgn-ai
```

Then enable the plugin — either through the in-app picker in `codex`, or by adding the following to `~/.codex/config.toml`:

```toml
[plugins."ivklgn@ivklgn-ai"]
enabled = true
```

## Uninstall

```bash
# Claude Code
claude plugin uninstall ivklgn --scope user

# Codex — disable in ~/.codex/config.toml, then drop the marketplace
codex plugin marketplace remove ivklgn-ai
```

## Agents

| Agent                                                                      | Description                                                                                                       |
| -------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| [business-analyst](agents/business-analyst.md)                             | Requirements analysis, user stories, feature specs, and product documentation                                     |
| [cli-developer](agents/cli-developer.md)                                   | CLI tools and terminal applications with cross-platform support and shell completions                             |
| [css-developer](agents/css-developer.md)                                   | CSS/SCSS specialist for layout, responsive design, animations, theming, and modern CSS features                   |
| [deployment-engineer](agents/deployment-engineer.md)                       | CI/CD pipeline design, deployment strategies (blue-green, canary), and GitOps workflows                           |
| [documentation-developer](agents/documentation-developer.md)               | Documentation sites with Astro Starlight, Docusaurus, VitePress, and SEO optimization                             |
| [frontend-figma-layout-designer](agents/frontend-figma-layout-designer.md) | Convert raw Figma HTML/CSS exports into clean, production-ready React components                                  |
| [golang-pro](agents/golang-pro.md)                                         | High-performance Go systems, concurrent programming, microservices, and idiomatic patterns                        |
| [instantdb-expert](agents/instantdb-expert.md)                             | InstantDB realtime database: code generation, reviews, optimizations, and type-safe patterns                      |
| [js-perf-analyzer](agents/js-perf-analyzer.md)                             | JS/TS performance analysis: memory leaks, CPU bottlenecks, event loop stalls, V8 internals, and bundle size       |
| [llm-architect](agents/llm-architect.md)                                   | LLM systems architecture: inference serving, RAG pipelines, fine-tuning, and multi-model orchestration            |
| [mcp-developer](agents/mcp-developer.md)                                   | MCP server and client development for connecting AI systems to external tools and data                            |
| [npm-updater](agents/npm-updater.md)                                       | Check for package updates, analyze changelogs, run security audits, and create update reports                     |
| [platform-engineer](agents/platform-engineer.md)                           | Internal developer platforms, self-service infrastructure, Backstage portals, and golden paths                    |
| [playwright-e2e](agents/playwright-e2e.md)                                 | Playwright E2E testing: write, review, debug, and optimize tests and page objects                                 |
| [postgres-pro](agents/postgres-pro.md)                                     | PostgreSQL expert for relational database design, normalization, ER modeling, and correctness-focused performance |
| [prompt-engineer](agents/prompt-engineer.md)                               | Prompt design, optimization, A/B testing, and production prompt management                                        |
| [react-code-optimizer](agents/react-code-optimizer.md)                     | React performance analysis: fix re-renders, eliminate duplicates, optimize component splitting                    |
| [react-specialist](agents/react-specialist.md)                             | React 18+ development with hooks, server components, and production-ready architectures                           |
| [reatom-guru](agents/reatom-guru.md)                                       | React with Reatom state manager: write, review, and refactor using best practices                                 |
| [security-auditor](agents/security-auditor.md)                             | Security auditing, vulnerability assessment, OWASP compliance, and threat modeling                                |
| [security-engineer](agents/security-engineer.md)                           | DevSecOps automation, zero-trust architecture, compliance programs, and vulnerability management                  |
| [typescript-pro](agents/typescript-pro.md)                                 | Advanced TypeScript development with full type system mastery, strict mode, generics, and build optimization      |

## Skills

| Skill                                                      | Description                                                                           |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| [load-branch-changes](skills/load-branch-changes/SKILL.md) | Load current branch changes (diff, commits, changed files) into session context       |
| [reset-permissions](skills/reset-permissions/SKILL.md)     | Reset accumulated permissions in .claude/settings.local.json (full or keep read-only) |
| [review-golang](skills/review-golang/SKILL.md)             | Go code review on git-changed files using golang-pro agent with Context7 docs         |
| [update-golang-deps](skills/update-golang-deps/SKILL.md)   | Update Go module deps using native `go` toolchain + govulncheck; handles v2+ paths    |
| [update-node-deps](skills/update-node-deps/SKILL.md)       | Update Node.js deps (npm/pnpm/yarn/bun) using native commands with changelog + audit  |

## Structure

```
├── .claude-plugin/
│   ├── plugin.json                  # Claude Code plugin manifest
│   └── marketplace.json             # Claude Code marketplace manifest
├── .codex-plugin/
│   └── plugin.json                  # Codex plugin manifest
├── .agents/plugins/marketplace.json # Codex marketplace manifest
├── .mcp.json                        # Shared MCP server config
├── agents/                          # Subagents (22) — Claude-first; openai.yaml for Codex interface
└── skills/                          # Skills (5) — shared across both hosts
```

Both Claude Code and the Codex CLI read the same `skills/` directory. The `agents/` directory holds Claude-style subagents (YAML frontmatter); `agents/openai.yaml` carries the Codex plugin-level interface metadata. The only other host-specific files are the plugin and marketplace manifests under `.claude-plugin/`, `.codex-plugin/`, and `.agents/plugins/`.

## Releasing

`/review-and-release` validates conventions, syncs the README tables, bumps the patch version in both `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json`, and creates a release commit.
