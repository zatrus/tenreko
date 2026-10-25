---
name: spec-new
description: Phase 1 of spec-driven development. Turn a feature idea into docs/specs/NNN-slug/requirements.md with user stories, EARS acceptance criteria, NFRs, non-goals and open questions. Use when the user wants to start a new feature.
argument-hint: <feature idea in one or two sentences>
disable-model-invocation: true
---

# /spec-new: write requirements

Feature idea: **$ARGUMENTS**

## Steps

1. **Pick the folder.** Find the highest `docs/specs/NNN-*` number and use the next one. Slug = 2 to 4 kebab-case words. Create `docs/specs/NNN-slug/` and a **new** branch from an up-to-date `main`: `git switch -c feat/NNN-slug` (ask first if the working tree is dirty). The agent can push only to branches it creates this way. If the name already exists, pick another number or slug; never reuse someone else's branch.
2. **Understand before writing.** Read `docs/BUSINESS.md` (users, policies, terminology) and `docs/constitution.md`. Read the capability files in `docs/capabilities/` this idea touches: they describe current behaviour. Use the `explorer` agent to check the code matches them. If code and capability file disagree, report it in *Open questions*; don't pick one.
3. **Ask clarifying questions first** if the idea leaves out who the user is, the trigger, the expected outcome, or the failure behaviour. Ask at most 5 questions, in one message, each with a suggested default answer. Wait for the answers.
4. **Write `requirements.md`** from `docs/specs/_templates/requirements.md`:
   - Problem and goals: *why*, not *how*. No technology names.
   - *Capabilities* line: which capability files this adds to, changes (`CHECKOUT-3`), or retires. A new capability gets a name and a `PREFIX`.
   - Business facts (prices, limits, policies, legal duties) only from `docs/BUSINESS.md` or the human. Unknown → *Open questions*. Use its terminology; new terms go under *New terms*.
   - Optional `AC-x.y` Given/When/Then scenarios for multi-step or concurrent behaviour.
   - User stories, each with EARS criteria and IDs `REQ-<story>.<n>`. Cover the happy path, every error/unwanted case, and boundaries.
   - Measurable NFRs only.
   - Non-goals: at least one, to fence the scope.
   - **Edge cases:** go through every category of the *Edge cases* table (run the `/edge-cases` method on the stories). Each relevant case becomes an EARS REQ (usually `IF … THEN`); each irrelevant category gets `N/A: <reason>`. For *Repeats and concurrency*, name the invariant and what the losing request gets.
   - Anything you're unsure about goes in *Open questions*. Don't guess.
5. **Self-check** before showing it:
   - Each criterion is testable by an automated test, with a single behaviour per line.
   - No solution details have leaked in (endpoints, classes, libraries).
   - Every row of the *Edge cases* table has REQ IDs or an N/A reason. No empty cells.
6. Add the spec to the index in `docs/specs/README.md` with status `draft`. At the GO, add the *New terms* to the terminology table in `docs/BUSINESS.md`.
7. **STOP.** Show a short summary (stories, REQ count, open questions, and the edge cases covered, one line per category) and ask:
   > **Which edge cases did I miss?** Think of your domain: odd data you have seen in production, time zones, money, two users at once. Add them under *Added by the human at review* (I turn them into REQs).
   > Review `docs/specs/NNN-slug/requirements.md`. Reply **GO** to approve, or tell me what to change. Next step after GO: `/spec-design` (best in a fresh session).

Don't write design or code in this phase.
