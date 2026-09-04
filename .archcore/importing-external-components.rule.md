---
title: "Importing external agents and skills"
status: accepted
tags:
  - "conventions"
  - "imports"
---

External agents and skills (wshobson/agents, VoltAgent, testland/qa, jeffallan/claude-skills, standalone skill repos) are never copied verbatim. Adapt every import to ai-kit conventions:

- **Detect, don't assume.** Replace hard-coded versions ("Python 3.12+", "React 19", "iOS 18") with a detection step that reads the project's manifests (pyproject.toml, package.json, go.mod, Package.swift, gradle files) and gates features on the detected version.
- **Don't impose a stack.** Imported prompts must not push uv/ruff/FastAPI/App Router onto projects that use something else; recommend only for greenfield or on request.
- **Context7 everywhere.** Agents that touch libraries get `mcp__context7__resolve-library-id` / `mcp__context7__query-docs` in tools and a "consult docs" step.
- **License compliance before import.** Check the upstream license first (`gh api repos/<owner>/<repo> --jq .license.spdx_id`). MIT and MIT-0 are fine; anything else needs review. Every port or adaptation — any component where upstream text was carried over — gets all four: (1) an entry in the root `THIRD-PARTY-LICENSES.md` component→source map, (2) the upstream's full license text with its copyright line reproduced in that same file, (3) an `ATTRIBUTION.md` in the skill directory (source, author, license, list of changes) linking to `THIRD-PARTY-LICENSES.md`, and (4) a Credits bullet in README.
- **Attribution depth follows what was copied.** A component written from scratch that reuses only ideas, structure, or a workflow concept gets (1) and (4), and carries no `ATTRIBUTION.md` — `skills/compatibility-audit` is the reference case, mapped as "Original text" in `THIRD-PARTY-LICENSES.md`. An imported agent is a single file with no directory of its own, so it gets (1), (2), and (4) and never an `ATTRIBUTION.md`. Sources are listed in both cases, for transparency.
- **Synced pairs.** Every imported agent still ships as `agents/<name>.md` + `agents/<name>.toml` with matching bodies.
- **Delegation over duplication.** Broad "do-everything" agents (e.g. frontend-developer) are rewritten as integrators that route narrow work to the existing focused agents instead of duplicating their depth.
