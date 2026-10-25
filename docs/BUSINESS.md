# Business context

<!-- Why the product exists. Read by /spec-new before writing requirements.
     Mark every statement CONFIRMED (the human decided it) or ASSUMPTION (not yet validated).
     The agent never invents prices, policies, targets, or legal obligations: an unknown value is
     written as "not decided" and asked about. Feature rules live in docs/capabilities/, not here. -->

_Updated: {{DATE}} · Owner: {{HUMAN}}_

## Product purpose
{{What problem the product solves and why it matters.}}

## Users and customers

| Group | Need | Relationship to the product | Status |
|---|---|---|---|
| {{Group}} | {{Problem or goal}} | {{user / payer / operator / …}} | CONFIRMED |

## Value proposition
{{Main benefits and why someone would choose this product.}}

## Core journeys
- {{Actor}} {{does something}} to {{achieve an outcome}}.

## Business and operating model
{{Who pays whom, how the service is operated, who is responsible for what. "Not decided" is a valid answer.}}

## Scope and boundaries

### In scope
- {{Supported capability}}, see `docs/capabilities/{{name}}.md`

### Out of scope
- {{Explicit boundary}}

## Business policies
<!-- Summary only, with a link to the capability rule that implements it. -->
- {{Policy}}: `{{PREFIX}}-n`

## Domain terminology
<!-- The single glossary for code, specs, and docs. New terms from a spec are added here at its GO. -->

| Term | Meaning |
|---|---|
| {{Term}} | {{Definition used consistently in code and docs}} |

## Success measures
<!-- Targets only where agreed. -->
- {{Measure}}: {{target, or "no target agreed"}}

## Assumptions and open questions
- [ ] {{Unvalidated assumption or pending decision}} (owner: {{who}})
