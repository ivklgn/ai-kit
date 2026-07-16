# Attribution

The **`nextjs-developer`** skill is a port of the [`nextjs-developer`](https://github.com/Jeffallan/claude-skills/tree/main/skills/nextjs-developer) skill by **Jeff Allan** ([@Jeffallan](https://github.com/Jeffallan)), distributed under the MIT License.

Changes in the ai-kit port:

- Frontmatter adapted to ai-kit plugin conventions (`model` field, trimmed metadata)
- Added a version/router detection step (Step 0) — the skill now targets the project's installed Next.js version and respects existing Pages Router codebases instead of assuming Next.js 14+ App Router everywhere
- Noted version-sensitive APIs (async `params` in Next 15+, caching default changes) in the examples

Full license text: see [`THIRD-PARTY-LICENSES.md`](../../THIRD-PARTY-LICENSES.md) at the repository root.
