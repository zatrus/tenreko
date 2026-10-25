# Testing rules

- **Red → green → refactor.** Write the test, run it, and *see it fail for the right reason* before implementing.
- **One behaviour per test.** Name it after the behaviour: `should_return_404_when_order_missing` / `returns 404 when order is missing`.
- **Arrange / Act / Assert** blocks, visibly separated. No logic (loops, ifs) in tests.
- **Trace to the spec.** Put the REQ ID in the test name or a one-line comment: `// REQ-1.2`.
- **Test pyramid:** many fast unit tests on the pure core; fewer integration tests on adapters (real DB via Testcontainers or an in-memory equivalent, real HTTP layer); very few e2e tests.
- **Don't mock what you don't own.** Wrap third-party clients in a thin adapter and fake the adapter. Prefer fakes over mocks for domain collaborators.
- **Deterministic:** no real clock, network, random seeds, or test-order dependence. Inject a clock and seed.
- **Edge cases from the spec** (empty, max, invalid, concurrent, failure) each get a test.
- **Coverage is a floor, not a goal.** The gate enforces the configured minimum (default 80% lines on new code). Never lower it to get green.
- **Flaky test = bug.** Fix it or quarantine it with an issue link and a human `GO`. Never retry until it passes.
- **Never** delete, skip, or loosen an assertion to make a failing test pass. If the test is wrong, say why and fix the spec/test with a `GO`.
