# CLAUDE.md

<!-- Keep this file under ~120 lines. Everything here is loaded on EVERY session start.
     Stack-specific rules live in .claude/rules/*.md and load only for matching paths. -->

## Project

- **Name:** {{PROJECT_NAME}}
- **Stack:** {{STACK}}  <!-- node | python | java | spring-boot -->
- **One-line purpose:** {{PURPOSE}}

Principles that override everything else: @docs/constitution.md
Current state (rewritten at the end of each session): @docs/state/NOW.md

Where things live (read on demand, not at startup):
- Business context, users, policies, terminology: `docs/BUSINESS.md`
- **Current behaviour**, one file per capability: `docs/capabilities/`
- Change records (requirements → design → tasks): `docs/specs/NNN-slug/`
- Decisions: `docs/adr/` · Human contribution rules: `CONTRIBUTING.md`

## Roles

- **Human = decision-maker.** Nothing moves past a gate (requirements → design → tasks → merge) without an explicit `GO`.
- **Only the human merges into `main`.** The agent pushes only to branches it created, opens the PR, and stops.
- **Main agent = lead.** It plans, evaluates, decides, and commits on its feature branch. Heavy or mechanical work goes to subagents in `.claude/agents/`:
  - `explorer` (Haiku): any code search or code map
  - `test-runner` (Haiku): builds, tests, the quality gate
  - `implementer` (Sonnet): writes code for one task from `tasks.md`
  - `reviewer` (Sonnet): fresh-context review against the spec
  - `reasoner` (Opus): hard root-cause analysis and design trade-offs
- Every completion report uses the format in *Reporting* below and ends with `Delegated: <what> → <agent>` (or `Delegated: none`).

## Workflow: spec-driven development

Every change is triaged first:

| Size | When | Flow |
|---|---|---|
| **Trivial** | typo, rename, config value, ≤ ~20 lines, no behaviour change | fix → gate → commit |
| **Bug** | behaviour is wrong vs. an existing spec | `/bugfix`: failing test first → fix → gate |
| **Feature** | new behaviour, API, data model, or anything you are unsure about | full spec flow below |
| **Existing code, no specs** | adopting the template for a codebase that already exists | `/spec-extract <path>`: map → one capability per run → business → ADRs |

Full spec flow (one folder per feature: `docs/specs/NNN-slug/`):

1. `/spec-new <idea>` → `requirements.md` (user stories + EARS acceptance criteria). **STOP for GO.**
2. `/spec-design` → `design.md` (architecture, contracts, data, test strategy). **STOP for GO.**
3. `/spec-tasks` → `tasks.md` (small, ordered, test-first tasks). **STOP for GO.**
4. `/spec-implement` → one task at a time: red → green → refactor → gate → commit.
5. `/spec-verify` → traceability (every REQ has a passing test) + capability files updated + independent review → push branch, open PR. **STOP: the human squash-merges.**
6. `/wrap-up` → update `docs/state/NOW.md`, archive finished items, update `docs/facts/`.

`docs/capabilities/` says how the system behaves **now**; a spec folder records one change and becomes history once delivered. If the code needs to differ from the spec, **update the spec first**, then the code.

## Quality gate

One command, same for every stack. Run it before every commit; never commit red.

```bash
bash scripts/check.sh          # format-check + lint + typecheck + tests (+ coverage)
bash scripts/check.sh --fix    # apply formatters/autofixes first
```

The task is not done until the gate is green **and** you have pasted the relevant output. "Should work" is not done.

## Hard rules (short list; details in .claude/rules/)

1. **Verified facts only.** Tag claims `VERIFIED` (you ran it / read it) or `ASSUMED`. Never invent APIs, versions, numbers, or test results. Business facts (prices, policies, targets, legal duties) come only from `docs/BUSINESS.md` or the human.
2. **Stay in scope.** Every changed line traces to the current task. Note unrelated issues in NOW.md; don't fix them.
3. **Tests are the contract.** New behaviour → new test first. Bug → reproducing test first.
4. **Never weaken a check to get green.** No skipped tests, `@Disabled`, `# type: ignore`, `eslint-disable`, lowered coverage, or deleted assertions without an explicit human `GO`.
5. **No secrets** in code, logs, specs, or commits. Use env vars and `.env.example`.
6. **Don't hand-edit** lockfiles, generated code, or migrations that already ran. Regenerate or add a new migration.
7. **Ask, don't guess,** when a requirement is ambiguous. Put the question in the spec under *Open questions*. When code, capability files, and specs **disagree**, name the conflict (paths) and ask. Neither side silently wins.
8. **Conventional commits**, one task per commit on the feature branch (tiny tasks may share one), referencing the spec: `feat(auth): add login rate limit [spec 003 T4]`. PRs are squash-merged, so `main` gets one commit per spec.
9. **Branches and merging:** push only to branches you created (the hook enforces it). Never merge into `main` and never run `gh pr merge`; only the human merges. Nothing else public (release, publish, tags, external message) without human `GO`.
10. **Numbers come from tools.** Coverage, timings, sizes, and counts are copied from command output, never estimated.

## Reporting

Report outcomes and evidence, not plans. Persist decisions in files, not in chat. Style and how to cite IDs: `.claude/rules/communication.md`.

```
Done: <task IDs and the resulting behaviour>
Verification:
- Passed: <checks actually run, summary copied from output>
- Failed: <remaining failures, or none>
- Not run: <relevant checks not run, and why, or none>
Open issues: <blockers, conflicts, consequential assumptions, or none>
Documents updated: <paths, or none>
Delegated: <what> → <agent>, or none
```

## Context and budget

- Start a fresh session per phase (spec → design → tasks → implement). State carries over via files, not chat.
- After ~40 exchanges, or when the context feels heavy, say so and run `/wrap-up`.
- Don't switch models mid-session (the cache is per model). Delegate instead.
- Before a big task, check plan usage. **≥ 80%:** economy mode (Haiku/Sonnet only, no parallel subagents). **≥ 90%:** stop, `/wrap-up`, report.

## Commands

<!-- Filled by /project-init. Keep in sync with scripts/check.sh. -->
- Install: `{{INSTALL_CMD}}`
- Run: `{{RUN_CMD}}`
- Test one: `{{TEST_ONE_CMD}}`
- Gate: `bash scripts/check.sh`
