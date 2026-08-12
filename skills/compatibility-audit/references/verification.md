# Verification and Environment Checks

Static reading proposes; running gates disposes. Use this file for Step 5 (Environment) and Step 6 (Verify).

- [Order of operations](#order-of-operations)
- [Build and test gates by ecosystem](#build-and-test-gates-by-ecosystem)
- [Contract-diff tools](#contract-diff-tools)
- [Environment checks](#environment-checks)
- [Rollout compatibility](#rollout-compatibility)
- [When no gate exists](#when-no-gate-exists)
- [Recording results](#recording-results)

## Order of operations

1. Run the cheapest gate that can falsify a suspected blocker first — usually a typecheck or build of the consuming package.
2. Scope to what is affected. In a monorepo use the affected-package selector rather than building the world.
3. Only then run broader suites.
4. Never fix code to make a gate pass. A failing gate is the finding.

Do not run destructive commands. Migrations, deploys, `terraform apply`, publishing, and anything that writes to a shared environment are analyzed, never executed. Plan and dry-run modes are fine.

## Build and test gates by ecosystem

Pick by the manifests the scope resolver reported.

| Ecosystem | Typecheck / build | Tests | Affected-only |
|---|---|---|---|
| Node / TypeScript | `tsc --noEmit`, `<pm> run build` | `<pm> test` | `turbo run build --filter=...[BASE]`, `nx affected -t build`, `pnpm --filter '...[BASE]'` |
| Go | `go build ./...`, `go vet ./...` | `go test ./...` | package paths of consumers |
| Python | `mypy`, `pyright`, `python -m compileall` | `pytest` | `pytest <paths>` |
| Rust | `cargo check --all-targets` | `cargo test` | `-p <crate>` |
| Java / Kotlin | `mvn -q compile`, `gradle assemble` | `mvn test`, `gradle test` | module selectors |
| C# | `dotnet build` | `dotnet test` | project selectors |
| Ruby | `ruby -c`, `bundle exec rake` | `rspec` | file paths |
| PHP | `composer validate`, `phpstan` | `phpunit` | suite filters |
| Swift | `swift build` | `swift test` | target selectors |
| Terraform | `terraform validate`, `terraform plan` | `terraform plan` output review | `-target` |
| Kubernetes / Helm | `kubectl apply --dry-run=server`, `helm template`, `helm lint` | policy tests (`conftest`) | per chart |
| Docker | `docker build` | — | per image |
| Shell / CI | `shellcheck`, `actionlint`, `<ci> lint` | — | changed files |
| SQL migrations | migration tool's dry-run or `--sql` preview | migration test suite | per migration |

Use the project's own wrapper when one exists (`make check`, `just verify`, a `scripts/` entry, the CI workflow's steps). Reproducing what CI runs is stronger evidence than a command you invented — read the CI config and mirror it.

## Contract-diff tools

Run these only when the artifact and tool config are already present in the repo; do not install tooling for the audit. Normalize every output into the classification table in SKILL.md Step 2 — these tools report their own vocabulary of "breaking", which is not automatically your severity.

| Artifact | Tool | Command shape |
|---|---|---|
| OpenAPI | `oasdiff` | `oasdiff breaking <base.yaml> <head.yaml>` |
| Protobuf | `buf` | `buf breaking --against '.git#branch=<BASE>'` |
| GraphQL | `graphql-inspector` | `graphql-inspector diff <base.graphql> <head.graphql>` |
| Rust crate | `cargo-semver-checks` | `cargo semver-checks check-release` |
| Java | `japicmp`, `revapi` | build-plugin goal |
| Node package | `api-extractor`, `attw` | `api-extractor run`, `attw --pack` |
| Python | `griffe` | `griffe check <pkg> -a <BASE>` |
| Consumer contracts | Pact | `pact-broker can-i-deploy` |
| Database schema | migration tool diff, `atlas schema diff` | tool-specific |
| Terraform | `terraform plan` | look for `must be replaced` |

A tool reporting "no breaking changes" covers only the surface it understands — behavioral and data compatibility still need reading. Say so in the report rather than letting a green tool imply full coverage.

## Environment checks

Verify the change against what it runs on:

- **Toolchain floor** — did the change use syntax or stdlib features newer than the declared minimum? Compare against `engines`, `go` directive, `python_requires`, `rust-version`, target framework, or the version pinned in CI and Dockerfiles. A feature newer than the floor is a blocker even though it compiles locally.
- **Target platforms** — browsers and their baseline (browserslist), OS/arch matrix, mobile OS versions, container base image, serverless runtime version.
- **Dependencies** — new dependency added? Check license, maintenance, size/footprint where it matters, whether an existing dependency already does it, and conflicts in the resolved tree. Confirm the lockfile was updated.
- **Resources and limits** — memory/CPU limits, timeouts, connection-pool sizes, payload and rate limits the change could now exceed.
- **Secrets and permissions** — new env vars, secrets, scopes, or IAM permissions must exist in every environment before the code that reads them ships. A required variable with no default that is absent in staging is a blocker.
- **Feature flags** — is the new path flag-guarded, and is the default state safe? Is the flag defined in the flag system, not just in code?

## Rollout compatibility

Applies to anything deployed rather than released as a version: old and new must coexist.

Ask both directions explicitly:

- **Old reader, new writer** — can the previous version still parse what the new one produces? (added required field, changed enum, new format)
- **New reader, old writer** — can the new version still handle what is already stored or in flight? (rows, cache entries, queued messages, in-flight requests)
- **Rollback** — if this is reverted an hour after deploy, does the data written in that hour still work?
- **Ordering** — does the change require its migration, its config, or another service to deploy first? An undeclared ordering requirement is a blocker; the mitigation is to split the change into a compatible sequence (expand → migrate → contract).

Two-phase patterns are the standard mitigation: add the new field alongside the old, dual-write, backfill, switch readers, then remove the old field in a later release.

## When no gate exists

If the affected consumers have no build or test to run, the audit is not free to assume success:

1. Say so in Gaps, naming what is unverified.
2. Fall back to the strongest static evidence available — exhaustive grep of the symbol, reading each call site, checking the type declarations.
3. Downgrade the verdict accordingly. Unverified surface with a suspected blocker cannot yield COMPATIBLE.

Absence of tests is itself worth one Integration finding when the neighbours do have them.

## Recording results

Every command that ran goes in the Verification table with its verbatim outcome — pass, fail with the error count, or skipped with the reason. Do not paraphrase a failure into "some issues"; quote the first concrete error and cite the file and line it points at.
