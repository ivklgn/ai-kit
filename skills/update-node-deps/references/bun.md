# bun reference

**Lockfile:** `bun.lockb` (binary, older Bun) or `bun.lock` (text JSON, Bun 1.2+).
**Detection:** either lockfile present. `bun --version` to confirm toolchain.
**Workspaces:** `workspaces` field in `package.json`, same shape as npm. Workspace flag: `--filter <name>`.

## List outdated

```bash
bun outdated --json || true
```

Bun's `--json` output is stable in 1.1+. Each entry:

```json
{
  "name": "lodash",
  "current": "4.17.20",
  "update": "4.17.21",
  "latest": "4.17.21",
  "workspace": "."
}
```

Note: `update` is the semver-range equivalent of `wanted` in npm.

If the installed Bun version pre-dates JSON output, fall back to parsing the human-readable table from `bun outdated`.

## Security audit

Bun has `bun audit` (Bun 1.1+). Fall back to `npm audit` if unavailable — Bun's lockfile is compatible enough for npm to read deps, though it will complain about the missing `package-lock.json`. The cleanest fallback:

```bash
bun audit --json || true
```

If that errors (older Bun): tell the user, skip the audit step, note it in the report.

## Apply — patch tier (batch)

```bash
bun update                    # caps at semver range
```

For advisory-driven cross-range patches:

```bash
bun add <pkg>@<patch-version>
```

## Apply — minor tier

```bash
bun add <pkg>@<minor-latest>
```

Or `bun update --latest <pkg>` (Bun 1.1+) for an explicit cross-range bump.

## Apply — major tier

```bash
bun add <pkg>@<major-latest>
```

For workspace-scoped (Bun 1.1+):

```bash
bun add <pkg>@<version> --filter <workspace-name>
```

## Verify install

```bash
bun install --frozen-lockfile=false
```

## Known quirks

- `bun add` always rewrites `package.json` to the installed version — no surprise there, but confirm the version range format in `package.json` matches what the user wants (default is `^`).
- If both `bun.lockb` and `bun.lock` exist, Bun prefers `bun.lockb`. Ask the user to delete one.
- `bun install` respects `packageManager` in `package.json`. If set to a non-bun PM, Bun still installs but emits a warning; flag to the user.
- `workspace:*` protocol supported in Bun 1.1+ — skip local packages.
