---
name: compatibility-audit
description: Audit whether a change is compatible with everything around it, across four boundaries — the contract it exposes to consumers, how cleanly it fits the conventions and abstractions of the place it lives, whether the change was carried through everywhere it had to be, and whether it survives its runtime environment. Scope is either the current git changes (working tree, staged, or branch vs merge base) or an explicit path — a module, package, class, function, file, schema, or config. Language-, domain- and artifact-agnostic — works the same for a new API endpoint, a Go package refactor, a single class, a frontend component, a database migration, or a devops/CI configuration. Emits a per-axis verdict (OK/RISK/FAIL) with evidence-backed findings and a compatible / conditionally compatible / incompatible ruling plus a migration path. Use when asked whether a change will break anyone, whether a piece of code still fits its surroundings, before merging a refactor, when extracting or upgrading a shared package, when adding or altering an API, or to review how cleanly the current edits integrate.
model: sonnet
---

# Compatibility Audit

Answer one question: **is this change safe and clean with respect to everything it touches?**

The audited unit can be anything with a boundary — a package, a module, a class, a single function, an endpoint, a schema, a config file. The word "surface" below means whatever that unit exposes.

Compatibility here is not only "does it break the build". Any change sits inside four boundaries, and it is compatible only when it agrees with all four:

| Axis | Boundary | The question |
|---|---|---|
| **Contract** | What it exposes outward | Does anything that depends on it still work? |
| **Integration** | The context it lives in | Does it match the conventions and reuse the abstractions of this place? |
| **Completeness** | The closure of the change | Was the change carried through everywhere it had to be? |
| **Environment** | What it executes on | Does it survive its runtime, platform, and rollout? |

This works across languages and domains because the axes are fixed while the **reference standard is discovered per repository**. Never judge against a generic best practice — judge against what this repo already does, and cite it.

This skill assesses; it does not fix. Evidence over intuition: every finding cites a file and line, a diff hunk, or a command result.

## Step 0: Resolve the Scope

