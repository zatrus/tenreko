# Coding rules (all languages)

## Before writing code
- Read the relevant spec task and the code you will touch. Use `explorer` for anything wider than 2 or 3 files.
- State assumptions. If two readings of the task exist, ask; don't pick one silently.
- Look for an existing helper, pattern, or library in the repo before writing a new one. Match it.

## While writing code
- **Simplest thing that satisfies the REQ.** No speculative parameters, layers, interfaces with one implementation, or "for later" config.
- **Surgical diffs.** Don't reformat, rename, or "improve" code outside the task. Remove only what *your* change made unused.
- **Match the surrounding code**: naming, comment density, error style, file layout.
- **Names say what, not how.** `activeUsers`, not `list2`. Booleans read as questions: `isExpired`, `hasAccess`.
- **Functions do one thing**, around 30 lines or less, with 3 parameters or fewer (otherwise use a parameter object/record).
- **Pure core, effects at the edges.** Keep I/O, time, randomness, and env access injectable so the core is unit-testable.
- **Immutability by default.** Mutate only when it's measurably needed.
- **Errors:** never swallow them. Either handle with a specific recovery, or rethrow with context. No catch-all that just logs.
- **No magic values.** Named constants, or config for real deployment-time knobs.
- **Comments explain why**, not what. Link the spec ID where behaviour is non-obvious: `// REQ-2.3: retries are capped at 3`.
- **Dependencies:** adding one is a design decision. Justify it in design.md (maintenance, size, licence, security). Prefer the standard library.

## After writing code
- Run `bash scripts/check.sh`. Read the failures; fix root causes, not symptoms.
- Self-review your diff (`git diff`) before calling the task done: debug prints, TODOs without a spec ID, commented-out code, unrelated changes.
