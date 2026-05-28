# yarn reference

**Lockfile:** `yarn.lock`
**Classic vs Berry detection:**
- `yarn --version` starts with `1.` → **classic (v1)**
- `yarn --version` is `2.x`, `3.x`, `4.x` → **berry** (usually with `.yarnrc.yml` present)

The command surface differs significantly between classic and berry. Pick the right section below.

---

## Yarn Classic (v1)

### List outdated

```bash
yarn outdated --json || true
```

Yarn classic emits **NDJSON** (newline-delimited JSON), one record per line. Filter for lines where `type == "table"` — the `data.body` array has rows `[name, current, wanted, latest, packageType, url]`.

### Security audit

```bash
yarn audit --json || true
```

Also NDJSON. Filter lines where `type == "auditAdvisory"` — `data.advisory` has `module_name`, `severity`, `patched_versions`.

### Apply — patch tier

```bash
yarn upgrade                           # caps at semver range
```

Or per-package to a specific patch:

```bash
yarn upgrade <pkg>@<patch-version>
```

### Apply — minor / major tier

```bash
yarn upgrade <pkg>@<version>
```

### Verify install

```bash
yarn install --frozen-lockfile=false
```

### Classic quirks

- `yarn upgrade-interactive` exists but is interactive (TUI) — don't use it, the skill drives the flow.
- `yarn upgrade --latest` crosses the semver range for the entire project — too broad; prefer per-package.

---

## Yarn Berry (v2/v3/v4)

### List outdated

Berry does NOT have built-in `yarn outdated`. The supported path is the official plugin:

```bash
yarn plugin import https://raw.githubusercontent.com/mskelton/yarn-plugin-outdated/main/bundles/@yarnpkg/plugin-outdated.js
yarn outdated --format json || true
```

If the user has not installed the plugin, inform them and ask for permission before running the `plugin import`. If they decline, fall back to parsing `yarn info <pkg> --json` per package — slower but needs no plugin.

### Security audit

```bash
yarn npm audit --json --recursive || true
```

NDJSON output with `advisories` keyed by package.

### Apply — patch / minor / major

Berry uses `yarn up`, not `yarn upgrade`:

```bash
yarn up <pkg>@<version>
```

For workspace-scoped:

```bash
yarn workspace <workspace-name> up <pkg>@<version>
```

### Verify install

```bash
yarn install --immutable=false
```

### Berry quirks

- `yarn up <pkg>` (no version) bumps to the `^latest` range — equivalent to minor/major-crossing bump. Prefer the explicit `@<version>` form for clarity.
- `workspace:^` / `workspace:*` protocol — local packages; skip.
- Berry's Plug'n'Play (`pnp.cjs` file present) may require `yarn dlx` instead of `npx` for one-off tools during verification.
