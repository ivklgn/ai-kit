# Probe Catalog

Probes are deliberate, single-behavior breaks introduced to test whether a test notices. They are
**contract-related, not random** — each probe should correspond to a defect a real developer could
plausibly ship. Change exactly ONE behavior per probe, run the test, record `detected` (test
failed for the right reason) or `survived` (test still passed), then restore.

## Contents

- [Reachability probe](#reachability-probe)
- [Sensitivity families](#sensitivity-families)
- [Metamorphic relations](#metamorphic-relations)
- [Choosing a minimal set](#choosing-a-minimal-set)
- [Reading a probe result](#reading-a-probe-result)

## Reachability probe

Prove the test actually exercises the target before trusting any sensitivity result. Insert a
controlled sentinel at the target point in production code:

- `throw ProbeReached` / `panic("probe")` / `fail()` at the target line.
- Return an impossible sentinel value.
- Replace a critical side effect with an explicit failure.
- Fail immediately *before* the critical assertion to confirm the assertion path runs.

Expected: the test fails *because of the sentinel*. If it still passes, the test does not reach
the target → `NOT_EXERCISING_TARGET`. This is strictly stronger than line coverage.

## Sensitivity families

After reachability is confirmed, introduce plausible defects from these families.

### Effect removal — "the work silently doesn't happen"
- Skip a persistence write / `save` / `commit`.
- Drop a dependency call (don't emit the event, don't call the collaborator).
- Don't update the state field.
- Don't return the computed result (return the input / a default).

### Decision inversion — "the branch goes the wrong way"
- Flip a condition (`if x` → `if !x`).
- authorized → unauthorized; allowed → denied.
- success path → failure path.

### Boundary error — "off by one"
- `<` → `<=`, `>` → `>=`.
- `limit` → `limit ± 1`; `n` → `n - 1`.
- Inclusive/exclusive range flip.

### Result error — "the value is subtly wrong"
- Correct value → neutral / default (`0`, `""`, `null`).
- `true` → `false`.
- Non-empty → empty collection.
- Status `A` → status `B` (e.g. `CANCELLED` → `PENDING`).

### Failure-path error — "errors are mishandled"
- Swallow an exception that should propagate.
- Return success when a dependency fails.
- Skip a rollback / compensation step.
- Retry one fewer time; drop the timeout.

## Metamorphic relations

Use when an exact expected value is hard or expensive to pin, but a *relationship between runs*
is known. Break the relation and confirm the test (or an added check) notices:

- `sort(sort(x)) == sort(x)` (idempotence).
- `encode(decode(x)) == x` / `decode(encode(x)) == x` (round-trip).
- Adding an irrelevant item does not change the selected result.
- Raising a limit cannot shrink the result set.
- Reordering independent inputs does not change an aggregate output.
- Scaling all inputs by a constant scales the output predictably.

Metamorphic checks partially solve the oracle problem: they assert invariants without needing the
single "correct" output. Useful in `deep` mode and for hard-to-oracle numeric/ranking logic.

## Choosing a minimal set

For a fast developer loop, prefer a small, high-signal set over breadth:

- **quick**: 1 reachability + 2 contract-specific (effect removal / result error / decision
  inversion, picked by what the contract promises) + 1 boundary or failure-path probe.
- **focused**: 3–7 probes — add the failure/negative path and the most likely boundary.
- **deep**: add metamorphic relations, repeated runs, and test-order variation.

Bias probe selection toward what the *contract* claims. If the contract says "issues no payment",
the highest-value probe is "initiate a payment anyway" — not a random arithmetic tweak.

## Reading a probe result

- `detected` — test failed, and the failure is tied to the contract (not a build error, not a
  timeout, not a changed mock call order). Only contract-tied failures count as kills.
- `survived` — test still passed despite a real behavior change → a gap. Name the missing
  assertion.
- Failure via build/infra/timeout → `INCONCLUSIVE` for that probe; do not score it as a kill.
- Failure only because internal mock call order changed (observable result unaffected) → evidence
  of `OVERMOCKED`.
