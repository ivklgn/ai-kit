---
name: recap
description: Re-orient inside a long session — produce a dense five-slot status (goal, done, current step, open items, next step) written in the language of the session, plus an optional drill-down into any single item. Reads only what is already in context plus one git call, and never explores the codebase. Use when the user asks where we are, what we were doing, what the status is, where we stopped, what is left, to catch up or be reminded, or invokes recap; and when returning to a session whose earlier part is no longer fresh.
model: sonnet
allowed-tools: Bash(git status:*) Bash(git log:*)
---

# Recap

Everything needed is already in context. This skill is fast because it refuses to go looking for anything else.

## Speed contract

Run exactly one command, and only if the working directory is a git repository:

```bash
git status --short --branch && git --no-pager log --oneline -10
```

If it fails (not a repository), continue silently without it.

Never call Read, Grep, Glob, Edit, WebSearch, or any other tool. Never re-open files that were already discussed — the discussion is in context. Never launch a subagent. One command, then write the answer.

## Language

Write the recap in the language the **user** has been writing in this session, not the language of this skill. Mixed input follows the dominant language of the user's own messages. Translate the slot labels too — in Russian they read Цель / Сделано / Сейчас / Открыто / Дальше. Keep identifiers verbatim — file paths, branch names, commands, flags, library names, error strings.

## Level 1 — default output

No argument means the full status. Fill these five slots, in order:

**Goal** — what the user is actually trying to achieve, in their terms. One line. If the session pivoted, state the current goal and mark the pivot in a clause.

**Done** — 2–5 bullets, one line each. Each bullet is a *result*, not an activity: "found the built-in /recap, it is one line long" rather than "searched for skills". Where a decision was made, name the decision and its reason. Merge related steps into one bullet.

**Now** — the single thing in flight and how far it got. If the last turn completed cleanly, name that completed thing instead.

**Open** — 0–3 bullets of what is expensive to rediscover: approaches tried and rejected *with the reason*, unanswered questions, known traps, work deliberately deferred. Omit the whole slot when genuinely empty — never pad it.

**Next** — the immediate next action, concrete enough to start on. If a user decision is required first, name the decision instead.

Close with a one-line hint that any slot or topic can be expanded.

Hard limits: 15 lines total. No preamble ("Вот краткое резюме…"), no closing offer of help, no restating the request.

## Level 2 — drill-down

An argument names either a slot (`open`, `next`, `открыто`, `дальше`) or a topic word (`git`, `конвенции`). Expand only that, from the same context:

- Every relevant turn in order — what was tried, what came back, what it cost
- Exact artifacts: file paths, commands, versions, numbers, error text
- What was rejected along the way and why

One or two short paragraphs, or up to 8 bullets. Still no exploration: if the answer genuinely requires a file that is not in context, name the file and stop rather than reading it. If the argument matches nothing in the session, say so and list the topics that are available — never guess.

## Accuracy

Every statement traces to something in the session or to the git output. Nothing from memory alone, nothing inferred about what "probably" happened. Where the earlier part of the session was compacted into a summary, work from that summary as-is and do not reconstruct detail it dropped — if a slot is thin because of compaction, say so in three words rather than filling it.

## Edge cases

- **Fewer than three exchanges** — skip the template, answer in one line.
- **Two or more unrelated tasks** — run the template for the current task only, then a single closing line `Ранее в сессии: …` for the rest.
- **Session is one long task with no result yet** — the Сделано slot holds what was ruled out; that is a real result.
