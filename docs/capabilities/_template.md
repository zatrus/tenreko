# Capability: {{Name}}

- **Prefix:** `{{PREFIX}}` (rule IDs `{{PREFIX}}-1`, `{{PREFIX}}-2`, …)
- **Last changed by:** spec NNN (YYYY-MM-DD)
- **Business context:** [BUSINESS.md](../BUSINESS.md) (terms used here are defined there)

## Purpose
What this capability does for whom, in 1 to 3 sentences.

## Rules (current behaviour)

<!-- EARS, one observable behaviour per row. "Since" = the change REQ that introduced or last changed it,
     or "extracted YYYY-MM-DD" for behaviour documented from existing code (/spec-extract). "Code" = path:line.
     "Test(s)" = the test that proves it, or "— (code only)".
     Remove nothing: strike a retired rule through and name the spec that retired it. -->

| ID | Rule | Since | Code | Test(s) |
|---|---|---|---|---|
| {{PREFIX}}-1 | WHEN … the system shall … | spec 001 REQ-1.1 | `src/…/OrderService.java:42` | `OrderServiceTest.should_…` |

## Invariants and concurrency
<!-- Rules that must always hold on shared state, how each is enforced, and the parallel test that proves it. -->

| Invariant | Enforced by | Test |
|---|---|---|

## Edge cases (current)
Decided behaviour for empty input, limits, time zones, repeats, and so on, as rule IDs from the table above, or "none".

## Open questions
<!-- Undecided behaviour, suspected bugs, race risks, conflicts between code, tests, and docs.
     Each in plain words with its effect. Answered items become rules, or a /spec-new or /bugfix. -->
- [ ] …

## Contracts
Links to the public interface: API paths or the OpenAPI file, events, CLI flags.

## Decisions
- ADR-NNNN: …

## History
| Spec | Change |
|---|---|
| [001](../specs/001-slug/) | Introduced |