Run the bundled scope resolver — it handles baseline detection, all change states, and path scoping (paths are relative to this skill's directory):

```bash
sh scripts/resolve_scope.sh                      # current git changes vs merge base
sh scripts/resolve_scope.sh path/to/target       # a package, module, file, schema, or config dir
sh scripts/resolve_scope.sh --base v1.4.0 pkg/   # explicit baseline
```

It prints `BASE`, `MODE`, `COUNT`, the changed files, the manifests that govern them, and the touched directories. Parse that output; do not re-derive it.

The three modes mean different things:

- **git-changes / path-scoped-changes** — baseline is `BASE`, candidate is the working tree. Diff with `git diff <BASE> -- <paths>`.
- **path-snapshot** — no pending changes in that path. Audit the code as it stands against its current consumers ("is this thing in good standing?"). Contract findings become "risk in the existing surface" rather than "regression".
- **COUNT 0** — nothing to audit. Ask the user what to audit; do not guess.

For a change that is proposed but not yet written, treat the current tree as baseline and audit the proposal on paper against the same four axes.

## Step 1: Map the Scope onto Surfaces and Consumers

Before judging anything, establish three facts:

1. **What is the public surface** of the changed thing — what crosses its boundary.
2. **Who consumes it** — every caller, importer, subclass, deployment, or reader of its data.
3. **What the local norm is** — how the neighbouring code solves the same problems.

The mapping from artifact kind to surface and consumers is in **`references/surface-map.md`** — read it now, and read only the rows matching the manifests and file types in scope (code module, HTTP/RPC/GraphQL API, database schema, event payload, UI component, CLI, config/IaC/CI, published package). It also lists where consumers hide in each case.

Anything not reachable from outside the boundary is internal: note it as exempt from Contract, but it still counts for Integration.

Establish the local norm by reading siblings, not by recalling conventions: the other files in the same directory, the nearest equivalent module, the repo's lint/format config, and any project rules (`CLAUDE.md`, `.archcore/`, `CONTRIBUTING`, ADRs). A convention with no local precedent is not a finding.

## Step 2: Contract — Will Consumers Break

Walk the diff of the public surface and classify each change into exactly one primary category:

| Category | Meaning | Typical evidence |
|---|---|---|
| **additive** | New capability; existing consumers unaffected | new export, new optional param/field, widened input type |
| **source-breaking** | Consumers fail to compile/typecheck | removed/renamed export, narrowed param type, new required param, changed generic signature |
| **runtime-breaking** | Compiles but fails at runtime | changed thrown/returned error shape, sync→async, removed dynamic property, changed argument order in untyped code |
| **behavioral** | Same signature, different observable behavior | changed defaults, ordering, rounding, timezone handling, validation strictness, side-effect timing |
| **data-breaking** | Persisted or transmitted data incompatible | schema migration without backfill, changed serialization field names/types, cache key format change |
| **dependency-breaking** | Consumers' dependency resolution breaks | peer-dependency major bump, dropped runtime/engine version, new transitive conflict, license change |

Behavioral changes are what diffs hide best — read the changed bodies of every public symbol, not just the signatures.

## Step 3: Integration — Does It Fit Where It Lives

This is the "quality and cleanliness" axis: the change may break nobody and still be wrong for this place. Probe convention conformance, abstraction reuse, dependency direction, duplication, surface economy, and coupling.

The probes, and the rule that every finding must cite a local precedent, are in **`references/integration-fit.md`** — read it before judging this axis or Completeness.

## Step 4: Completeness — Was the Change Carried Through

A half-applied change is a compatibility defect even when every piece compiles. Check that all call sites moved, that tests/docs/config/CI/types followed, that no dead remnant of the old shape survives, and that parallel implementations were not left behind. Probes are in the same reference file.

## Step 5: Environment — Does It Survive Its Runtime

Check the change against what it actually runs on: language/toolchain version floors, target platforms and browsers, engine and container constraints, required env vars and secrets, feature flags, and — for anything deployed — whether old and new instances can coexist during a rolling release (old readers vs new writers, and the reverse). Detection commands per ecosystem are in **`references/verification.md`**.

## Step 6: Verify With Real Gates

Do not stop at static analysis. Run what exists:

- Build/typecheck and test the packages that consume the changed surface, scoped to the affected ones.
- Use the matching contract-diff tool when its config is present (`oasdiff`, `buf breaking`, `graphql-inspector`, `cargo semver-checks`, Pact) and normalize its output into the classification table above.
- Record each command and its result. A passing gate is evidence; an unrun gate is a gap that must appear in the report.

Commands per ecosystem, and what to do when no gate exists, are in **`references/verification.md`**.

## Step 7: Report

Assign a severity to every finding: **blocker** (a known consumer breaks, or the change is demonstrably incomplete), **warn** (could break consumers you cannot see — published API, dynamic access, serialized data in the wild — or violates a local precedent), **info** (additive or internal).

Then roll up: an axis is **FAIL** with any unresolved blocker, **RISK** with any warn, otherwise **OK**.

```markdown
## Compatibility Audit — <scope> (<BASE>..<candidate>, mode: <MODE>)

**Verdict: COMPATIBLE | CONDITIONALLY COMPATIBLE | INCOMPATIBLE**

| Axis | Result | One-line reason |
|---|---|---|
| Contract | OK | no public surface removed or narrowed |
| Integration | RISK | own retry loop instead of the shared one |
| Completeness | FAIL | 2 of 5 call sites still on the old signature |
| Environment | OK | toolchain floor unchanged |

### Findings
| # | Axis | Severity | Category | Finding | Evidence | Affected |
|---|---|---|---|---|---|---|
| 1 | Completeness | blocker | — | `runJob` still called with the removed 2-arg form | cmd/cli/run.go:41 | cmd/cli |
| 2 | Integration | warn | — | hand-rolled retry; `pkg/retry.Do` is the established one (pkg/queue/worker.go:63) | internal/api/client.go:88 | — |

### Verification
| Consumer / Gate | Command | Result |
|---|---|---|
| cmd/cli | `go build ./cmd/...` | FAIL — 2 errors |

### Gaps
- <surfaces or consumers that could not be exercised, and why>

### Required before merge
1. <ordered, concrete steps>
```

Verdict rules:

- **INCOMPATIBLE** — at least one unresolved Contract blocker: a known consumer breaks.
- **CONDITIONALLY COMPATIBLE** — no Contract blocker, but any axis is FAIL or RISK. List every condition under "Required before merge"; a conditional verdict with an empty list is invalid.
- **COMPATIBLE** — all four axes OK, with the gates in Step 6 actually run.

For every blocker, propose the cheapest safe path, in this order: preserve compatibility (overload, optional param, deprecated alias, adapter shim, dual-write migration) → staged deprecation with warnings → coordinated breaking change with a written migration guide and, for a published package, a major version bump.

## Rules

- Never report COMPATIBLE while a gate is failing or unrun for a blocker-suspect change — downgrade honestly and put it in Gaps.
- Every Integration finding cites the local precedent it contradicts. Without a precedent it is a preference, and preferences are not findings.
- Behavioral compatibility claims require reading the implementation, not just the signature diff.
- Do not fix the code. Report, then offer to implement the "Required before merge" list as a separate step.
- An undefined public surface (no export manifest, everything imported ad hoc) is itself a Contract finding — report it rather than inventing a boundary.
- Keep the axes separate in the report. "It breaks callers" and "it is ugly here" have different costs and different owners.
