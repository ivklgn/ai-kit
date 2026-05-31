# ai-kit

Subagents and skills for **Claude Code** and the **OpenAI Codex CLI**, from one shared source.

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

`business-analyst` · `cli-developer` · `css-developer` · `deployment-engineer` · `documentation-developer` · `frontend-figma-layout-designer` · `golang-pro` · `instantdb-expert` · `js-perf-analyzer` · `llm-architect` · `mcp-developer` · `npm-updater` · `platform-engineer` · `playwright-e2e` · `postgres-pro` · `prompt-engineer` · `react-code-optimizer` · `react-specialist` · `reatom-guru` · `security-auditor` · `security-engineer` · `typescript-pro`

## Skills

`12-factor-apps` · `load-branch-changes` · `reset-permissions` · `review-golang` · `update-golang-deps` · `update-node-deps`

## Commands

`/ai-kit:12-factor-apps` · `/ai-kit:load-branch-changes` · `/ai-kit:reset-permissions` · `/ai-kit:review-golang` · `/ai-kit:update-golang-deps` · `/ai-kit:update-node-deps`

## Credits

The **`12-factor-apps`** skill is a port of the [`12-factor-apps`](https://clawhub.ai/anderskev/12-factor-apps) skill by **anderskev** (clawhub.ai), built on the [Twelve-Factor App](https://12factor.net) methodology by Adam Wiggins. See [`skills/12-factor-apps/ATTRIBUTION.md`](skills/12-factor-apps/ATTRIBUTION.md) for details.

## License

[MIT](LICENSE) © ivklgn
