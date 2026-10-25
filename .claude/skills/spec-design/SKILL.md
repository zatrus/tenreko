---
name: spec-design
description: Phase 2 of spec-driven development. Produce docs/specs/NNN-slug/design.md (architecture, contracts, data model, errors, test strategy, constitution check) from approved requirements. Use after requirements.md has a GO.
argument-hint: "[spec number or folder; default = active spec in NOW.md]"
disable-model-invocation: true
---

# /spec-design: technical design

Spec: **$ARGUMENTS** (if empty, use the active spec named in `docs/state/NOW.md`, or the newest folder in `docs/specs/`).

## Preconditions
- `requirements.md` has `Status: approved`. If not, stop and say so.
- No *Open questions* that block design. If there are, list them and stop.

## Steps

1. **Gather VERIFIED context.** Send `explorer` to map the modules, patterns, and conventions this feature touches (entry points, similar features, error handling style, test setup). Don't read the whole codebase yourself.
2. **Hard trade-offs?** If there are two or more credible approaches with real consequences, ask `reasoner` for a comparison. Record the result under *Alternatives considered*. Hard-to-reverse choices also get an ADR draft in `docs/adr/`.
3. **Write `design.md`** from `docs/specs/_templates/design.md`:
   - Reuse existing patterns found in step 1. Cite real paths; mark new files *(new)*.
   - Define **contracts first** (API, function signatures, events, schema), precisely enough that tests can be written from them.
   - **Error handling table:** every unwanted-behaviour REQ (`IF … THEN`) appears in it.
   - **Concurrency and consistency table:** list all shared mutable state the design touches. Every invariant gets an atomic mechanism (constitution article 11), the loser's result, and a named concurrency test. "Check, then write" in application code is never a mechanism. If nothing is shared, write `None: <why>`.
   - **Edge-case REQs** each map to a test in the test strategy. Use property-based tests for input-shaped categories (text, numbers, boundaries, time) and parallel tests on the real datastore for invariants.
   - **Test strategy table:** every REQ and NFR maps to a test level and a test name.
   - **Constitution check:** go through every article. Exceptions need a justification.
   - Pick the simplest design that meets the REQs. Don't add extension points nobody asked for.
4. **Self-check:** every REQ is addressed. No new requirements have sneaked in (if you need one, propose it as a change to requirements.md instead).
5. Update `docs/state/NOW.md` (active spec and phase).
6. **STOP.** Summarise the approach, the main risks, and new dependencies, then ask:
   > Review `design.md`. Reply **GO** to approve, or tell me what to change. Next: `/spec-tasks`.

No production code in this phase. Small throwaway spikes are allowed only with a GO, and are deleted afterwards.
