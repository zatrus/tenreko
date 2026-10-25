# Testing rules

- **Red → green → refactor.** Write the test, run it, and *see it fail for the right reason* before implementing.
- **One behaviour per test.** Name it after the behaviour: `should_return_404_when_order_missing` / `returns 404 when order is missing`.
- **Arrange / Act / Assert** blocks, visibly separated. No logic (loops, ifs) in tests.
- **Trace to the spec.** Put the REQ ID in the test name or a one-line comment: `// REQ-1.2`.
- **Test pyramid:** many fast unit tests on the pure core; fewer integration tests on adapters (real DB via Testcontainers or an in-memory equivalent, real HTTP layer); very few e2e tests.
- **Don't mock what you don't own.** Wrap third-party clients in a thin adapter and fake the adapter. Prefer fakes over mocks for domain collaborators.
- **Deterministic:** no real clock, network, random seeds, or test-order dependence. Inject a clock and seed.
- **Edge cases from the spec** each get a test: every REQ from the *Edge cases* table of requirements.md. Use `/edge-cases` to find them before or after writing code.
- **Property-based tests** for logic driven by input shape (parsing, validation, money, dates, text): state a property that must hold for all valid inputs (round-trip, invariant, never throws, agrees with a simpler model) and let the library generate the data. fast-check (Node), Hypothesis (Python), jqwik (Java). Pin the seed in CI output so a failure can be replayed; keep each found counterexample as a plain example test.
- **Concurrency tests** for every invariant in design.md: real datastore (Testcontainers, never an in-memory stand-in), start N workers behind one barrier so they really overlap, then assert the invariant and the exact outcome count (stock 1, 10 buyers → 1 success, 9 conflicts, stock 0). No sleeps. Run the test against the naive implementation first and see it fail. Patterns per stack: `.claude/skills/edge-cases/references/concurrency.md`.
- **Time edge cases** use an injected clock set to the tricky instant (DST switch, 23:59:59 in another zone, Feb 29), never the real clock.
- **Optional: mutation testing** (Stryker, mutmut, PIT) shows whether the tests would notice a broken boundary (`>` changed to `>=`). It is slow: run it nightly or before a release on the core domain, never in `scripts/check.sh`.
- **Coverage is a floor, not a goal.** The gate enforces the configured minimum (default 80% lines on new code). Never lower it to get green.
- **Flaky test = bug.** Fix it or quarantine it with an issue link and a human `GO`. Never retry until it passes.
- **Never** delete, skip, or loosen an assertion to make a failing test pass. If the test is wrong, say why and fix the spec/test with a `GO`.
