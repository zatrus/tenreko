# Specs

One folder per feature: `NNN-short-slug/` with three files, created in order and each approved (`GO`) before the next:

| File | Answers | Created by |
|---|---|---|
| `requirements.md` | **What** and **why**: user stories, EARS acceptance criteria (REQ-x.y), NFRs, non-goals | `/spec-new` |
| `design.md` | **How**: architecture, contracts, data, errors, test strategy, constitution check | `/spec-design` |
| `tasks.md` | **In what steps**: small test-first tasks with traceability | `/spec-tasks` |

Then `/spec-implement` executes tasks and `/spec-verify` proves every REQ has a passing test.

Templates: [`_templates/`](_templates/). Numbering: next free 3-digit number.

## Index

| # | Feature | Status |
|---|---|---|
