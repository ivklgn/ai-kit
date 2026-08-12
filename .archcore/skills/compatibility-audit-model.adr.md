---
title: "Compatibility auditing is modeled on four boundaries"
status: accepted
tags:
  - "conventions"
  - "skills"
---

## Context

The repository shipped `module-compatibility-audit`, a skill answering a single question — will this change break its consumers. Two limits surfaced. The name implied the audited unit is a module, while the same question applies to a class, a function, an endpoint, a migration, or a devops config. And breakage is only half of what makes a change safe: a change can break nobody and still be bolted on badly — parallel abstractions, wrong dependency direction, half-migrated call sites.

## Decision

Compatibility is modeled as agreement across four fixed boundaries, audited together and reported separately:

- **Contract** — what the unit exposes outward; does anything depending on it still work.
- **Integration** — the context it lives in; does it match local conventions and reuse existing abstractions.
- **Completeness** — the closure of the change; was it carried through everywhere it had to be.
- **Environment** — what it executes on; does it survive the runtime, platform, and rollout.

Universality across languages and domains comes from separating the fixed rubric from the discovered standard: the axes and their probes never change, while the baseline they measure against is read out of the repository under audit. Consequently every Integration finding must cite the local precedent it contradicts with a `file:line`. A style opinion with no local precedent is not a finding.

Output is a per-axis verdict (OK / RISK / FAIL) plus evidence-backed findings. The overall ruling is COMPATIBLE, CONDITIONALLY COMPATIBLE, or INCOMPATIBLE, where only an unresolved Contract blocker yields INCOMPATIBLE. The skill is read-only — it reports and proposes a migration path; applying it is a separate, explicit step.

## Alternatives

A numeric 0–100 score per axis was considered and rejected: a model-assigned score invites invented precision and does not reproduce between runs, while a verdict backed by cited evidence does.

Keeping the contract-only skill and adding a second skill for integration quality was rejected because both would match the same trigger ("check whether these changes are compatible"), leaving the choice between them ambiguous.

## Consequences

The skill is renamed `compatibility-audit` — no artifact noun in the name, so it triggers on any unit with a boundary. This is a breaking rename: `/ai-kit:module-compatibility-audit` no longer exists for anyone who already installed the plugin, and the directory, command, README, license map, and `plugins/ai-kit` mirror all move with it.

Scope resolution is delegated to a bundled `scripts/resolve_scope.sh`, which distinguishes three modes — git changes, path-scoped changes, and a path snapshot with no pending edits — so a path with no diff is audited as "is this in good standing" rather than refused.

Detail lives in three reference files loaded on demand: `surface-map.md` maps any artifact kind to its surface and consumers, `integration-fit.md` holds the Integration and Completeness probes, and `verification.md` holds per-ecosystem gates and contract-diff tools.
