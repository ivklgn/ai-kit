---
name: update-golang-deps
description: Audit and update Go module dependencies using native go toolchain commands (go list, go get, go mod tidy) plus govulncheck for security. Auto-applies patch updates silently, asks before minor, and confirms each major individually. Cross-checks release notes via gh/Context7 and vulnerabilities before each batch. Handles v2+ module path changes (gopkg.in/, github.com/.../v2). Use when the user asks to update dependencies, bump modules, check outdated modules, or audit security in a Go project.
model: sonnet
---

# Update Go Dependencies

Audit and update Go module dependencies safely, one semver tier at a time. Use the native `go` toolchain plus `govulncheck` — no third-party wrappers.

## Step 1: Preflight

```bash
go version
```

Locate `go.mod`:

```bash
find . -name go.mod -not -path '*/vendor/*' -not -path '*/.git/*' -not -path '*/node_modules/*'
```

If multiple `go.mod` files are found (nested modules), ask the user which module to target, or whether to iterate all.

Check for `go.work`:

```bash
test -f go.work && cat go.work
```

If a workspace exists, ask whether to target a single module or iterate across the workspace.

## Step 2: Detect govulncheck

```bash
command -v govulncheck
```

If missing, inform the user and ask for approval to install:

```bash
go install golang.org/x/vuln/cmd/govulncheck@latest
```

If declined, proceed without the vuln scan — note it in the final report.

## Step 3: List outdated modules

```bash
go list -u -m -json all
```

This streams one JSON object per module (not a single array). Parse by splitting on `}\n{` or using a JSON stream parser. Relevant fields:

```json
{
  "Path": "github.com/stretchr/testify",
  "Version": "v1.8.0",
  "Update": { "Path": "github.com/stretchr/testify", "Version": "v1.9.0" },
  "Main": false,
  "Indirect": false,
  "Replace": null
}
```

**Default to direct dependencies only** (`Indirect: false`, `Main: false`). `go mod tidy` drags indirects along automatically after direct bumps. Only include indirects if the user explicitly asks.

**Skip** modules with a non-nil `Replace` — they point to a local path or forked repo and must be updated manually. Report them separately.

## Step 4: Run govulncheck (if available)

```bash
govulncheck ./... -format json
```

Parse the stream. Each `finding` event with `osv` populated is an advisory. Record:

```
{ module, vulnerable_ranges, fixed_in, severity, summary }
```

Map `fixed_in` to the outdated list so you know which advisories each tier's updates would resolve.

## Step 5: Categorize by semver

For each module with an `Update`, classify the jump from `Version` to `Update.Version`:

- **Patch**: `v1.2.3` → `v1.2.5`
- **Minor**: `v1.2.3` → `v1.3.0`
- **Major**: `v1.2.3` → `v2.0.0`

Additional Go-specific rules:

- **`+incompatible` suffix** (e.g., `v2.3.0+incompatible`): legacy pre-modules v2+. Treat as **major** and flag — these modules never adopted Go modules properly.
- **v2+ module path bump**: a module currently at `github.com/foo/bar` with `latest = v2.x.x` requires the import path to change to `github.com/foo/bar/v2` (Go modules convention SIV — semantic import versioning). Detect by comparing `latest` major ≥ 2 and current path has no `/vN` suffix. Handle in the major tier with special rewriting flow.
- **Pre-1.0** (v0.y.z): `v0.2.3` → `v0.2.9` = **patch**; `v0.2.3` → `v0.3.0` = **major** (not minor). Go pre-1.0 libraries make breaking changes between v0.y bumps.
- **`gopkg.in` modules**: versioning lives in the import path (`gopkg.in/yaml.v2` vs `gopkg.in/yaml.v3`). A jump from `v2` to `v3` requires a manual import path change, not a `go get`.

## Step 6: Fetch release notes (minor + major only)

Skip patches. For each minor and major update:

1. **`gh` for GitHub-hosted modules** (most common):
   ```bash
   gh release view v<X.Y.Z> -R <owner>/<repo>
   ```
   The module path `github.com/<owner>/<repo>` maps directly to the GitHub repo. For modules in subdirectories (e.g., `github.com/foo/bar/subpkg`), the release is on the repo root, sometimes tagged `subpkg/v<X.Y.Z>`.

2. **Context7 MCP** for well-known libraries (less coverage than npm, but fast when present):
   - `mcp__context7__resolve-library-id` with the module path
   - `mcp__context7__query-docs` with `query="changelog"` or `query="migration"`

