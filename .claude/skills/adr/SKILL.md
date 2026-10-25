---
name: adr
description: Record an Architecture Decision Record in docs/adr/ for significant, hard-to-reverse decisions (framework, datastore, public API style, auth approach, major dependency). Use when a design involves such a choice or the user asks to record a decision.
argument-hint: <decision title>
---

# /adr: record a decision

Decision: **$ARGUMENTS**

1. Next number = highest `docs/adr/NNNN-*.md` + 1, zero-padded to 4 digits. File: `docs/adr/NNNN-kebab-title.md`, from `docs/adr/0000-template.md`.
2. Fill in **Context** (facts tagged VERIFIED/ASSUMED), **Decision** (1 to 2 sentences), **Alternatives** (at least 2, honest pros and cons), and **Consequences** (including what gets harder).
3. Status `proposed`. Link it from the related spec's design.md.
4. Ask for a GO. After the GO, set it to `accepted` with the date. If it replaces an older ADR, mark that one `superseded by ADR-NNNN`. ADRs are never deleted.
