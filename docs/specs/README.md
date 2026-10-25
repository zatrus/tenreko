# Specs: change records

Each folder records **one change**: why it was made, how it was built, and how it was verified. Once delivered, a folder is a historical record. **Current behaviour** lives in [`docs/capabilities/`](../capabilities/), which `/spec-verify` updates before the PR.

One folder per feature: `NNN-short-slug/` with three files, created in order and each approved (`GO`) before the next:

| File | Answers | Created by |
|---|---|---|
| `requirements.md` | **What** and **why**: user stories, EARS acceptance criteria (REQ-x.y), NFRs, non-goals | `/spec-new` |
| `design.md` | **How**: architecture, contracts, data, errors, test strategy, constitution check | `/spec-design` |
| `tasks.md` | **In what steps**: small test-first tasks with traceability | `/spec-tasks` |

Then `/spec-implement` executes tasks and `/spec-verify` proves every REQ has a passing test, folds the REQs into the capability files, and sets the status to `delivered`.

Status lifecycle: `draft` → `approved` (per file, at each GO) → `delivered (historical, spec NNN)`. A delivered spec is not edited again; a later change gets a new spec.

Templates: [`_templates/`](_templates/). Numbering: next free 3-digit number.

## Index

| # | Feature | Capabilities | Status |
|---|---|---|---|
