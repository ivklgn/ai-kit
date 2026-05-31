# pnpm reference

**Lockfile:** `pnpm-lock.yaml`
**Workspace config:** `pnpm-workspace.yaml` at the root.
**Workspaces flag:** `--filter <name>` for one; `--recursive` (or `-r`) for all.

## List outdated (JSON)

```bash
pnpm outdated --format json --long || true
```

Shape (map of package → info):

```json
{
  "lodash": {
    "current": "4.17.20",
    "latest": "4.17.21",
    "wanted": "4.17.21",
    "isDeprecated": false,
    "dependencyType": "dependencies"
  }
}
```

For workspace-wide in monorepos:

```bash
pnpm outdated -r --format json --long || true
```

## Security audit (JSON)

```bash
pnpm audit --json || true
```

Shape includes `advisories` keyed by numeric ID; each has `module_name`, `severity`, `patched_versions`.

## Apply — patch tier (batch)

```bash
pnpm update                   # caps at semver range (= wanted)
```

For advisory-driven patches that need to jump the range:

```bash
pnpm add <pkg>@<patch-version>
```

## Apply — minor tier

Prefer explicit per-package installs over `pnpm update --latest` so the PM writes the exact target version into `package.json`:

```bash
pnpm add <pkg>@<minor-latest>
```

Alternative batch (rewrites all direct deps to latest — use only when user approves ALL minors at once):

```bash
pnpm update --latest <pkg1> <pkg2> <pkg3>
```

## Apply — major tier

```bash
pnpm add <pkg>@<major-latest>
```

For workspace-scoped:

```bash
pnpm add <pkg>@<version> --filter <workspace-name>
```

## Verify install

```bash
pnpm install --frozen-lockfile=false
```

## Known quirks

- `pnpm update --latest` (or `-L`) is the cross-range equivalent. `pnpm update` alone caps at the semver range.
- `catalog:` / `catalogs:` entries (pnpm 9+ workspace catalogs) — DO NOT rewrite. Update the catalog entry in `pnpm-workspace.yaml` instead if the user asks.
- `workspace:*` / `workspace:^` protocol — local packages; skip entirely.
- `onlyBuiltDependencies` (pnpm 10+) — unrelated to updating, but noise in output; ignore.
- If `packageManager` pins a pnpm version that differs from the installed one, corepack will prompt; inform the user but do not auto-approve.
