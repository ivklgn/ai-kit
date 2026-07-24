---
name: explain-branch-changes
description: "Explain the current git branch's changes in plain product language for a non-technical audience — no file paths, no code references, no jargon. Reads the branch diff, commits, and available docs, then produces a short human briefing about what changed and why it matters. Use when the user invokes /explain-branch-changes, asks what a branch does in simple terms, needs a product summary of changes for a PM / designer / stakeholder / support, or says things like 'объясни ветку простыми словами', 'что поменялось для пользователей', 'explain this branch to a non-developer'. Works with any codebase, language, and project structure. NOT for code review or technical diff analysis — use load-branch-changes for that."
model: sonnet
---

# Explain Branch Changes

Turn the current branch's changes into a briefing a person who has never seen code can read. The reader may be a product manager, designer, support agent, marketer, or executive. They care about what changes for users and the business — never about how the code does it.

Write the briefing in the language the user communicates in. If the user writes in Russian, the briefing is in Russian.

The process:

1. Collect the branch changes (git)
2. Mine the changes and project docs for product meaning
3. Translate to human language and deliver the briefing

## Step 1: Collect the Changes

Detect the base branch and gather the raw material:

```bash
BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
if [ -z "$BASE" ]; then
  BASE=$(git rev-parse --verify main >/dev/null 2>&1 && echo main || echo master)
fi
git log $BASE..HEAD --pretty=format:"%h %s%n%b"
git diff $BASE...HEAD --stat
git diff $BASE...HEAD
```

Include uncommitted work (`git status --short`, `git diff HEAD`) if present — the reader wants the state of the branch, not just its commits.

Handle the edge cases in the reader's terms, not git's:

- **Not a git repository** → say this folder has no change history to read, and stop.
- **On the base branch / no changes** → say there is no work-in-progress here; offer to describe what shipped recently (last ~10 commits on the base branch) instead.
- **Huge diff** (thousands of lines) → work from `--stat`, commit messages, and targeted reads of the most-changed and most user-facing files. Never skip Step 2 because the diff is big.

## Step 2: Mine for Product Meaning

The diff says what changed; the surrounding context says why. Gather both:

- **Commit messages and branch name** — often contain the intent and ticket IDs.
- **PR description** — `gh pr view` if a PR exists (ignore errors if not).
- **User-visible strings in the diff** — UI labels, button texts, error messages, emails, notification texts, translation files. These are the single best source for a product summary: they show exactly what a user will see.
- **Docs touched or nearby** — README, CHANGELOG, docs/, design docs, `.archcore/` or similar knowledge bases. If the project documents the changed area, read it to name features the way the project names them.
- **Tell-tale files** — migrations (data storage changed), feature flags (built but switched off), config/infra files, dependency manifests, test-only changes. See [references/change-types.md](references/change-types.md) for how to recognize and phrase each type.
- **The code itself** — read enough of the changed code to understand the actual behavior change. Use it for understanding only; none of it surfaces in the output.

Do not guess. If the diff shows a change whose purpose is unclear even after reading context, describe the observable effect and mark it as an assumption ("судя по всему" / "it looks like").

## Step 3: Translate and Deliver

Consult [references/change-types.md](references/change-types.md) to phrase each kind of technical work in human terms, then write the briefing.

### Hard rules

- **No code artifacts.** No file paths, function or class names, commit hashes, branch names, library names, or line references anywhere in the output.
- **No jargon.** Words like refactoring, endpoint, dependency, migration, API, backend, deploy, merge do not appear. Every such concept has a plain-language equivalent in the reference file.
- **Every point answers "so what?"** — what a person will notice, or why the business should care. A change with no observable or business effect is grouped under invisible work.
- **Fact-lock.** Describe only what the diff and context actually show. Never invent features, numbers, or motivations. Uncertainty is stated, not papered over.
- **Separate visible from invisible.** Users notice some changes (new screens, texts, fixed bugs); other work is internal (cleanup, groundwork, tooling). Present invisible work honestly as "you won't see this, but it matters because…" — never dress it up as a user feature.

### Briefing format

Sensible default — adapt, drop empty sections, keep the whole thing readable in under a minute:

**[One sentence: what this branch is about, as a headline]**

**What users will see** — bullets of observable changes, each phrased as what a person will see or experience.

**Invisible work** — internal changes in benefit terms (stability, speed, easier future changes).

**Worth knowing** — status and caveats in plain terms: the feature is built but switched off; the work looks unfinished; part of the change touches how data is stored, so the release needs extra care.

Section titles go in the user's language (Russian: «Что увидят пользователи», «Невидимая работа», «Стоит знать»).

### Writing style

Plain speech, not a press release and not a report:

- Everyday words, active verbs. "Теперь письмо приходит сразу", not "реализована оптимизация процесса отправки уведомлений".
- Concrete over abstract: name the screen, the button, the situation — as a user would name them.
- No empty amplifiers ("значительно улучшает", "ключевая функциональность") and no "не просто X, а Y" constructions.
- Short. 100–250 words for a typical branch. One small fix deserves two sentences, not a report.

### Example

Diff shows: new `PasswordResetController`, an email template, rate-limiter middleware, 12 new UI strings, a DB migration adding a `reset_tokens` table, plus dependency bumps.

Briefing (user communicates in Russian):

> **В приложении появляется восстановление пароля.**
>
> **Что увидят пользователи**
> - На экране входа появилась ссылка «Забыли пароль?». По ней приходит письмо со ссылкой для смены пароля.
> - От слишком частых попыток восстановления стоит защита: после нескольких запросов подряд придётся подождать.
>
> **Невидимая работа**
> - Приложение запоминает выданные ссылки на смену пароля, чтобы каждая работала один раз и недолго. Это про безопасность.
> - Обновлены готовые компоненты от сторонних разработчиков: плановая гигиена.
>
> **Стоит знать**
> - Меняется устройство хранения данных, поэтому выпуск этой версии потребует от команды чуть больше внимания, чем обычно.
