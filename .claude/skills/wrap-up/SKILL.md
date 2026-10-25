---
name: wrap-up
description: End-of-session handover with no manual prompting. Rewrite docs/state/NOW.md (max 40 lines, 4 sections), move finished items to archive.md as one line each, and close handled inbox items. Use at the end of every work session, when context gets long (~40 exchanges), or when plan usage reaches 90%.
---

# /wrap-up: leave state for the next session

The next session starts from files, not chat history. Make them true and short.

1. **Collect facts** (VERIFIED only): `git status`, `git log --oneline -15`, and the active spec's `tasks.md` checkboxes. Run the gate only if you changed code since the last green run.
2. **Rewrite `docs/state/NOW.md`** completely (don't append). Max **40 lines**, exactly these sections:
   - header line: `_Updated: YYYY-MM-DD · Branch: … · Active spec: NNN-slug (phase)_`
   - **In progress:** what's half-done, with file/task pointers and the gate state
   - **Waiting on others:** external blockers, review requests
   - **Needs my decision (human):** each item is a question with options and your recommendation
   - **Next steps:** numbered, concrete, and the first one is runnable as-is (e.g. `/spec-implement T5`)
3. **Archive:** each item finished this session becomes one line at the top of `docs/state/archive.md`:
   `YYYY-MM-DD | spec 003 | T1–T4 done: rate limiter + tests | a1b2c3d..e4f5a6b`
4. **Inbox:** close (`status: closed`) the `docs/state/inbox.md` entries you handled. Add any `NEEDS OWNER` items to *Needs my decision*.
5. **Unrelated issues** you noticed but didn't fix go into *Next steps* or a GitHub issue. Don't drop them silently.
6. Commit the state files: `docs(state): wrap-up YYYY-MM-DD` (only if on a feature branch, or the human asked).
7. Reply with: a 3-line summary, the first next step, and `Delegated: …`.
