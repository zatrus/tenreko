---
paths:
  - "docs/specs/**"
  - "docs/adr/**"
---

# Rules for writing specs and ADRs

- Start from the templates in `docs/specs/_templates/`. Keep every section; write "n/a" with a reason instead of deleting one.
- **requirements.md is solution-free.** No class names, endpoints, or libraries. Those belong in design.md.
- **Every acceptance criterion is EARS, testable, and has a stable ID** (`REQ-<story>.<n>`). Never renumber an approved ID; deprecate it with ~~strikethrough~~ and add a new one.
- **Measurable NFRs:** numbers with units and conditions ("p95 < 200 ms at 50 rps"), never "fast" or "scalable".
- **Open questions block approval.** Don't answer them yourself; ask the human.
- **design.md cites real code.** Paths and symbols must exist (VERIFIED by `explorer`). Proposed new files are marked *(new)*.
- **tasks.md:** every REQ appears in at least one task. Every task names the test written first.
- After a GO, set `Status: approved (GO by … on YYYY-MM-DD)`. A later change to an approved file needs a new GO and a line in *Implementation notes*.
- Significant, hard-to-reverse decisions (framework, datastore, public API style) also get an ADR in `docs/adr/`.
