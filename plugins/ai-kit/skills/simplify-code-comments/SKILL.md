---
name: simplify-code-comments
description: Keep code comments signal-only in any programming language — never write comments that restate the code, and delete existing noise comments instead of rewriting them. Use when writing or generating code (to avoid producing filler comments), when asked to clean up, simplify, or remove comments, or when reviewing code for comment noise. Preserves doc comments (JSDoc, docstrings, javadoc, rustdoc, godoc), "why" comments, ticket/ADR anchors, and deprecation notices.
model: sonnet
---

# Simplify Code Comments

A comment is either **signal** (context the code cannot express) or **noise** (a restatement of what the code already says). The decision is binary: noise gets deleted, signal stays untouched. There is no third option — never rewrite, shorten, "improve", or replace a noise comment with a better one.

## The Two Rules

**Rule 1 — When writing code: default to no comments.** Self-documenting names carry the "what". Write a comment only when it holds a non-obvious "why" that the code cannot express. If tempted to explain *what* a line does — rename the variable/function instead, don't comment. If the code is reasonably clear as-is, write nothing and move on; do not add a comment "for readability".

**Rule 2 — When cleaning existing code: delete noise, don't polish it.** A noise comment is removed wholesale. Do not:

- rewrite it more concisely
- move its content into a doc comment
- replace it with a "better" comment
- refactor the surrounding code to "make the comment unnecessary" (unless refactoring was the actual task)

And do not over-trim: this is not a minimization contest. Comments classified as signal stay **verbatim** — no tightening their wording, no merging, no translation. If a pass over a file finds no noise, change nothing.

## What Is Signal (keep, untouched)

- **Non-obvious "why"**: an invariant or pitfall that is easy to break (race conditions, hydration mismatches, ordering requirements, platform quirks)
- **Business rules** not derivable from the code — why a boundary/condition is exactly this
- **Hidden behavior**: side effects, call-order or environment requirements
- **Ticket/ADR/doc anchors** (`JIRA-1234`, `see docs/adr/...`) — context links
- **Workarounds** with the cause and the removal condition
- **Doc comments on public API** (JSDoc, docstring, javadoc, rustdoc, godoc, XML docs): purpose, contract, units, error behavior, constraints — anything beyond what the signature/types already state
- **Deprecation notices** with a replacement pointer
- **Tooling directives**: `# noqa`, `// eslint-disable`, `#pragma`, `// nolint`, license headers, shebangs, code-generation markers

When genuinely unsure — especially if the comment makes a domain or historical claim that cannot be verified from the code — keep it. Deleting real context is worse than tolerating borderline noise.

## What Is Noise (delete, don't improve)

- Restating what a line/branch/condition does: `// increment counter`, `# loop over users`, `// hide subscription when complete` above the exact condition
- Translating an identifier into prose: `// getUserById gets user by id`
- Doc comments that duplicate the signature: `@param userId — the user id`, `:returns: the user`, docstring `"""Gets user by id."""` on `get_user_by_id`
- Section banners: `// ==== helpers ====`, `# imports`
- Narrating obvious structure: `// constructor`, `// return the result`, `// end of loop`
- Commented-out code with no explanation of why it's kept
- Change-log narration: `// updated to use new API`, `// fixed bug`

Note the doc-comment distinction: a doc comment that only mirrors the signature is noise; the same doc comment stating a contract, unit, or constraint beyond the signature is signal. Judge by content, not by form.

## Examples

Noise — delete the comment, leave the code exactly as-is:

```tsx
// show slider only on mobile
{isMobile ? <SeriesSlider /> : null}
```

```python
def get_user_by_id(user_id: str) -> User:
    """Gets a user by id."""   # noise: duplicates the signature — delete the docstring
```

Signal — keep verbatim:

```ts
// pda flag, not useBreakpoint: that one defaults to desktop on SSR → hydration
// mismatch for the server-streamed slider slot
const isPDA = useAppSelector(s => s.browser.pda);
```

```python
def get_device_id() -> str:
    """Long-lived device identifier; survives login/logout.

    Analytics/anti-fraud only — never use for authorization (see ADR-014).
    """
```

## Cleanup Procedure

When asked to clean comments in existing code:

1. Walk the target files; classify each comment as signal or noise using the lists above.
2. Delete noise comments — the comment only, never the code under it.
3. Leave signal comments byte-for-byte unchanged.
4. Do not rename, refactor, or reformat anything else; the diff must contain only comment deletions.
5. If asked to review rather than edit, report noise comments as `file:line` with the verdict "delete" — no proposed rewrites.
