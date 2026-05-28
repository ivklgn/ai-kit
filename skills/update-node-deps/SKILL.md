---
name: update-node-deps
description: Audit and update Node.js/JavaScript project dependencies using native package-manager commands (npm, pnpm, yarn, bun). Auto-applies patch updates silently, asks before minor, and confirms each major individually. Cross-checks changelogs via Context7 and security advisories before each batch. Use when the user asks to update dependencies, bump packages, check outdated packages, or audit security in a JS/TS project.
model: sonnet
---

# Update Node.js Dependencies

Audit and update Node.js project dependencies safely, one semver tier at a time. Use native package-manager commands only — no `npm-check-updates` or other third-party wrappers.

## Step 1: Detect the package manager

Determine the PM in this order (stop at first match):

1. `packageManager` field in `package.json` (corepack convention: `"pnpm@9.x"`, `"yarn@4.x"`, etc.).
2. Lockfile presence:
   - `pnpm-lock.yaml` → **pnpm**
   - `yarn.lock` → **yarn** (detect classic vs berry via `.yarnrc.yml` presence or `yarn --version`)
   - `bun.lockb` or `bun.lock` → **bun**
   - `package-lock.json` → **npm**
3. If multiple lockfiles exist, ask the user which one is authoritative.
4. If no lockfile and no `packageManager` field, default to **npm** and note it.

## Step 2: Load the PM reference

Read the matching reference file for exact native commands — do not hardcode them in this workflow:

- **npm** → [references/npm.md](references/npm.md)
- **pnpm** → [references/pnpm.md](references/pnpm.md)
- **yarn** (classic or berry) → [references/yarn.md](references/yarn.md)
- **bun** → [references/bun.md](references/bun.md)

## Step 3: Detect workspaces / monorepo

Check for: `workspaces` array in root `package.json`, `pnpm-workspace.yaml`, `turbo.json`, `nx.json`, or `lerna.json`.

If detected, ask the user whether to:
- Target the root `package.json` only
- Target a single workspace (list discovered workspace paths)
- Iterate all workspaces sequentially

## Step 4: Check git cleanliness

Run `git status --porcelain -- package.json '*lock*'`. If either `package.json` or the lockfile is dirty, warn the user — a dirty baseline makes tier rollback ambiguous. Ask whether to continue, stash, or abort.

## Step 5: List outdated packages

Use the PM's native outdated command (from the reference file) with JSON output. Parse into rows:

```
{ name, current, wanted, latest, dependencyType }
```

Exclude packages using `workspace:` / `catalog:` / `link:` / `file:` / `git+` protocols — these are local or pinned on purpose.

## Step 6: Run the security audit

Run the PM's native audit command (from the reference file) in JSON mode. Record advisories keyed by package name, with severity (critical / high / moderate / low) and the fixed-in version.

## Step 7: Categorize by semver

For each outdated package, classify the jump from `current` to `latest`:

- **Patch**: `1.2.3` → `1.2.5` (same major.minor).
- **Minor**: `1.2.3` → `1.3.0` (same major).
- **Major**: `1.2.3` → `2.0.0` (major bump).

Pre-1.0 rule (enforce strictly — pre-1.0 libraries break often):
- `0.2.3` → `0.2.9` = **patch**
- `0.2.3` → `0.3.0` = **major** (not minor — treat minor-in-zeromajor as breaking)
- `0.2.3` → `1.0.0` = **major**

## Step 8: Fetch changelogs (minor + major only)

Patch changelogs are noise — skip them. For each minor and major update, fetch release notes in this order:

1. **Context7 MCP**:
   - `mcp__context7__resolve-library-id` with the package name
   - `mcp__context7__query-docs` with the resolved ID and `query="changelog"` (retry with `query="releases"` or `query="breaking changes"` if empty)
2. **GitHub releases via `gh`**:
   - Find repo URL: `npm view <pkg> repository.url --json 2>/dev/null`
   - `gh release view v<version> -R <owner>/<repo>` (try with and without the `v` prefix)
   - Or `gh release list -R <owner>/<repo> --limit 10` to inspect multiple hops
3. **WebFetch fallback**:
   - `https://github.com/<owner>/<repo>/releases` or `https://www.npmjs.com/package/<pkg>`

Summarize each into one line: `"Adds X. Deprecates Y. **Breaking:** Z."` — keep breaking-change callouts prominent.

## Step 9: Apply updates in tiers

Apply in strict order: **patch → minor → major**. After each tier, run verification (Step 10) before proceeding to the next tier. If verification fails, offer rollback and stop.

### Tier 1 — Patches (auto-apply)

Apply all patch updates and all security-fix updates (regardless of semver range) as one batch. Use the PM's batch patch-update command from the reference. Do not prompt. Report count after.

### Tier 2 — Minor (approval gate)

Present the full minor batch as a markdown table:

```
| Package | Current → Latest | Fixes advisory? | Changelog summary |
```

Ask the user: approve the batch, deselect specific packages, or skip tier entirely. Apply approved packages; report.

### Tier 3 — Major (per-package confirmation)

Iterate majors one at a time. For each:
- Show `current → latest`
- Show changelog summary with **breaking changes flagged**
- Link codemod / migration guide if found in the changelog
- Note any type-definition changes (`@types/*` jumps often come with API shifts)

Ask per-package: **apply / skip / defer-to-later**. Apply each approved major individually, run install, then immediately run verification (Step 10). If verification fails for a specific major, offer rollback of just that package and continue to the next major.

## Step 10: Verify

Run after each tier (and after each individual major):

1. Install must have exited 0.
2. If `tsconfig.json` exists: run `npx tsc --noEmit` (or the `typecheck` script if defined in `package.json`).
3. If `scripts.build` exists in `package.json`: run it via the PM.
4. If `scripts.test` exists: offer to run it (don't force — tests can be slow).

On failure:
- Report the exact error (first 50 lines).
- Offer rollback: `git checkout -- package.json <lockfile>` then re-run the PM's install.
- Do not proceed to the next tier.

## Step 11: Final report

Emit a concise markdown report:

```markdown
# Node.js Dependencies Update Report

**Package manager:** pnpm (detected via pnpm-lock.yaml)
**Scope:** root (or workspace path)

## Applied
- patch: 12 packages (2 fixed advisories)
- minor: 5 packages (1 fixed advisory)
- major: 2 packages

## Skipped / deferred
- `react@19.0.0` — deferred, needs app-wide migration review
- `eslint@9.0.0` — skipped, flat-config migration blocker

## Security advisories
- Resolved: 3 (HIGH: 1, MODERATE: 2)
- Remaining: 1 (LOW — no fix available upstream)

## Verification
- install: ok
- typecheck: ok
- build: ok
- tests: not run (user declined)
```

## Guardrails

- **Never use `--force` or `--legacy-peer-deps`** without explicit user approval. Peer-dep errors are signal, not noise.
- **Never bypass git hooks. Never commit or push.** The user reviews and commits themselves.
- **Skip `overrides` / `resolutions`** entries in `package.json` — they exist to pin problem versions; mention them in the report instead.
- **Preserve `workspace:` / `catalog:` / `link:` / `file:` protocols** — do not rewrite to literal versions.
- **Respect `engines.node`**: if a major update's changelog says it requires a newer Node than `engines.node`, flag and skip.
- **One PM at a time**: do not mix (e.g., do not `npm install` in a pnpm project).
