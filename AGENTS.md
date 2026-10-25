# AGENTS.md

Instructions for AI coding agents that aren't Claude Code (Codex, Gemini CLI, Cursor, etc.). Claude Code reads `CLAUDE.md`. Both describe the same project and rules.

A typical use is an **independent pre-merge review** by a different vendor's model: a second pair of eyes that didn't write the code.

## Read first
1. `docs/constitution.md`: non-negotiable principles
2. `CLAUDE.md`: workflow, quality gate, hard rules
3. `.claude/rules/*.md`: coding, testing, security, git, and the stack rules
4. `docs/BUSINESS.md`: users, policies, and the single glossary
5. `docs/capabilities/<name>.md`: current behaviour of what you touch
6. The spec for the change: `docs/specs/NNN-slug/{requirements,design,tasks}.md` (delivered specs are history, not current behaviour)

Open and read these files; a link alone doesn't load them. If they disagree with each other or with the code, report the conflict with paths. Don't resolve it yourself.

## Quality gate
`bash scripts/check.sh` must pass. Never weaken lint, type, test, or coverage settings.

## When reporting work
Write short, active, literal sentences. Describe each requirement, rule, or task in plain words first, then add its ID in parentheses: "two buyers cannot both get the last item (CHECKOUT-3)". Never use an ID alone. Full rules: `.claude/rules/communication.md`.

Use the *Reporting* format in `CLAUDE.md`: Done, Verification (Passed / Failed / **Not run**), Open issues, Documents updated. Never claim a check passed without running it.

## When asked to review
Review `git diff main...HEAD` against the spec. Report findings as:
```
VERDICT: APPROVE | CHANGES REQUESTED
[BLOCKER|MAJOR|MINOR] path:line — problem — concrete failure scenario — suggested fix
Missing coverage: REQ-… without a test | none
Unspecified edge cases: <case> → proposed REQ (EARS) | none
Race risks: <state> — <interleaving> — <mechanism missing> | none
```
Focus: spec conformance (every REQ implemented and tested), capability files updated to match, correctness, edge cases the spec missed (the categories in `docs/specs/_templates/requirements.md`), races on shared state (every read-then-write needs an atomic mechanism and a parallel test, see constitution article 11), contracts vs. design.md, security, and scope creep. Skip style issues (formatters handle those). Don't modify files during a review.
