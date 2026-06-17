---
name: test-health-check
description: Prove that a unit, integration, or end-to-end test genuinely guards its stated behavior by running a few targeted fault probes (reachability, sensitivity, oracle validity, reliability) around the code under test — instead of trusting coverage. Use during active test development or test review: after writing or changing a test, when verifying a test actually catches real bugs, when a test "passes but might not test anything", when a suite feels untrustworthy, or to health-check the tests affected by the current branch. Supports an isolated git-worktree mode scoped to affected cases so production code is never touched.
model: sonnet
---

# Test Health Check

Produce compact PROOF that a specific test guards its stated contract — by running a few
targeted fault probes around the code under test. This is **not** mutation testing and emits
**no** mutation score. It answers a sharper question for active development: does this test
pass on healthy behavior and reliably fail on a *plausible, contract-related* break?

## Why coverage is not enough

A test can execute a line, or even cover an entire method, yet still fail to assert anything
meaningful (a "pseudo-tested" method survives having its whole body deleted). And a test that
kills mutants can still pin the *wrong* requirement if its oracle was copied from the
implementation. So this skill verifies four independent properties:

1. **Reachability** — the test actually exercises the target behavior.
2. **Sensitivity** — the test fails under a plausible, contract-related break.
3. **Oracle validity** — assertions match the contract/spec/invariant, not the implementation.
4. **Reliability** — the result is reproducible and isolated (not flaky / order / environment dependent).

## Invocation

`$ARGUMENTS` may contain a target and flags. The target is a test name, a test/source file, a
diff/branch scope, or a described behavior. If no target is given, default to the affected cases
of the current branch (see Worktree mode).

| Flag | Effect |
|------|--------|
| `--worktree` | Run the whole cycle in an isolated git worktree scoped to affected cases. Production tree is never mutated. Strongly preferred. |
| `quick` (default) | Current test or changed file: baseline → reachability probe → 2 sensitivity probes → restore. |
| `focused` | Function/class/endpoint/flow: baseline → contract extraction → 3–7 targeted probes → boundary/failure analysis → suggestions. |
| `deep` | Critical behavior: broader probe set, repeated runs, test-order variation, mock/fixture review, metamorphic checks, boundary verification. |
| `exhaustive` | Hand off to a real mutation runner for a true score. NOT the primary mode — only for a full module / CI gate / historical comparison. |
| `--fix` | After diagnosis, propose and verify a minimal test patch (off by default). |

## MUST rules (hard constraints)

- MUST identify the claimed test contract before probing.
- MUST establish a passing baseline first.
- MUST change only ONE behavior per probe.
- MUST keep an exact diff of every probe.
- MUST restore the repository after every probe.
- MUST verify the restored test passes.
- MUST distinguish a test failure from a build / infrastructure failure.
- MUST NOT declare a test healthy when its oracle is unclear (emit `ORACLE_UNCLEAR`).
- MUST NOT report a mutation score from an agent-selected sample.
- MUST NOT retain production mutations.
- MUST verify any proposed test passes on original code and fails on the relevant broken variant.

## Core workflow (the fast loop)

1. **Locate the test and the target code.** Determine the level (unit / integration / e2e) — it
   changes what to probe. See `references/levels.md`.
2. **Extract the contract.** State explicitly what the test promises to verify. Source priority:
   (a) user-stated behavior, (b) issue / acceptance criteria / PR description, (c) public API +
   docs, (d) domain invariants, (e) neighboring tests, (f) production code — LAST, since an
   oracle copied from the implementation can lock in an existing bug. If no reliable contract can
   be derived → stop and report `ORACLE_UNCLEAR`.
3. **Establish the baseline.** Run the test (and, if cheap, its file/class). Record the exact
   command, exit code, duration, seed (if any), test count, and working-tree state. The baseline
   MUST be green. If it is red or flaky, stop dynamic probing and report `FLAKY_OR_ORDER_DEPENDENT`
   or surface the broken baseline — do not probe on top of a broken baseline.
4. **Reachability probe.** Insert a controlled sentinel (throw / fail / panic) at the target point
   in production code and run the test. Expect failure *caused by the sentinel*. If the test still
   passes → `NOT_EXERCISING_TARGET`. Restore.
