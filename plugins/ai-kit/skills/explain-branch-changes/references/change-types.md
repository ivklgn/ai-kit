# Change Types: Recognition and Human Phrasing

How to recognize common kinds of technical work in a diff, and how to phrase each for a reader who does not know code. Phrasing examples are in English — adapt them to the user's language, keeping the same register: plain, concrete, honest.

## Contents

- [New feature](#new-feature)
- [Bug fix](#bug-fix)
- [UI / copy changes](#ui--copy-changes)
- [Refactoring / cleanup](#refactoring--cleanup)
- [Performance](#performance)
- [Security](#security)
- [Database migration](#database-migration)
- [Feature flag](#feature-flag)
- [Dependency updates](#dependency-updates)
- [API / integration changes](#api--integration-changes)
- [Tests only](#tests-only)
- [CI / build / tooling](#ci--build--tooling)
- [Configuration / infrastructure](#configuration--infrastructure)
- [Localization](#localization)
- [Analytics / telemetry](#analytics--telemetry)
- [Accessibility](#accessibility)
- [Documentation](#documentation)
- [Work-in-progress signals](#work-in-progress-signals)

## New feature

**Signals:** new files forming a coherent unit (screen + logic + strings), new routes/screens, new UI strings, commit messages with feat/add.

**Phrasing:** lead with what the person can now do and where. "You can now export a report to PDF from the order page." Name the screen or flow the way a user would, not the way the code does.

## Bug fix

**Signals:** commit messages with fix/bug/issue numbers, small targeted diffs, new regression tests reproducing a scenario.

**Phrasing:** describe the misbehavior from the user's seat and say it no longer happens. "Before: the app sometimes showed yesterday's prices after midnight. Now it shows current ones." If the broken scenario is unclear, say a malfunction in that area was fixed — without inventing symptoms.

## UI / copy changes

**Signals:** changes to templates, stylesheets, component markup, string literals, image assets.

**Phrasing:** the most directly tellable kind of change — quote the actual new texts and describe layout changes plainly. "The confirmation button now says 'Place order' instead of 'Submit'." Changed strings in the diff are exact facts; use them.

## Refactoring / cleanup

**Signals:** many files changed with no behavior change, renames and moves, deleted code, commit messages with refactor/cleanup/simplify.

**Phrasing:** internal tidying — say nothing changes for users, and give the benefit: "Internal restructuring: the product behaves the same, but future changes in this area will be faster and safer." Never present it as a feature; never call it "refactoring."

## Performance

**Signals:** caching added, queries reworked, batching, lazy loading, commit messages with perf/speed/optimize.

**Phrasing:** what feels faster and where. "The order list opens noticeably faster, especially for customers with long histories." If no measured numbers exist in commits or the PR, do not invent any — say "faster," not "40% faster."

## Security

**Signals:** auth/permission checks added, input validation, token/session handling, rate limiting, secret handling, CVE mentions.

**Phrasing:** calm and non-alarming: "Protection was tightened around sign-in" — say what is now better protected, not how, and avoid implying there was a breach unless the context says so.

## Database migration

**Signals:** files under migrations/, SQL DDL, schema files, ORM model changes.

**Phrasing:** "The way the app stores its data is changing." Flag the operational consequence: releasing needs extra care, and rolling back is harder than usual. If data is deleted or transformed, say so explicitly — that is a business-relevant fact.

## Feature flag

**Signals:** flag/toggle names in code or config, conditions checking a flag, flag registry files.

**Phrasing:** "The feature is built but switched off — it can be turned on for everyone or for a test group without another release." This is a status fact readers genuinely need; always surface it.

## Dependency updates

**Signals:** lockfiles and manifests changed (package.json, go.mod, requirements.txt, Gemfile, pom.xml, etc.) with little or no code change.

**Phrasing:** "Updated ready-made components the app is built from — routine hygiene that keeps things secure and current." If a bump fixes a known vulnerability, fold it into the security phrasing.

## API / integration changes

**Signals:** changes to public endpoints, webhook contracts, exported schemas, SDK code, partner-facing formats.

**Phrasing:** who outside is affected: "The way partner systems talk to us is changing — partners may need to adjust on their side." A breaking change for external consumers is a business fact; flag it under "worth knowing."

## Tests only

**Signals:** only test files and fixtures changed.

**Phrasing:** "No product changes — the team strengthened its safety net that automatically catches mistakes before release."

## CI / build / tooling

**Signals:** pipeline configs (.github/workflows, .gitlab-ci.yml), Dockerfiles, linter/build configs, dev scripts.

**Phrasing:** "Improvements to the team's internal assembly line — helps ship updates faster and with fewer mistakes. Nothing changes in the product itself."

## Configuration / infrastructure

**Signals:** env files, deployment manifests, IaC (terraform/k8s), server settings.

**Phrasing:** "Changes to where and how the app runs." Surface user-relevant consequences if visible: capacity, reliability, a new region. Otherwise treat as invisible work.

## Localization

**Signals:** translation files (.po, .json, .strings, locales/), locale-switching logic.

**Phrasing:** "The app now speaks German" / "Translations were corrected." Name the languages — that's a product fact.

## Analytics / telemetry

**Signals:** tracking calls, event names, analytics SDKs, metrics/logging additions.

**Phrasing:** "The team will now see how people use [feature], to make better decisions about it." If the change expands what user data is collected, say so plainly — that can matter for privacy and legal.

## Accessibility

**Signals:** aria attributes, contrast/font changes, focus handling, screen-reader labels.

**Phrasing:** "The app becomes easier to use for people with impaired vision or those who navigate by keyboard."

## Documentation

**Signals:** only .md/docs files changed.

**Phrasing:** "The team's written guides were updated — nothing changes in the product."

## Work-in-progress signals

**Signals:** TODO/FIXME/WIP in the diff or commit messages, commented-out blocks, placeholder texts ("lorem", "test"), failing or skipped tests, "draft" PR status.

**Phrasing:** honesty over polish: "Parts of this look unfinished — it reads as work in progress, not something ready to release." Never present a half-built branch as done.
