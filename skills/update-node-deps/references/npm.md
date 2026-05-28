# npm reference

**Lockfile:** `package-lock.json`
**Detection:** `package-lock.json` present and no pnpm/yarn/bun lockfiles.
**Workspaces flag:** `-w <name>` for a single workspace, `-ws` for all workspaces.

## List outdated (JSON)

```bash
npm outdated --json || true
```

`npm outdated` exits **1** when anything is outdated — always OR with `|| true`.

Shape:

```json
{
  "lodash": {
    "current": "4.17.20",
    "wanted": "4.17.21",
    "latest": "4.17.21",
    "dependent": "my-app",
    "location": "node_modules/lodash",
    "type": "dependencies"
  }
}
```

The top-level keys are package names. `wanted` respects the semver range in `package.json`; `latest` ignores it. We target `latest` when classifying.

## Security audit (JSON)

```bash
npm audit --json || true
```

`npm audit` also exits non-zero when vulnerabilities exist. Relevant shape:

```json
{
  "vulnerabilities": {
    "<pkg>": {
      "severity": "high",
      "fixAvailable": { "name": "<pkg>", "version": "<fixed-version>" }
    }
  }
}
```

Map `fixAvailable.version` back to Step 7 categorization to know which advisories get resolved by which tier.

## Apply — patch tier (batch)

```bash
npm update                     # only goes to 'wanted' (semver range)
```

If a patch advisory requires going beyond `wanted`, install the exact version instead:

```bash
npm install <pkg>@<patch-version>
```

## Apply — minor tier (per-package to exact latest)

```bash
npm install <pkg>@<minor-latest>
```

Do NOT run `npm update` for minors — it won't cross the `^` caret boundary when the installed `wanted` is already the cap.

## Apply — major tier (per-package)

```bash
npm install <pkg>@<major-latest>
```

Peer-dep errors: if `ERESOLVE` fires, STOP. Do not apply `--legacy-peer-deps` or `--force` without explicit user approval — those flags hide real incompatibilities.

## Verify install

```bash
npm install  # re-idempotent; lockfile should already be consistent after the install-above commands
```

## Known quirks

- `npm update` caps at `wanted`, not `latest`. Always use `npm install <pkg>@<exact-version>` for cross-range moves.
- `npm ls <pkg>` to inspect why a sub-dep pins a version (useful when a direct update doesn't propagate).
- For workspaces: `npm install <pkg>@<version> -w <workspace-name>` targets one workspace only.
- `npm audit fix --force` sometimes downgrades unrelated packages — do NOT use it.
