---
name: bugfix
description: Fix a bug with reproduce-first discipline - write a failing test that reproduces it, find the root cause, apply the minimal fix, gate, and commit. Use when behaviour is wrong compared with an existing spec or clear expectation.
argument-hint: <bug description, issue link, or error message>
---

# /bugfix: reproduce, fix, prove

Bug: **$ARGUMENTS**

1. **Pin down the expected behaviour.** Which capability rule (`docs/capabilities/`, e.g. `CHECKOUT-3`) or spec REQ is violated? If none exists, this may be a feature request. Say so and suggest `/spec-new`. If the capability file itself is wrong or stale, that's a conflict: report it and ask which side is right.
2. **Locate:** use `explorer` to find the code path. Read the logs or the stack trace if given.
3. **Reproduce in a test first.** Write the smallest automated test that fails *because of the bug*. Run it, and paste the failing assertion. If you can't reproduce it, stop and report what you tried. Don't fix blind.
4. **Root cause:** explain *why* it fails in 1 to 3 sentences, VERIFIED with evidence (`path:line`). If the first hypothesis doesn't hold after one attempt, hand it to `reasoner`.
5. **Minimal fix** of the root cause, not the symptom. Don't refactor nearby code.
6. **Search for siblings:** does the same mistake exist elsewhere? List the places (fix them only if it's the same root cause and trivial; otherwise note them in NOW.md).
7. **Gate:** `bash scripts/check.sh` GREEN (via `test-runner`).
8. **Commit** on a new branch you create from `main` (`git switch -c fix/<slug>`), never on `main` or someone else's branch. Message: `fix(<scope>): <what was wrong> [CHECKOUT-3]` (or `[spec NNN REQ-x.y]`), with a body saying the root cause. Add the regression test name to the rule's *Test(s)* in the capability file. Push it and open a PR if asked; the human merges.
9. Report in the *Reporting* format from `CLAUDE.md`, plus the root cause and the regression test name.
