# NOW

<!-- Max 40 lines. Rewritten (not appended) by /wrap-up at the end of every session.
     Only current state. Finished items move to archive.md as one line each. -->

_Updated: 2026-10-25 · Branch: docs/extract-reservations · Active spec: none_

## In progress
- `/spec-extract` of `D:\projects\reservations`: phase `map` done and approved (GO by human on 2026-10-25), 14 capabilities in [the capability index](../capabilities/README.md).
  - Stack: Python 3.14 + FastAPI + SQLAlchemy 2 async + Alembic on PostgreSQL (two backends: `binturo-organizers`, `binturo-platform`). React 19 + Vite frontends. Stripe for payments.

## Waiting on others
- 

## Needs my decision (human)
- Whether docs-only commits are allowed while `scripts/check.sh` cannot run (no stack yet, `/project-init` not done).

## Next steps
1. `/spec-extract D:\projects\reservations enrollments` (ENROLL, smallest core capability), in a fresh session.
2. Then one capability per run, in the order of the index.