5. **Sensitivity probes.** Introduce a few plausible, contract-specific defects — ONE behavior
   change per probe — and confirm the test fails for the right reason. Default set: 1 reachability
   + 2 contract-specific + 1 boundary/error probe. Pick probes from `references/probes.md`.
6. **Restore and re-verify.** After every probe, restore the exact bytes and re-run the original
   test to confirm it is green again. Keep the diff of each probe for the report.
7. **Diagnose.** Map results to one diagnosis token and list concrete gaps. See
   `references/diagnoses.md` for the full enum, when each applies, and the proof matrix.

### Restore mechanism (when NOT using `--worktree`)

Before mutating a file, snapshot its exact bytes. After the probe, rewrite the snapshot and
re-run the test to confirm green. If the file already had uncommitted changes, restore from the
snapshot (not `git checkout`, which would discard the user's edits). Prefer `--worktree` to make
this bulletproof.

## Worktree mode + affected cases

`--worktree` (and the default no-target invocation) scopes probing to the tests touched by, or
covering, the current branch's changes, and runs the whole cycle in a disposable git worktree —
so temporary production mutations never reach the real tree, even on interruption.

Use the bundled helper `scripts/worktree.sh` (base branch defaults to `main`):

```bash
# 1. Discover affected files (branch diff vs main + staged + unstaged + untracked)
bash scripts/worktree.sh affected
bash scripts/worktree.sh tests        # same, filtered to likely test files

# 2. Create the isolated worktree (HEAD + uncommitted + untracked replayed); capture its path
WT=$(bash scripts/worktree.sh setup)

# 3. Run baseline + all probes inside "$WT" (cd into it for test + edits)

# 4. ALWAYS tear it down — even on failure
bash scripts/worktree.sh cleanup "$WT"
```

Rules for this mode:

- Map affected SOURCE files to their tests (by naming convention and import/reference), and
  include changed TEST files directly. `scripts/worktree.sh tests` surfaces obvious test files;
  do the semantic source→test mapping yourself.
- If nothing is affected, say so and stop — do NOT silently probe the whole repo.
- Always `cleanup` the worktree (wrap the run so cleanup happens even if a probe throws). Never
  leave orphaned worktrees; `git worktree list` should be clean afterward.
- `--worktree` composes with `quick` / `focused` / `deep`.

## `--fix` (opt-in)

Default is diagnose-only. With `--fix`, propose a MINIMAL test patch that closes the proven gap,
then verify all three: (a) the new/changed test passes on original code, (b) it fails on the
relevant broken variant, (c) the existing suite stays green. This prevents writing a test
tailored to one syntactic mutant. Never auto-apply without these three checks passing.

## Output

Report the contract, the baseline, each probe with its one-line change and result
(`detected` | `survived`), the diagnosis token with findings, and (if requested) the suggested
test change. Use a compact structured block:

```yaml
test: cancels_unpaid_order
scope: integration
contract:
  description: "Cancelling an unpaid order persists CANCELLED and issues no payment"
  confidence: high
  sources: [test name, public service contract, domain state machine]
baseline: { status: passed, command: "<cmd>", runs: 2 }
probes:
  - { id: reachability, change: "throw at OrderService.cancel", result: detected }
  - { id: remove-persistence, change: "skip repository.save", result: survived }
  - { id: invert-payment-condition, change: "initiate payment for unpaid order", result: detected }
diagnosis:
  status: WEAK_ORACLE
  findings: ["verifies returned status but not persisted state"]
suggested_test_change: ["reload the order from persistence and assert CANCELLED"]
confidence: high
```

State the diagnosis honestly: prefer `INCONCLUSIVE` or `ORACLE_UNCLEAR` over a false `HEALTHY`.

## References

Read these as needed (one level deep):

- `references/probes.md` — the probe catalog (effect removal, decision inversion, boundary, result
  error, failure-path, metamorphic) with language-agnostic examples. Read when choosing probes.
- `references/levels.md` — unit / integration / e2e specifics, dual observation for e2e, and which
  diagnoses apply per level. Read when determining what to probe at a given level.
- `references/diagnoses.md` — the full diagnosis enum, when each applies, and the proof matrix
  (healthy-code vs broken-code expectations). Read when classifying the result.
