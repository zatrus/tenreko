# Spec NNN: {{Feature name}} · Requirements

- **Status:** draft | approved (GO by {{who}} on {{date}})
- **Owner:** {{human}}
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

### US-2: ...

## Non-functional requirements

| ID | Category | Requirement (measurable) |
|---|---|---|
| NFR-1 | performance | p95 latency of X < 200 ms at 50 rps |
| NFR-2 | security | ... |

## Edge cases and error scenarios
- Empty input, max size, concurrency, partial failure, permission denied, ...

## Open questions
<!-- Every ambiguity goes here. Do not guess. The spec cannot be approved while
     a question that blocks design is open. -->
- [ ] Q1: ...

## Glossary
- **Term:** definition used consistently in code and docs.
