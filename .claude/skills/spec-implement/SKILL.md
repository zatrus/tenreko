---
name: spec-implement
description: Phase 4 of spec-driven development. Execute approved tasks from tasks.md one at a time with test-first, a green quality gate, and one conventional commit per task. Use after tasks.md has a GO.
argument-hint: "[task ID like T3, or 'all'; default = next open task]"
disable-model-invocation: true
---

# /spec-implement: build it, task by task

Target: **$ARGUMENTS** (default: the next `[ ]` task in the active spec's `tasks.md`; `all` = loop through open tasks).

## Preconditions
- `tasks.md` is `Status: approved`.
- You're on the spec branch (`feat/NNN-slug`), created by `/spec-new`, never on `main`. The working tree is clean or holds only this task's changes.
- `bash scripts/check.sh` is green **before** you start. If it's red, report and stop. Don't build on a red baseline.

## Loop (per task)

1. Mark the task `[~]` in `tasks.md`.
2. **Delegate** to the `implementer` agent: pass the spec folder and the task ID. For a trivial task (≤ ~20 lines) you may do it yourself, following the same red → green → refactor steps.
3. **Review the result yourself** (you are the lead):
   - Read the diff (`git diff`). Is every changed line within the task? Do the tests check the REQ behaviour?
   - Confirm the test was seen red before green (the implementer's report includes the failing line).
4. **Gate:** have `test-runner` run `bash scripts/check.sh`. It must be GREEN, with the summary copied from the output.
5. Mark the task `[x]` in `tasks.md`.
6. **Commit** the task's files plus `tasks.md` only:
   `git add <paths> docs/specs/NNN-slug/tasks.md && git commit -m "feat(<scope>): <summary> [spec NNN TX]"`
   The `[spec NNN TX]` tag links commit and task (`git log --grep "spec NNN T3"`).
   **Tiny tasks** (≤ ~20 changed lines each, touching the same files) may be done back to back and committed together: `[spec NNN T2,T3]`. Anything bigger gets its own commit, because each commit is a green checkpoint you can roll back to.
   Commit locally only. Pushing and the PR happen in `/spec-verify`.
7. If BLOCKED (ambiguous REQ, design gap, test can't be written): mark `[!] <reason>`. Write the question in `docs/state/NOW.md` under *Needs my decision* and **stop the loop**. If the fix needs a spec change, propose the edit to requirements/design and wait for GO.

When `all` is requested, continue with the next task. Stop after every 3 tasks, or when the context gets heavy, and run `/wrap-up` so a fresh session can continue.

## Finish
When no `[ ]` tasks remain: report in the *Reporting* format from `CLAUDE.md` (with the commit range), then say
> All tasks done. Next: `/spec-verify`.

End with `Delegated: …`.
