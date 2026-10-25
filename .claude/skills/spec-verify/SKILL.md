---
name: spec-verify
description: Phase 5 of spec-driven development. Prove the implementation meets the spec - fill the traceability table (every REQ has a passing test), run the full gate, and get an independent fresh-context review before merge. Use when all tasks are done.
argument-hint: "[spec number or folder; default = active spec]"
disable-model-invocation: true
---

# /spec-verify: prove it before merge

Spec: **$ARGUMENTS** (default: active spec).

## Steps

1. **All tasks closed?** Any `[ ]`, `[~]`, or `[!]` in `tasks.md` → list them and stop.
2. **Full gate:** `test-runner` runs `bash scripts/check.sh`. It must be GREEN. Copy the summary (tests, coverage).
3. **Traceability:** for each REQ and NFR in `requirements.md`, find the test(s) that cover it (search for the REQ ID and the names from the design's test strategy). Fill the *Traceability* table in `tasks.md`:
   `| REQ-1.1 | T1 | OrderServiceTest.should_reject_expired | ✅ passing |`
   Any REQ without a test → status ❌. That's a blocker: add a task, and go back to `/spec-implement`.
   NFRs that can't be tested automatically get a recorded manual check with evidence (command and output).
4. **Independent review:** run the `reviewer` agent on `git diff main...HEAD` with the spec folder. It hasn't seen this conversation, which is the point.
   - Optional, for risky changes: also ask a different vendor's tool (Codex or Gemini, which read `AGENTS.md`) or a separate Claude session for a second review.
   - For auth, crypto, uploads, or external input: also run `/security-review`.
5. **Triage findings:** fix BLOCKER and MAJOR (each as a small task plus commit, with gate green). For each MINOR, fix it or note why not. Never dismiss a finding without a reason.
6. **Docs:** README, API docs, `.env.example`, and CHANGELOG updated where behaviour changed.
7. **Report** (it becomes the PR description):
   ```
   Spec NNN: <name>: VERIFIED | NOT READY
   Gate: <summary copied from output>
   REQs: X/Y covered by passing tests (list any gaps)
   Review: APPROVE | n findings fixed, m deferred (why)
   Commits: <range>
   ```
8. **Open the PR** (only if the report says VERIFIED):
   - `git push -u origin feat/NNN-slug`. The hook allows this only for a branch the agent created.
   - `gh pr create --base main --title "feat(<scope>): <spec title> [spec NNN]" --body-file <report>`. The title and body become the **squash commit** on `main`, so write them for someone reading `git log` a year from now: the spec link, REQs covered, gate summary, and review result.
9. **STOP.** Tell the human the PR is ready, and suggest **squash merge**. Never merge it yourself: no `gh pr merge`, no merging into `main`.
10. **After the human says it's merged:** switch to `main` and pull, add a line to `docs/facts/releases.md` (only what's verified), and run `/wrap-up`. Commit those state files on a new `chore/` branch, or leave them for the human, but never commit on `main`.
