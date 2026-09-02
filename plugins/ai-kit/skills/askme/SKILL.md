---
name: askme
description: Turn the current plan into a numbered list of what only the human can supply — decisions, facts only they know, credentials or access, data from systems the agent can't reach, and real-world or interactive actions — each with why the agent is blocked, which step it unblocks, the default if unanswered, and the exact reply shape. Works only from what is already in context; calls no tools and never explores the codebase. Use when the user asks what you need from me, what's blocked on me, give me my part, what are your questions, or says ask me what you need, or invokes askme; and proactively once the plan reaches a step that depends on a person.
model: sonnet
---

# Ask Me

Produce a list the human can work through without re-reading the session — every line on it must be something only they can do.

## Speed contract

Call no tools. Everything needed is in context: the goal, the plan, what was tried, what failed, what the user already said. Never Read, Grep, Glob, search, or launch a subagent to "check whether it's really needed" — if the session does not show the limit, the item does not exist yet.

## Language

Write in the language the **user** has been writing in this session, not the language of this skill. Mixed input follows the dominant language of the user's own messages. Translate the kind tags and labels — tags in Russian: Решить / Ответить / Доступ / Принести / Сделать; item labels: Причина (why me not you) / Блокирует / По умолчанию / Ответ; closing line: Пока жду. Keep identifiers verbatim — paths, commands, hostnames, branch names, error text.

## What qualifies

An item earns its place only when the session shows the agent genuinely cannot do it. Five kinds:

| Tag | The item is… | Typical sign in the session |
|---|---|---|
| **Decide** | a choice the user owns: product behaviour, scope, priority, spending, anything irreversible | two valid approaches, and picking one changes the work |
| **Answer** | a fact only the user has: intended behaviour, what production does, what a colleague agreed | the agent guessed, or asked and got no reply |
| **Access** | a credential, permission, VPN, MCP server that failed to connect, a tool call the user declined | an auth error, "server failed to connect", a denied permission |
| **Fetch** | data in a system the agent cannot reach: dashboard, email, chat thread, ticket, remote log, closed database | the plan needs a number or a file the session never contained |
| **Do** | an action in the world or in an interactive session: approve, merge, pass 2FA, run an interactive login, restart a box, look at a screen | the next step is a click, a signature, or `! <command>` |

Not an item:

- anything the agent can read, run, search, or try itself but simply hasn't yet — untried capability is never an item; only a failure already in the session earns one
- anything already answered earlier in the session, including inside a compacted summary
- anything a reasonable default resolves cheaply and reversibly — apply it, mention it in the closing line, skip the item (costly-to-reverse choices are **Decide** items instead — list them, defaulted)
- a repeat of a tool call the user already declined — that becomes one **Access** item asking *whether* to retry differently, never the same call again

## Item format

Numbered. Blocking items first, in plan order; non-blocking ones after. Each item, in this order:

1. **Tag + ask** — one line, actionable without context. Closed questions with options beat open ones; one ask per item, split compound requests, merge asks that one action resolves.
2. **Why me not you** — the concrete limit in one clause: `no ssh to prod from here`, `tool call declined`, `needs a product call`. Never a bare "I can't".
3. **Blocks** — the plan step(s) it gates, or `nothing — speeds up step N`.
4. **Default** — what happens if unanswered. For **Decide**, that default is the agent's recommendation.
5. **Reply** — the exact shape: a word, a number, a pasted output, a path, yes/no.

```
N. [Tag] <the ask, one line>
   Why me not you: <the concrete limit>
   Blocks: <step(s) it gates, or "nothing — speeds up step N">
   Default: <what happens if unanswered>
   Reply: <exact expected shape>
```

Close with two lines:

- **Meanwhile:** what the agent does now that needs none of the above — or `nothing, everything waits on 1`.
- one hint: reply by number; unanswered items take their default.

Hard limits: at most 8 items. More than that — keep the 8 blocking the most steps (ties: the earliest step), group the rest by where they'd be resolved (same system, same person) into one line, and say how many were folded. No preamble (not "Вот что мне нужно от тебя:"), no apology, no restating the plan.

## Argument

Empty → the full list. A plan step number or name, or a topic word → only items for that — numbers mean plan steps, never the list's own item numbers, which exist only for replying. `blocking` → only items that gate a step. An argument that matches nothing → say so and name the steps that do have items — never guess.

## Edge cases

- **Nothing needed** — one line: nothing needed, plus the next step the agent is taking.
- **No plan in context** — build the list from the goal. If the goal itself is unclear, that is item 1 and the only item.
- **Compacted context** — work from the summary as-is. If it records a question asked but not answered, the item goes back on the list with a note that it was asked before.
- **Two or more unrelated tasks** — build the list for the current task only.
- **Fewer than three exchanges** — skip the template, ask in one line.

## Accuracy

Every item traces to something in the session: a failed attempt, a declined call, a stated gap, a fork in the plan. Nothing from general caution, nothing "just in case". A list with one real item beats a list with five plausible ones.
