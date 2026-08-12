<p align="center">
  <img src="logo.png" alt="ai-kit" width="480">
</p>

# ai-kit

Subagents and skills for **Claude Code** and the **OpenAI Codex CLI**, from one shared source. By Ivan K. (<https://github.com/ivklgn>)

## Install

**Claude Code**

```bash
/plugin marketplace add ivklgn/ai-kit
/plugin install ai-kit
```

**Codex CLI** — requires Codex CLI v0.117.0+.

```bash
codex plugin marketplace add ivklgn/ai-kit
codex
# then run /plugins, open AI Kit, select Install plugin
```

Local dev: `claude --plugin-dir .`

## Agents

`android-developer` · `architect-reviewer` · `bdd-specialist` · `business-analyst` · `cli-developer` · `css-developer` · `deployment-engineer` · `documentation-developer` · `documentation-writer` · `frontend-developer` · `frontend-figma-layout-designer` · `golang-pro` · `instantdb-expert` · `ios-developer` · `js-perf-analyzer` · `llm-architect` · `mcp-developer` · `npm-updater` · `platform-engineer` · `playwright-e2e` · `postgres-pro` · `prompt-engineer` · `python-pro` · `react-code-optimizer` · `react-specialist` · `reatom-guru` · `security-auditor` · `security-engineer` · `typescript-pro` · `unit-test-master`

## Skills

`12-factor-apps` · `audit-website` · `can-i-use` · `code-reviewer` · `compatibility-audit` · `explain-branch-changes` · `humanizer` · `humanizer-ru` · `jsdoc` · `load-branch-changes` · `nextjs-developer` · `reset-permissions` · `review-golang` · `seo-audit` · `simplify-code-comments` · `test-health-check` · `update-golang-deps` · `update-node-deps`

## Commands

`/ai-kit:12-factor-apps` · `/ai-kit:can-i-use` · `/ai-kit:compatibility-audit` · `/ai-kit:humanizer` · `/ai-kit:humanizer-ru` · `/ai-kit:jsdoc` · `/ai-kit:load-branch-changes` · `/ai-kit:reset-permissions` · `/ai-kit:review-golang` · `/ai-kit:simplify-code-comments` · `/ai-kit:test-health-check` · `/ai-kit:update-golang-deps` · `/ai-kit:update-node-deps`

## Credits

Several agents and skills are ports of, or are adapted from, third-party MIT-licensed projects. The complete component → source map with full license texts lives in [`THIRD-PARTY-LICENSES.md`](THIRD-PARTY-LICENSES.md); ported skills additionally carry an `ATTRIBUTION.md` in their directory describing what was changed.

- **`12-factor-apps`** — port of the [`12-factor-apps`](https://clawhub.ai/anderskev/12-factor-apps) skill by **anderskev** (clawhub.ai, MIT-0), built on the [Twelve-Factor App](https://12factor.net) methodology by Adam Wiggins
- **`audit-website`** — port from [squirrelscan/skills](https://github.com/squirrelscan/skills) by **squirrelscan** (MIT)
- **`seo-audit`** — condensed adaptation from [marketingskills](https://github.com/coreyhaines31/marketingskills) by **Corey Haines** (MIT)
- **`code-reviewer`** and **`nextjs-developer`** — ports from [jeffallan/claude-skills](https://github.com/Jeffallan/claude-skills) by **Jeff Allan** (MIT); two code-reviewer references were adapted upstream from [obra/superpowers](https://github.com/obra/superpowers) by **Jesse Vincent** (MIT)
- **`humanizer`** — port of [blader/humanizer](https://github.com/blader/humanizer) by **Siqi Chen** (MIT), based on Wikipedia's "Signs of AI writing" guide; **`humanizer-ru`** — port of [ilyautov/humanizer-ru](https://github.com/ilyautov/humanizer-ru) by **Ilya Utov** (MIT)
- **`python-pro`**, **`ios-developer`**, **`frontend-developer`** agents — adapted from [wshobson/agents](https://github.com/wshobson/agents) by **Seth Hobson** (MIT)
- **`android-developer`**, **`typescript-pro`**, **`golang-pro`**, **`mcp-developer`**, **`cli-developer`**, **`llm-architect`**, **`architect-reviewer`**, **`platform-engineer`**, **`prompt-engineer`** agents — adapted from [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) (MIT)
- **`unit-test-master`**, **`bdd-specialist`**, **`compatibility-audit`** — original text drawing on patterns from [testland/qa](https://github.com/testland/qa) (MIT) and wshobson/agents

All adaptations are substantially rewritten for ai-kit's detect-the-project-first conventions.

## License

[MIT](LICENSE) © ivklgn
