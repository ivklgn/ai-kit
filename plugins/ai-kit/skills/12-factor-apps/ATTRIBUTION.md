# Attribution

This skill is a **port** of an existing community skill, kept here transparently.

## Original skill

- **Name:** `12-factor-apps` ("12-Factor App Compliance Analysis")
- **Author / publisher:** **anderskev** — <https://clawhub.ai/user/anderskev>
- **Published on:** clawhub.ai — <https://clawhub.ai/anderskev/12-factor-apps>
- **License / terms of use:** **MIT-0** (MIT No Attribution) — per the original skill card,
  "ready for commercial/non-commercial use."
- **Original version:** 1.0.0
- **Imported via:** clawhub download API (slug `12-factor-apps`), 2026-05-31

## Underlying methodology

The Twelve-Factor App methodology was created by **Adam Wiggins** (originally at Heroku)
and is published at <https://12factor.net>.

## What was ported

The clawhub download contained a self-contained `SKILL.md` plus a `skill-card.md` metadata
wrapper. `SKILL.md` here is a faithful port of that original content, with only these
changes for this repository:

- Added a `model:` field to the frontmatter (required by this repo's skill convention).
- Added the short "Source & attribution" note near the top of `SKILL.md`.
- Added a `/ai-kit:12-factor-apps` command wrapper (`commands/12-factor-apps.md`) so the
  skill can be invoked from both Claude Code and the Codex CLI.

The original is licensed **MIT-0**, which permits reuse without requiring attribution. We
keep attribution anyway, out of courtesy and transparency.

## Licensing of this port

- The original work's MIT-0 terms continue to apply to the ported content; credit for the
  original skill remains with **anderskev**.
- Additions authored in this repository (the command wrapper, frontmatter tweaks, and this
  file) are covered by this repository's MIT `LICENSE`.

If you are the original author and would like the attribution adjusted or this port
removed, please open an issue on this repository.
