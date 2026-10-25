---
name: spec-tasks
description: Phase 3 of spec-driven development. Break an approved design.md into docs/specs/NNN-slug/tasks.md, a list of small, ordered, test-first tasks each traced to REQ IDs. Use after design.md has a GO.
argument-hint: "[spec number or folder; default = active spec]"
disable-model-invocation: true
---

# /spec-tasks: implementation plan

Spec: **$ARGUMENTS** (default: the active spec in `docs/state/NOW.md`).

## Preconditions
`requirements.md` and `design.md` are both `Status: approved`. Otherwise stop.

## Steps

1. Write `tasks.md` from `docs/specs/_templates/tasks.md`.
2. **Slice vertically** where possible: each task delivers a thin, testable piece of behaviour end-to-end, rather than "all the entities, then all the services".
3. **Order:** contracts/types → domain logic → adapters (DB, HTTP) → wiring/config → docs. Start with a walking skeleton if the feature is new.
4. **Each task:**
   - is one commit, small (aim for < ~150 changed lines), and leaves the gate green
   - lists `Covers: REQ-…`, the **test to write first**, the files to change, and the verify step
   - marks `[P]` only when it shares no files with other open tasks
5. **Coverage check:** fill the *Traceability* table skeleton. Every REQ and NFR appears in at least one task. If a REQ has no task, add one or ask.
6. Include tasks for: migrations (if any), config/env docs (`.env.example`), README/API docs updates, and observability (logs/metrics) when the design calls for them.
7. Update `docs/state/NOW.md` (phase: tasks).
8. **STOP.** Show the task list (titles and REQ refs only), then ask:
   > Reply **GO** to approve. Next: `/spec-implement` (runs tasks one by one), or `/spec-implement T3` for one task.
