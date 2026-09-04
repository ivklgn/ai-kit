---
title: "Project stack and conventions"
status: accepted
tags:
  - "conventions"
  - "stack"
---

This repository is a plugin marketplace (`ai-kit`), not a runnable application. It ships specialized subagents, skills, and slash commands for two hosts — Claude Code and the OpenAI Codex CLI — from one shared source. There is no build manifest or compiled source; the artifacts are Markdown, TOML, YAML, and JSON definitions.

Author every agent as a synced pair: a Claude Code Markdown file `agents/<name>.md` (YAML frontmatter `name`/`description`/`tools`/`model`, then the prompt body) and a matching Codex TOML file `agents/<name>.toml` (`name`/`description`/`sandbox_mode`/`developer_instructions`). The instruction bodies must stay in sync — when you change one, change the other.

Author skills as `skills/<name>/SKILL.md` and slash commands as `commands/<name>.md`. Every `SKILL.md` frontmatter carries `name` and `description`, plus either `model` (`haiku`, `sonnet`, or `opus`) or `disable-model-invocation: true`.

Name skills and commands in kebab-case — lowercase words joined by hyphens (`ask-me`, `load-branch-changes`), never run together (`askme`). One string serves four places at once: the skill directory name, the frontmatter `name`, the command filename, and the `/ai-kit:<name>` invocation. Renaming is therefore a breaking change for anyone who already installed the plugin, and moves the directory, the command file, the README lists, the `THIRD-PARTY-LICENSES.md` entry, and the `plugins/ai-kit` mirror together.

Declare distribution in three places: `.claude-plugin/` (`marketplace.json` + `plugin.json`) for Claude Code, `.codex-plugin/plugin.json` for Codex, and `agents/openai.yaml`, which carries the Codex plugin-level `interface.display_name`. Keep the `version` field identical across both plugin manifests and bump them together on release.

The Codex marketplace manifest (`.agents/plugins/marketplace.json`) points at `plugins/ai-kit/`, not the repo root — Codex users receive only that directory's contents. On every release, mirror the root into it: `rsync -a --delete` of `skills/` and `agents/` (the agents sync carries `agents/openai.yaml` along), plus a copy of `.codex-plugin/plugin.json` (so its version matches). `commands/` is intentionally not synced — the Codex manifest declares only `skills` and `mcpServers`; slash commands are Claude-only. The `/review-and-release` skill performs this sync.

Configure MCP servers in `.mcp.json`, kept identical in `.codex.mcp.json` and `plugins/ai-kit/.mcp.json`.

Write prompts as imperative architectural guidance — no code blocks unless the agent's domain genuinely requires them.
