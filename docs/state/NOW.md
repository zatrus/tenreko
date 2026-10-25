# NOW

_Updated: 2026-10-25 · Branch: docs/extract-reservations · Active spec: none_

## In progress
- `/spec-extract` of `D:\projects\reservations`: map approved (GO 2026-10-25), 14 capabilities in [the capability index](../capabilities/README.md).
  - Stack: Python 3.14 + FastAPI + SQLAlchemy 2 async + Alembic on PostgreSQL (two backends: `binturo-organizers`, `binturo-platform`). React 19 + Vite frontends. Stripe for payments.
  - Enrollments (ENROLL) extracted: [current enrollment rules](../capabilities/enrollments.md), 65 rules. Waiting for human review and answers to its open questions.

## Waiting on others
- 

## Needs my decision (human)
- Whether docs-only commits are allowed while `scripts/check.sh` cannot run (no stack yet, `/project-init` not done).
- Open questions in [current enrollment rules](../capabilities/enrollments.md): 7 suspected bugs, 5 race risks, 8 behaviour questions, 6 doc conflicts.

## Next steps
1. Human reviews the enrollment rules. Answers that describe desired behaviour become `/spec-new` or `/bugfix` items here.
2. Candidate first spec after extraction: characterisation tests against a real database for the enrollment races and the waitlist renumbering (all current tests mock the database).
3. `/spec-extract D:\projects\reservations <next capability>` in a fresh session (suggested: passes-and-pricing, PASS, because enrollments depend on it).
