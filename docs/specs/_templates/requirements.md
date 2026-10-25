# Spec NNN: {{Feature name}} · Requirements

- **Status:** draft | approved (GO by {{who}} on {{date}}) | delivered (historical, spec NNN)
- **Owner:** {{human}}
- **Capabilities:** {{name}} (adds / changes / retires {{PREFIX}}-n), see `docs/capabilities/`
- **Related:** issues, ADRs, other specs

## Problem
What hurts, for whom, and how we know (evidence, tagged VERIFIED/ASSUMED). 2 to 5 sentences. No solution here.

## Goals
- G1: measurable outcome

## Non-goals
- What this spec deliberately does NOT cover. Protects against scope creep.

## User stories and acceptance criteria

<!-- EARS notation: one testable sentence per criterion. Each gets a stable ID.
     Ubiquitous:   The <system> shall <response>.
     Event:        WHEN <trigger> the <system> shall <response>.
     State:        WHILE <state> the <system> shall <response>.
     Unwanted:     IF <condition> THEN the <system> shall <response>.
     Optional:     WHERE <feature is included> the <system> shall <response>. -->

### US-1: As a {{role}}, I want {{capability}} so that {{benefit}}

| ID | Acceptance criterion (EARS) |
|---|---|
| REQ-1.1 | WHEN ... the system shall ... |
| REQ-1.2 | IF ... THEN the system shall ... |

<!-- Optional acceptance scenarios for multi-step or concurrent behaviour, where one EARS line is not enough.
     Each names the REQ(s) it proves and is traced like a REQ. -->

#### AC-1.1: {{scenario name}} (REQ-1.1)
Given {{state}}
When {{action, e.g. two distinct users book the last place at the same time}}
Then {{observable outcome, e.g. exactly one booking succeeds}}
And {{the other gets a "class full" response}}

### US-2: ...

## Non-functional requirements

| ID | Category | Requirement (measurable) |
|---|---|---|
| NFR-1 | performance | p95 latency of X < 200 ms at 50 rps |
| NFR-2 | security | ... |

## Edge cases and error scenarios

<!-- Go through EVERY category. Each row is either covered by REQ IDs or marked
     "N/A: <reason>". An empty cell is not allowed. The human adds their own cases at the GO.
     Use /edge-cases to draft this table. -->

| Category | Cases to consider | Covered by / N/A reason |
|---|---|---|
| Empty, null, missing | empty string/list/file, null/None/undefined, missing field, missing optional config | |
| Boundaries | 0, 1, max, max+1, negative, min-1; first/last page; exactly at a limit | |
| Text | whitespace-only, very long, Unicode (emoji, combining marks, RTL), case, normalisation, injection payloads | |
| Numbers and money | rounding, precision (no floats for money), overflow, division by zero, currency | |
| Time | time zones, DST jumps, leap day, end of month/year, "now" at midnight, expiry exactly at the boundary, clock skew | |
| Collections and order | duplicates, unsorted input, huge input, stable ordering of results | |
| External failures | timeout, retry after partial success, dependency down, malformed response | |
| Permissions and state | not authenticated, wrong owner, resource already deleted, invalid state transition | |
| Repeats and concurrency | double submit, retry of the same request (idempotency), two users changing the same thing at once, last item in stock | |

<!-- Concurrency rows name the invariant (what must always stay true, e.g. "stock is never negative",
     "an order is paid at most once") and the expected result for the losing request. design.md decides how
     each invariant is enforced. -->

**Added by the human at review:**
- 

## Open questions
<!-- Every ambiguity goes here. Do not guess. The spec cannot be approved while
     a question that blocks design is open. -->
- [ ] Q1: ...

## New terms
<!-- Terms this spec introduces or redefines. At the GO they are added to the terminology table in
     docs/BUSINESS.md, which is the single glossary. Existing terms are used as defined there. -->
- **Term:** definition
