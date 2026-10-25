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
2. **Understand before writing.** Use the `explorer` agent to find existing behaviour related to the idea, so requirements don't contradict what's already there. Read `docs/constitution.md`.
3. **Ask clarifying questions first** if the idea leaves out who the user is, the trigger, the expected outcome, or the failure behaviour. Ask at most 5 questions, in one message, each with a suggested default answer. Wait for the answers.
4. **Write `requirements.md`** from `docs/specs/_templates/requirements.md`:
   - Problem and goals: *why*, not *how*. No technology names.
   - User stories, each with EARS criteria and IDs `REQ-<story>.<n>`. Cover the happy path, every error/unwanted case, and boundaries.
   - Measurable NFRs only.
   - Non-goals: at least one, to fence the scope.
   - Anything you're unsure about goes in *Open questions*. Don't guess.
5. **Self-check** before showing it:
   - Each criterion is testable by an automated test, with a single behaviour per line.
   - No solution details have leaked in (endpoints, classes, libraries).
   - Every edge case listed has a matching REQ.
6. Add the spec to the index in `docs/specs/README.md` with status `draft`.
7. **STOP.** Show a short summary (stories, REQ count, open questions) and ask:
   > Review `docs/specs/NNN-slug/requirements.md`. Reply **GO** to approve, or tell me what to change. Next step after GO: `/spec-design` (best in a fresh session).

Don't write design or code in this phase.
