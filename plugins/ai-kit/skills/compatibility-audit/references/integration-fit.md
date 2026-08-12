# Integration Fit and Completeness Probes

The rubric for the two "quality and cleanliness" axes. The probes are fixed; the standard they measure against is discovered in the repository under audit.

- [The evidence rule](#the-evidence-rule)
- [Establishing the local norm](#establishing-the-local-norm)
- [Integration probes](#integration-probes)
- [Completeness probes](#completeness-probes)
- [Not findings](#not-findings)
- [Severity for these axes](#severity-for-these-axes)

## The evidence rule

**Every Integration finding must name the local precedent it contradicts, with a `file:line`.**

- Valid: "builds its own retry loop; `pkg/retry.Do` is used by the three other clients (pkg/queue/worker.go:63, internal/sync/pull.go:22)".
- Invalid: "should use a shared retry helper" — that is a preference, and preferences are not findings.

The precedent can be code, a lint or format config, a documented rule (`CLAUDE.md`, `.archcore/`, ADR, `CONTRIBUTING`), or an explicit convention in a README. If none exists, the honest finding is that the convention is undefined — report that once, do not repeat it per file.

This rule is what makes the audit portable across languages: it never imports an outside style opinion, it only measures self-consistency.

## Establishing the local norm

Before judging, read enough to know what "normal" looks like here:

1. **Siblings** — the other files in the same directory, and the file most similar in role to the changed one.
2. **The nearest equivalent unit** — if a new endpoint was added, read two existing endpoints end to end; if a Terraform module changed, read a neighbouring module.
3. **Machine-enforced rules** — linter, formatter, type-checker strictness, import-boundary configs, commit hooks. Anything already enforced is settled, not open for a finding.
4. **Written rules** — project docs and decision records that constrain this area.

Prefer the most recent precedent when the codebase is mid-migration: if half the repo uses the old pattern and new code uses the new one, the new one is the norm. Say so explicitly rather than flagging conformance to it.

## Integration probes

Run each probe against the scope. Record only what the diff actually shows.

**I1 — Convention conformance.** Naming of files, symbols, and parameters; file placement in the tree; module and directory layout; formatting decisions the formatter does not enforce; comment and doc style. Compare with siblings.

**I2 — Abstraction reuse.** Does the change re-solve a problem the codebase already solved? Look specifically for a second implementation of: error construction and wrapping, logging, configuration reading, HTTP or DB clients, retries and backoff, validation, serialization, auth checks, time and clock access, ID generation, feature-flag reads, pagination, caching. A parallel implementation is the single most common integration defect.

**I3 — Dependency direction.** Does the change import in the direction the architecture allows? Check for a new cycle, a lower layer reaching upward, a domain importing infrastructure, a shared package depending on an application, or a cross-boundary import that bypasses a declared public entry point. Import-boundary lint configs and module manifests state the intended direction.

**I4 — Duplication.** Was something copied that should have been called? Distinguish incidental similarity (fine) from a copy that must now be maintained in two places (finding). Copied code that drifted from its source is already a defect.

**I5 — Surface economy.** Is the newly exposed surface the minimum needed? Look for exports added for testing only, internals leaked to satisfy one caller, over-broad barrel re-exports, types exposed that should be internal, and mutable state handed out. Every unnecessary export becomes a permanent contract.

**I6 — Coupling and seams.** Are dependencies injected the way this repo injects them, or hardcoded? Can the change be tested the way its neighbours are tested, or does it require the whole world to be stood up? A unit that cannot be exercised the way its siblings are is a fit defect even if it works.

**I7 — Failure and edge semantics.** Does the change handle errors the way its neighbours do — same wrapping, same propagation, same logging level, same swallow-or-raise decision? Also compare handling of empty/nil/zero values, timeouts, cancellation, concurrency, and partial failure. Divergent failure semantics are invisible to the type-checker and surface in production.

**I8 — Observability parity.** Do the neighbours emit logs, metrics, traces, or audit events at this kind of boundary? If yes and the change is silent, it will be the blind spot in an incident.

**I9 — Internal consistency of the change.** Does the diff solve the same problem two different ways in two places? Does it introduce a new pattern in one file while following the old one in the next? Self-inconsistency within a single change is always a finding.

**I10 — Vocabulary.** Do the new names use the domain terms already established in this codebase, or invent synonyms for existing concepts? Two names for one concept is a comprehension cost paid forever.

**I11 — Reversibility and blast radius.** How hard is this to undo once merged? Note irreversibility explicitly: data migrations, published artifacts, broadened public surface, changes to shared defaults. High blast radius raises severity of every other finding on the change.

## Completeness probes

A change that compiles can still be half-done. Each probe below has a mechanical check.

**C1 — Call sites.** Every consumer found in the surface map was updated. Grep the old symbol, path, flag, key, or route string across the whole repo — including tests, docs, and non-code files. Any survivor is a blocker unless it is intentionally on a compatibility shim.

**C2 — Tests.** Tests covering the changed behavior were updated or added, and tests asserting the *old* behavior were removed rather than left passing against a shim. New public surface without any test is a warn; changed behavior with untouched tests is a blocker suspect — either the tests do not cover it or they now assert the wrong thing.

**C3 — Documentation and examples.** READMEs, doc comments, usage examples, changelogs, and runbooks that name the changed surface. Copy-paste commands in docs are executable contracts.

**C4 — Configuration and fixtures.** Config schemas, defaults, `.env` templates, deployment manifests per environment, seed data, fixtures, mocks, stubs, and contract-test files that encode the old shape. Stale mocks make broken code pass green.

**C5 — Build, CI, and lockfiles.** Lockfiles regenerated for dependency changes, CI job and required-check names still valid, build scripts and Dockerfiles referencing moved paths, cache keys still correct.

**C6 — Dead remnants.** The old implementation, its feature flag, its config keys, its imports, and its tests are gone — or explicitly retained as a documented deprecation with a removal condition. An undocumented leftover is a finding.

**C7 — Mirrors and generated output.** Every mirrored copy updated and every generator re-run (see the surface map's section on generated and mirrored code). Verify by comparing, not by trusting.

**C8 — Cross-cutting registries.** Anything that enumerates the changed thing: exports/barrel files, DI containers, route tables, plugin or command registries, translation catalogs, permission lists, feature-flag definitions, database of record for enum values.

## Not findings

Do not report these; they inflate the report and drown the real signal.

- A style opinion with no local precedent.
- Anything the linter, formatter, or type-checker already enforces and passes.
- Pre-existing debt in files the change merely touched, unless the change makes it materially worse — if it is worth mentioning, put it in Gaps, not Findings.
- Duplication that is coincidental rather than a maintenance link.
- "Missing tests" for code that has no test infrastructure at all — report the absence once, as an environment gap.
- Speculative future needs ("this will not scale") unless the change itself introduces the limit.

## Severity for these axes

- **blocker** — the change is demonstrably incomplete (an unmigrated call site, a stale mirror, a generated artifact out of sync), or it introduces a dependency cycle or an architectural violation that is enforced elsewhere.
- **warn** — a real divergence from an established local precedent, a parallel implementation, an unnecessary permanent export, or a missing test for changed behavior.
- **info** — a minor deviation, or a note worth recording that requires no action before merge.
