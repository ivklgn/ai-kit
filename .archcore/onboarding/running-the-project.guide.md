---
title: "Running and developing ai-kit locally"
status: accepted
tags:
  - "onboarding"
---

This repository is a plugin marketplace, not a standalone app. "Running" it means installing the `ai-kit` plugin into a host agent, or loading this checkout directly for local development.

## Prerequisites

- Claude Code, or OpenAI Codex CLI v0.117.0 or newer.

## Install into Claude Code

```
/plugin marketplace add ivklgn/ai-kit
/plugin install ai-kit
```

## Install into Codex CLI

```
codex plugin marketplace add ivklgn/ai-kit
codex
# then run /plugins, open AI Kit, and select Install plugin
```

## Local development

Load this checkout directly, without publishing to a marketplace:

```
claude --plugin-dir .
```

## Verify

After install, the subagents, skills, and `/ai-kit:*` commands appear in the host agent. The `context7` MCP server declared in `.mcp.json` becomes available to agents that list its tools.
