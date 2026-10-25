# AGENTS.md

Instructions for AI coding agents that aren't Claude Code (Codex, Gemini CLI, Cursor, etc.). Claude Code reads `CLAUDE.md`. Both describe the same project and rules.

A typical use is an **independent pre-merge review** by a different vendor's model: a second pair of eyes that didn't write the code.

## Read first
1. `docs/constitution.md`: non-negotiable principles
2. `CLAUDE.md`: workflow, quality gate, hard rules
3. `.claude/rules/*.md`: coding, testing, security, git, and the stack rules
4. The spec for the change: `docs/specs/NNN-slug/{requirements,design,tasks}.md`

## Quality gate
`bash scripts/check.sh` must pass. Never weaken lint, type, test, or coverage settings.

## When asked to review
Review `git diff main...HEAD` against the spec. Report findings as:
```
VERDICT: APPROVE | CHANGES REQUESTED
[BLOCKER|MAJOR|MINOR] path:line — problem — concrete failure scenario — suggested fix
Missing coverage: REQ-… without a test | none
```
Focus: spec conformance (every REQ implemented and tested), correctness, contracts vs. design.md, security, and scope creep. Skip style issues (formatters handle those). Don't modify files during a review.
