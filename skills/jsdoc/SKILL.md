---
name: jsdoc
description: Write, fix, or review JSDoc documentation for JavaScript and TypeScript code. Detects whether the project uses typed JSDoc (plain JS with checkJs), TypeScript (docs without type duplication), or a doc generator (TypeDoc, JSDoc CLI), and documents accordingly. Use when adding JSDoc comments, documenting a public API, fixing doc/signature drift, or setting up doc generation.
model: sonnet
---

# JSDoc Skill

You are documenting JavaScript/TypeScript code with JSDoc. Good doc comments state the contract the signature cannot: meaning, units, invariants, error behavior, and examples. Bad doc comments restate the code. Produce only the first kind.

## Step 1: Detect the Documentation Mode

Read `package.json`, `tsconfig.json`/`jsconfig.json`, and a sample of existing doc comments. Pick the mode — it changes what a correct comment looks like:

**Mode A — Typed JSDoc (plain JS).** Signals: `.js` sources with `checkJs`/`// @ts-check`, or JSDoc types used for editor intellisense. Types live IN the comments and are load-bearing:
- Full type annotations: `@param {Map<string, number>} counts`, `@returns {Promise<User|null>}`
- `@typedef`, `@callback`, `@template` for shapes and generics; import types with `@typedef {import('./api').User} User` or inline `@type {import('./api').User}`
- Verify with `npx tsc --noEmit` (respecting the project's config) — typed JSDoc that doesn't check is worse than none

**Mode B — TypeScript sources.** Types live in the signature; JSDoc adds semantics only:
- NO type braces: `@param userId - The owner of the session`, never `@param {string} userId`
- Never repeat what the type already says; if a comment would only restate the signature, omit it
- TSDoc-flavored tags when the project uses TypeDoc/API Extractor (`@remarks`, `@internal`, `@alpha`/`@beta`)

**Mode C — Doc generator present.** `typedoc`, `jsdoc`, or `documentation` in devDependencies or scripts: match its tag dialect and config (entry points, `@group`/`@category` conventions), and verify the build (`npm run docs` or equivalent) emits without warnings.

Match existing comment style: sentence casing, hyphen after param name, blank lines, `@example` formatting. Consistency beats personal preference.

## Step 2: Decide What Deserves Documentation

Document, in priority order:

1. **Exported/public API** — everything a consumer can reach: functions, classes, methods, types, constants, component props
2. **Non-obvious contracts** — units (ms vs s), ranges, nullability semantics, mutation vs copy, ordering guarantees, idempotency
3. **Error behavior** — `@throws` with the condition, rejected promise reasons
4. **Deprecations** — `@deprecated` with the replacement and migration hint, never bare
5. **Tricky internals** — only where the "why" isn't recoverable from the code

Do NOT document: trivial getters, self-explanatory parameters (`@param name - The name` is noise), private helpers with obvious behavior, or generated code.

## Step 3: Write the Comments

Structure per symbol:

- First line: one-sentence summary in third person ("Parses…", "Returns…") — what it does for the caller, not how
- Blank line, then remarks only if genuinely needed: invariants, performance notes, links via `{@link Symbol}`
- Tags in stable order: `@template`, `@param`, `@returns`, `@throws`, `@deprecated`, `@example`, `@see`
- `@example` for any API whose usage isn't obvious from the signature — runnable, minimal, showing the common case
- Default values: prefer showing in the signature; mention in prose only when semantics are surprising
- Overloads/options objects: document each property (`@param opts.retries - …`); in Mode A use a `@typedef` for reused option shapes

## Step 4: Verify

- Mode A: run `tsc --noEmit` (or the project's typecheck script) — all JSDoc types must check
- Mode B/C: run the project's lint (`eslint-plugin-jsdoc` rules if configured) and doc build; fix every warning you introduced
- Re-read each comment against the implementation: every claim (units, errors, defaults) must be true NOW — auditing existing comments for drift is part of the job when reviewing

## Review Mode

When asked to review existing JSDoc rather than write it, walk the target files and flag with file:line:

- **Drift** — comment contradicts the current signature or behavior (wrong param names, stale defaults, removed throws)
- **Type duplication** in TS projects; **missing/unchecked types** in typed-JS projects
- **Noise** — comments restating the identifier; propose deletion
- **Gaps** — exported symbols with non-obvious contracts and no docs

Report as a table with a concrete fix per finding; apply fixes only when the user asked for fixes.
