# Probing by Test Level

The level determines what is worth probing and which diagnoses apply. Identify the level first.

## Contents

- [Unit tests](#unit-tests)
- [Integration tests](#integration-tests)
- [End-to-end tests](#end-to-end-tests)
- [Dual observation](#dual-observation)

## Unit tests

Fast and isolated. Probe the logic the unit owns.

Priorities: return values, branch decisions, boundary conditions, thrown errors, state
transitions, and business-meaningful collaborator calls.

Typical probes:
- Return a wrong value (correct → default/neutral).
- Invert one branch.
- Remove a state update.
- Replace a domain constant.
- Remove a validation step.
- Suppress an exception that should propagate.

Extra check — **observable vs scripted**: does the test assert the *observable result*, or only
*how* the implementation drives its mocks? Break the observable result while leaving the call
sequence intact:
- If the test passes with a broken observable result but fails only when internal call order
  changes → `OVERMOCKED`. The test is pinned to the implementation, not the contract.

Mocks are fine for speed and isolation; over-specifying internal interactions makes tests brittle
and blind to real regressions.

## Integration tests

The value is in the REAL boundary between components. First, classify each dependency:

| Dependency | Real? |
|------------|-------|
| database | real / test container / in-memory / mock |
| message broker | real / fake / mock |
| HTTP dependency | stub / real service |
| filesystem | temporary / real / mocked |

If the "integration test" has mocked away ALL integration boundaries, it is not testing
integration → `MISCLASSIFIED_TEST_SCOPE` or `BOUNDARY_NOT_TESTED`.

Typical probes (aim them at the boundary):
- Don't persist the record.
- Don't commit the transaction.
- Use the wrong mapper / serializer.
- Pass the wrong dependency identifier.
- Make the external adapter return an error.
- Skip a rollback.
- Read stale state.
- Break the serialization contract.

A strong integration test reads back through the real boundary (e.g. reloads the row it claims to
have written) rather than trusting the return value of the call under test.

## End-to-end tests

Full source-level probing is too costly and noisy here, and e2e tests are slower and flakier than
unit/integration. Do **1–3 high-level fault injections** instead:

- Backend returns an error.
- Persistence operation is disabled.
- Authorization decision is inverted.
- API response omits a required field.
- An event is not delivered.
- A UI action does not trigger the backend operation.

For each, verify not just the UI signal (toast appeared / button disappeared / page changed) but
the corresponding **observable outcome** (record persisted / state changed / message emitted /
access denied / payment not initiated). A test that only checks the UI signal can pass while the
backend silently did nothing.

## Dual observation

For critical e2e flows, assert BOTH ends of the same fact:

```
UI displays "Order cancelled"
+ API/database confirms status == CANCELLED
+ payment service received no charge request
```

If a probe disables the backend effect and only the UI assertion still passes, the test has a
`WEAK_ORACLE` for that flow — it is watching the screen, not the system.