3. **WebFetch fallback**:
   - `https://pkg.go.dev/<module>?tab=versions` — shows version list
   - `https://pkg.go.dev/<module>` — may link to changelog

Summarize each into one line with breaking changes flagged.

## Step 7: Apply updates in tiers

Apply in strict order: **patch → minor → major**. Run verification (Step 8) after each tier and after each individual major. On failure, offer rollback and stop.

### Tier 1 — Patches (auto-apply)

For each patch in the batch:

```bash
go get <module>@<patch-version>
```

Then tidy once:

```bash
go mod tidy
```

If a `vendor/` directory with `modules.txt` exists, also run:

```bash
go mod vendor
```

Report count after.

### Tier 2 — Minor (approval gate)

Present the full minor batch as a table (`Module | Current → Latest | Fixes advisory? | Release notes`). Ask the user: approve the batch, deselect specific modules, or skip tier. Apply each approved module with `go get`, then `go mod tidy` once at the end.

### Tier 3 — Major (per-module confirmation)

Iterate majors one at a time. For each, first classify:

**Case A — same module path** (module already at `/vN` or major is still v0/v1):
- Ask per-module: apply / skip / defer.
- If apply: `go get <module>@v<N>.0.0`, then `go mod tidy`, then verify.

**Case B — v2+ path change required** (current path has no `/vN`, new major ≥ 2):
- Show a LOUD warning: "This bump changes the import path from `github.com/foo/bar` to `github.com/foo/bar/v2`. Every `import` statement referencing this module in your code must be rewritten."
- Count affected files:
  ```bash
  grep -rl "\"<current-module-path>\"" --include='*.go' .
  ```
- Show the file count and ask: apply (rewrite imports + `go get`) / skip / defer.
- If apply:
  1. Update `go.mod`: `go get <new-module-path>@v<N>.0.0` (this adds the `/vN` path as a new dependency).
  2. Rewrite imports in source. Prefer `gofmt -r` for mechanical rewrites:
     ```bash
     gofmt -w -r '"<old-path>" -> "<new-path>"' .
     ```
     (Note: `gofmt -r` operates on expressions, not strings. For import-path rewrites specifically, a sed-based approach is more reliable — or use `goimports` after manual sed:)
     ```bash
     grep -rl "\"<old-path>\"" --include='*.go' . | xargs sed -i.bak "s|\"<old-path>\"|\"<new-path>\"|g"
     find . -name '*.bak' -delete
     ```
  3. `go mod tidy` — this should drop the old path from `go.mod`.
  4. Verify.
- **`gopkg.in` special case**: path changes like `gopkg.in/yaml.v2` → `gopkg.in/yaml.v3` follow the same rewrite flow — the "major" is encoded in the path segment.

## Step 8: Verify

After each tier (and after each individual major):

```bash
go build ./...
go vet ./...
```

Offer (don't force — can be slow):

```bash
go test ./...
```

On failure:
- Report the first 50 lines of error output.
- Offer rollback: `git checkout -- go.mod go.sum` and any source files changed for import rewrites. Then `go mod tidy` to re-sync.
- Do not proceed to the next tier.

## Step 9: Final report

```markdown
# Go Dependencies Update Report

**Module:** github.com/example/app
**Go version:** go1.24

## Applied
- patch: 8 modules (1 fixed advisory)
- minor: 3 modules
- major: 1 module (github.com/foo/bar → /v2, 14 imports rewritten)

## Skipped / deferred
- `github.com/old/lib` — has `replace` directive, manual update needed
- `github.com/big/lib` → v3 — deferred, requires app-wide migration

## Vulnerabilities (govulncheck)
- Resolved: 2 (GO-2024-XXXX critical, GO-2024-YYYY high)
- Remaining: 0

## Verification
- go build ./...: ok
- go vet ./...: ok
- go test ./...: not run (user declined)
```

## Guardrails

- **Never edit `go.sum` by hand.** Use `go get` / `go mod tidy` exclusively.
- **Never bypass git hooks. Never commit or push.**
- **Skip `replace` directives** — flag them in the report; user handles manually.
- **Respect `toolchain` directive** in `go.mod`: if an update requires a newer Go toolchain than the project's `toolchain` line, flag and skip.
- **`vendor/` mode**: if `vendor/modules.txt` exists, run `go mod vendor` after `go mod tidy` so the vendor tree stays in sync.
- **`GOFLAGS=-mod=vendor`**: detect via `go env GOFLAGS`; updates still work but the user must re-vendor.
- **GOPRIVATE / GOPROXY**: if the project uses a private proxy, `go list -u` and `go get` respect those env vars — no action needed, just noted.
