---
paths:
  - "docs/specs/**"
  - "docs/adr/**"
  - "docs/capabilities/**"
  - "docs/BUSINESS.md"
---

# Rules for writing specs, capabilities, and ADRs

- **Keywords:** MUST / shall = mandatory. SHOULD = the default; an exception needs a written reason. MAY = optional. Don't use "should" loosely in a criterion.
- Start from the templates in `docs/specs/_templates/`. Keep every section; write "n/a" with a reason instead of deleting one.
- **Acceptance scenarios** (`AC-<story>.<n>`, Given/When/Then) are optional, for multi-step or concurrent behaviour. Each names its REQ(s) and is traced like a REQ.
- **Business facts** (prices, limits, policies, legal duties, targets) come from `docs/BUSINESS.md` or the human. Never invent them. Unknown → *Open questions*.
- **Terminology:** use terms as defined in `docs/BUSINESS.md`. New terms go under *New terms* and are added to BUSINESS.md at the GO.
- **requirements.md is solution-free.** No class names, endpoints, or libraries. Those belong in design.md.
- **Every acceptance criterion is EARS, testable, and has a stable ID** (`REQ-<story>.<n>`). Never renumber an approved ID; deprecate it with ~~strikethrough~~ and add a new one.
- **Measurable NFRs:** numbers with units and conditions ("p95 < 200 ms at 50 rps"), never "fast" or "scalable".
- **Open questions block approval.** Don't answer them yourself; ask the human.
- **design.md cites real code.** Paths and symbols must exist (VERIFIED by `explorer`). Proposed new files are marked *(new)*.
- **tasks.md:** every REQ appears in at least one task. Every task names the test written first.
- After a GO, set `Status: approved (GO by … on YYYY-MM-DD)`. A later change to an approved file needs a new GO and a line in *Implementation notes*.
- **Delivered specs are history.** Don't edit them; change behaviour with a new spec. Current behaviour lives in `docs/capabilities/<name>.md` with stable IDs (`CHECKOUT-3`), each linked to its source REQ and test.
- **Conflicts:** if the code, a capability file, and a spec disagree, name the conflict with paths and ask. Code can be buggy and specs can be stale; neither silently wins.
- Significant, hard-to-reverse decisions (framework, datastore, public API style) also get an ADR in `docs/adr/`.
