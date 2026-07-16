---
name: module-compatibility-audit
description: Audit a module, package, or subsystem for compatibility with its consumers after a change. Compares baseline vs candidate public surface, classifies every change (additive, source-breaking, runtime-breaking, behavioral, data-breaking, dependency-breaking), verifies affected consumers, and emits a compatibility matrix with a compatible / conditionally-compatible / breaking verdict plus a migration path. Use when refactoring a shared module, upgrading a library's API, extracting a package, or answering "will this change break anyone".
model: sonnet
---

# Module Compatibility Audit

You are auditing whether a changed (or about-to-change) module remains compatible with everything that depends on it. Evidence over intuition: every claim in the final report must cite a file and line, a diff hunk, or a command result.

## Step 0: Establish Baseline and Candidate

Determine what is being compared:

- **Uncommitted or branch changes** — baseline is the merge base (`git merge-base HEAD <default-branch>`), candidate is the working tree. Use `git diff <merge-base>` scoped to the module.
- **A proposed change (not yet written)** — baseline is the current tree; treat the proposal as the candidate and audit it on paper against the same checklist.
- **A dependency upgrade** — baseline is the locked version, candidate is the target version; the "module" is the dependency's API surface as used by this repo.

If there is no diff and no proposal, ask the user what change to audit. Do not proceed without a concrete candidate.

## Step 1: Define the Module Boundary

Identify what is inside the audited module and what constitutes its public surface:

- Entry points: `exports`/`main` in `package.json`, `__init__.py` re-exports, Go package identifiers, `pub` items, barrel files
- Public API: exported functions, classes, types/interfaces, constants, React components and their props, CLI commands and flags, HTTP/RPC endpoints it serves
- Serialized contracts: database schemas and migrations it owns, message/event payloads, file formats, wire schemas (OpenAPI, GraphQL SDL, protobuf), config file shapes
- Environment contracts: env vars read, feature flags, expected directory layout

Anything not reachable from outside the boundary is internal and exempt — note it and move on.

## Step 2: Find the Consumers

Enumerate everyone who depends on the public surface:

- Grep the repo (and sibling packages in a monorepo) for imports of the module and call sites of each changed export
- Include indirect consumers: code that consumes re-exports, subclasses, or implements the module's interfaces
- Include non-code consumers: CI scripts, infra manifests, docs with code samples, external services hitting served endpoints
- For a published library, treat the public API itself as the consumer contract — semver discipline applies to every export

Record consumer → used-symbol pairs; unused parts of the surface can change freely (note them as such).

## Step 3: Diff the Surface and Classify Every Change

Walk the diff of the public surface. Classify each change into exactly one primary category:

| Category | Meaning | Typical evidence |
|---|---|---|
| **additive** | New capability; existing consumers unaffected | new export, new optional param/field, widened input type |
| **source-breaking** | Consumers fail to compile/typecheck | removed/renamed export, narrowed param type, new required param, changed generic signature |
| **runtime-breaking** | Compiles but fails at runtime | changed thrown/returned error shape, sync→async, removed dynamic property, changed argument order in untyped code |
| **behavioral** | Same signature, different observable behavior | changed defaults, ordering, rounding, timezone handling, validation strictness, side-effect timing |
| **data-breaking** | Persisted or transmitted data incompatible | schema migration without backfill, changed serialization field names/types, cache key format change |
| **dependency-breaking** | Consumers' dependency resolution breaks | peer-dependency major bump, dropped runtime/engine version, new transitive conflict, license change |

Severity per finding: **blocker** (a known consumer breaks), **warn** (could break consumers you cannot see — published API, dynamic access, serialized data in the wild), **info** (additive or internal).

Behavioral changes are the ones diffs hide best — read the changed function bodies of every public symbol, not just signatures.

## Step 4: Verify Against Real Consumers

Do not stop at static analysis:

- Run each affected consumer's own gates: typecheck/build the packages that import the module, run their test suites — scoped to affected packages in a monorepo (e.g. turbo/nx affected, `go build ./...`, workspace filters)
- For wire contracts, use the matching diff tool when configs are present: `oasdiff breaking` (OpenAPI), `buf breaking` (protobuf), `graphql-inspector diff` (GraphQL), Pact `can-i-deploy` (consumer contracts) — normalize their findings into the same classification table
- For data-breaking candidates, check migration reversibility and whether old readers tolerate new writers (and vice versa) during rolling deployment
- Record each command and its result; a passing suite is evidence, an unrun suite is a gap that must appear in the report

## Step 5: Emit the Compatibility Matrix and Verdict

Produce the report:

```markdown
## Module Compatibility Audit — <module> (<baseline>..<candidate>)

**Verdict: COMPATIBLE | CONDITIONALLY COMPATIBLE | BREAKING**

### Findings
| # | Category | Severity | Symbol / Contract | Evidence | Affected consumers |
|---|----------|----------|-------------------|----------|--------------------|
| 1 | source-breaking | blocker | `parseConfig(path, opts)` | src/config.ts:42 — `opts` now required | apps/cli (3 call sites), packages/server |

### Verification
| Consumer | Check | Result |
|----------|-------|--------|
| apps/cli | typecheck + tests | FAIL — 3 errors |

### Unverified surface
- <consumers or contracts that could not be exercised, and why>

### Migration path
1. <ordered, concrete steps — code-mod, adapter, deprecation cycle, data backfill>
```

Verdict rules: any unresolved **blocker** → **BREAKING**; only **warn** findings, each with a stated mitigation → **CONDITIONALLY COMPATIBLE** (list the conditions); otherwise **COMPATIBLE**.

For every blocker, propose the cheapest safe path in order of preference: keep compatibility (overload, optional param, deprecated alias re-export, adapter shim, dual-write migration) → staged deprecation with warnings → coordinated breaking change with a written migration guide and, for published packages, a major version bump.

## Rules

- Never mark COMPATIBLE while any consumer's gate is failing or unrun for a blocker-suspect change — downgrade honestly to the gap section
- Do not fix the code during the audit; this skill assesses. Offer to implement the migration path as a follow-up
- Behavioral compatibility claims require reading the implementation, not just the signature diff
- If the module boundary is ambiguous (no export manifest, everything imported ad hoc), report that as a finding itself — an undefined public surface is a compatibility risk
