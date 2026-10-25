# Spec NNN: {{Feature name}} · Tasks

- **Status:** draft | approved (GO by {{who}} on {{date}})
- **Design:** ./design.md
- **Branch:** `feat/NNN-slug`

<!-- Rules for tasks:
     - Each task = one commit on the feature branch that leaves the gate green. Aim for < ~150 changed lines.
       Tiny tasks (<= ~20 lines, same files) may share a commit. The PR is squash-merged into main by the human.
     - Ordered by dependency. [P] marks tasks that can run in parallel (no shared files).
     - Each task lists the REQs it covers, the test to write FIRST, and how to verify.
     - Status: [ ] todo · [~] in progress · [x] done (commit sha) · [!] blocked (reason) -->

## Tasks

- [ ] **T1: {{short imperative title}}**
  - Covers: REQ-1.1
  - Test first: `path/to/test` → `should_...` (expect red)
  - Change: files/modules to touch
  - Verify: `bash scripts/check.sh` green; test from above passes

- [ ] **T2 [P]: ...**
  - Covers: REQ-1.2
  - Test first: ...
  - Change: ...
  - Verify: ...

## Traceability
<!-- Filled by /spec-verify. Every REQ and NFR must have a row. -->
| REQ / NFR | Task(s) | Test(s) | Status |
|---|---|---|---|

## Implementation notes
<!-- Discoveries during implementation that changed the plan. If one changes
     behaviour, update requirements.md/design.md FIRST and record it here. -->
