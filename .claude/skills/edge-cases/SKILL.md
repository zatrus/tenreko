---
name: edge-cases
description: Systematically find edge cases and race conditions for a spec, a user story, a function, a file, or a diff - before code is written (to draft REQs) or after (to find untested cases). Goes through a fixed checklist (empty/null, boundaries, text/Unicode, numbers/money, time zones/DST, duplicates/order, external failures, permissions/state, repeats/concurrency) and turns each finding into an EARS REQ or a test task. Use when writing requirements, before implementing tricky logic, or when reviewing code that touches shared state.
argument-hint: "<spec folder | REQ/story ID | file or function | 'diff'>"
---

# /edge-cases: what breaks this?

Target: **$ARGUMENTS** (empty = the active spec in `docs/state/NOW.md`).

## 1. Pick the mode
- **Before code** (target is a spec or a story): output is rows for the *Edge cases* table in `requirements.md` and draft EARS REQs.
- **After code** (target is a file, function, or `diff` = `git diff main...HEAD`): read the code itself, because the code shows cases nobody wrote down. Output is the cases that no test covers. Use `explorer` to find the callers and tests if the target is wider than 2 or 3 files.

## 2. Go through every category
For each one, write concrete cases for *this* target, or `N/A: <reason>`. Never skip a row silently.

| Category | Ask |
|---|---|
| Empty, null, missing | What if it's empty, absent, or null? Which fields are optional, really? |
| Boundaries | What happens at 0, 1, the limit, limit+1, negative? First and last page? |
| Text | Whitespace only, 10 000 characters, emoji, combining accents, RTL, different case, Unicode normalisation (`é` as one or two code points), SQL/HTML/path injection |
| Numbers and money | Rounding mode, precision (never float for money), overflow, division by zero, currency mix |
| Time | Which zone is "today"? DST jump (a missing or repeated hour), Feb 29, end of month, expiry at exactly the boundary instant, server and client clocks differ |
| Collections and order | Duplicates, unsorted input, 1 million items, result order stable between calls? |
| External failures | Timeout, dependency down, malformed response, retry after the first call partly succeeded |
| Permissions and state | Not logged in, someone else's resource, already deleted, invalid state transition (cancel a shipped order) |
| Repeats and concurrency | Double click, client retry, the same message delivered twice, two users changing the same row at once, the last item in stock |

## 3. Concurrency: find the shared state
For each piece of shared mutable state (DB row, counter, balance, stock, unique name, file, cache, a call with an external side effect):
1. **Invariant:** what must always be true? ("stock ≥ 0", "one active subscription per user", "an order is charged at most once")
2. **Interleaving:** write the two-request timeline that breaks it, step by step:
   `A reads stock=1 · B reads stock=1 · A writes 0 · B writes 0 → two items sold, one in stock`
3. **Mechanism:** pick the simplest atomic one (constitution article 11). Patterns and tests per stack: [references/concurrency.md](references/concurrency.md).
   - conditional update: `UPDATE … SET stock = stock - :n WHERE id = :id AND stock >= :n` → check the affected row count
   - unique constraint (one active subscription, unique username, idempotency key)
   - optimistic locking (version column) when the update logic is complex
   - `SELECT … FOR UPDATE` when several rows must change together
   - idempotency key for retries and duplicate deliveries of anything with side effects (payments, emails)
4. **Loser:** what does the request that loses get? (409 problem+json, a retry, the stored first response)

"Check in code, then write" (`if (stock > 0) save(stock - 1)`) and `@Transactional` alone are **not** mechanisms.

## 4. Turn findings into work
- **Before code:** add each relevant case to the *Edge cases* table with a new EARS REQ, usually `IF <case> THEN the system shall <response>`. Concurrency REQs name the invariant and the loser's result. Anything you're unsure about goes to *Open questions*. Don't decide business behaviour yourself (e.g. "should a cart reserve stock?").
- **After code:** for each untested case, say whether the current code handles it (VERIFIED by reading the line) and propose a test. Behaviour the spec doesn't define → propose a REQ change and wait for GO. Don't write the fix in this skill.

## 5. Ask the human
Always end with:
> These are the cases I found. **Which did I miss?** Your domain knowledge beats my checklist: real production data, odd customers, legacy imports, local rules (tax, calendars, holidays).

## Report
```
Edge cases: <target> (before code | after code)
Covered: <categories with REQ IDs or tests>
New: <n> proposed REQs / tests (list)
Races: <invariant> — <mechanism> — <test> (or "no shared mutable state")
Open questions: …
Delegated: …
```
