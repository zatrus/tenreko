# Constitution

<!-- Non-negotiable engineering principles for this project. Every design.md has a
     "Constitution check" that must pass these, or explicitly justify an exception.
     Change this file only with a human GO and an ADR (docs/adr/). Keep it short. -->

## Articles

1. **Spec before code.** Features start as `requirements.md`. Code that no requirement asks for doesn't get written.
2. **Test-first.** Each acceptance criterion maps to at least one automated test. The test is written and seen failing before the implementation.
3. **Simplicity.** Choose the simplest design that meets the requirements. No speculative abstractions, plugin systems, or config "for later". Three similar lines beat a premature abstraction.
4. **Clear boundaries.** Domain logic doesn't depend on frameworks, I/O, or transport. Adapters (HTTP, DB, CLI, queues) sit at the edges and are thin.
5. **Explicit contracts.** Public interfaces (HTTP APIs, CLI flags, events, library exports) are defined in `design.md` before implementation, and changes to them are versioned.
6. **Fail loudly at the edges.** Validate all external input at the boundary. Inside the core, trust types. No swallowed exceptions.
7. **Observability.** Errors carry context. Logs are structured and never contain secrets or personal data.
8. **Security by default.** Least privilege, parameterised queries, dependency updates, no secrets in the repo.
9. **Reproducible builds.** Pinned toolchain and lockfiles. One gate command (`scripts/check.sh`) behaves the same locally and in CI.
10. **Small increments.** Each task is one reviewable commit that leaves the gate green.
11. **Invariants live in the datastore.** A rule about shared state ("stock is never negative", "paid at most once") is enforced atomically where the data lives: a conditional update, a constraint, a version check, or a lock. Never "check in code, then write". Every such invariant has a test that runs requests in parallel against the real datastore.

## Project-specific additions

<!-- e.g. "Public API is backwards compatible within a major version"
          "p95 latency of /search < 200 ms"
          "Runs offline; no telemetry" -->
- {{ADD_OR_DELETE}}
