# Diagnoses & Proof Matrix

Every health check ends in exactly one diagnosis token plus concrete findings. Do **not** emit a
mutation score from an agent-selected sample — it implies a coverage guarantee the probes do not
provide.

## Proof matrix

For each test, the evidence should line up like this:

| Check | Healthy code | Broken code (probe) |
|-------|--------------|---------------------|
| Test execution | PASS | FAIL |
| Target branch reached | yes | yes |
| Failure tied to the contract | — | yes |
| After restore | PASS | — |
| Re-run | stable | stable |

Bad shapes and what they mean:

| Observed | Meaning |
|----------|---------|
| PASS / PASS | Test is insensitive to the defect → gap. |
| FAIL / FAIL | Baseline already broken → fix baseline first. |
| PASS / random-FAIL | Likely flaky. |
| PASS / FAIL via infra timeout | Not proven the test detected the defect. |
| PASS / FAIL via changed mock call order | Test may pin the implementation, not the contract. |

## Diagnosis enum

Use these exact tokens.

- **`HEALTHY`** — The test reaches the target and reliably detects the probed defects, the oracle
  is contract-valid, and results are stable across re-runs. Only valid when the contract was
  clearly established.

- **`WEAK_ORACLE`** — The test executes the right code and reaches the target, but its assertions
  miss a real change in the result/effect (a sensitivity probe `survived`). E.g. it checks a
  returned status but not the persisted state. Name the missing assertion.

- **`NOT_EXERCISING_TARGET`** — The reachability probe survived: the test does not actually
  exercise the claimed behavior. Stronger signal than missing coverage.

- **`MISSING_NEGATIVE_PATH`** — The happy path is checked but the failure/error path is not (a
  failure-path probe survived). The test never asserts the error, rollback, or rejection.

- **`MISSING_BOUNDARY_CASE`** — A boundary probe (`<`↔`<=`, `limit ± 1`) survived. The test does
  not pin the edge.

- **`OVERMOCKED`** — The test passes despite a broken observable result and fails only when an
  internal mock call order changes. It verifies scripted interactions, not behavior.

- **`BOUNDARY_NOT_TESTED`** — An integration boundary that the test claims to cover is actually
  replaced by a mock/fake, so the real boundary is never exercised.

- **`ORACLE_UNCLEAR`** — No reliable source of expected behavior could be established (contract
  could only be inferred from the implementation, or not at all). Never report `HEALTHY` in this
  case — the test may faithfully pin a bug.

- **`MISCLASSIFIED_TEST_SCOPE`** — A test labeled integration/e2e behaves like a unit test (all
  boundaries mocked), or vice versa. Its name oversells what it verifies.

- **`FLAKY_OR_ORDER_DEPENDENT`** — The result depends on re-runs, test order, or shared state. The
  signal is not trustworthy until isolated.

- **`ENVIRONMENT_DEPENDENT`** — The test depends on wall-clock time, network, locale, a shared DB,
  or other external state, so its pass/fail is not self-contained.

- **`INCONCLUSIVE`** — A probe could not produce a trustworthy result (build error, infra timeout,
  could not isolate the change). Report what blocked it rather than guessing.

## Picking the token

1. Baseline red/flaky → `FLAKY_OR_ORDER_DEPENDENT` (or surface the broken baseline). Stop.
2. No reliable contract → `ORACLE_UNCLEAR`. Stop.
3. Reachability probe survived → `NOT_EXERCISING_TARGET`.
4. Scope mismatch (all boundaries mocked) → `BOUNDARY_NOT_TESTED` / `MISCLASSIFIED_TEST_SCOPE`.
5. Sensitivity probe survived → the most specific of `WEAK_ORACLE`, `MISSING_NEGATIVE_PATH`,
   `MISSING_BOUNDARY_CASE`, `OVERMOCKED`.
6. Probe unusable → `INCONCLUSIVE`.
7. All probes detected, contract clear, results stable → `HEALTHY`.

When more than one applies, report the most actionable one and list the others in `findings`.
