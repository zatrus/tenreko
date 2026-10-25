# Spec-driven Claude Code project template

A starting point for **npm/TypeScript, Python, Java, and Spring Boot** projects built with Claude Code using **spec-driven development**: requirements → design → tasks → test-first implementation → verification, with a human `GO` at every gate.

It takes the working practices from the PilcrowMD multi-agent setup (lean startup context, self-written `NOW` handover, model tiering, independent review, "facts only from tools") and adds spec-driven and quality-engineering practices on top. The full rationale is in [`docs/WORKFLOW.md`](docs/WORKFLOW.md).

## Quick start

```bash
# 1. copy the template (including dotfiles) into a new folder
cp -r template/. ../my-service && cd ../my-service

# 2. open Claude Code and bootstrap one stack (copies a verified scaffold, renames, proves the gate is green)
claude
> /project-init spring-boot my-service com.acme.myservice     # or: node | python | java

# 3. build features the spec-driven way
> /spec-new Users can reset their password via an emailed link
> /edge-cases      # optional: any time, on a spec, a file, or the diff
> /spec-design      # after you reply GO
> /spec-tasks       # after GO
> /spec-implement all
> /spec-verify
> /wrap-up          # end of every session
```

Small changes don't need the full flow. See *Workflow* in `CLAUDE.md` for the trivial / bug / feature triage.

## What's inside

```
CLAUDE.md                     lean always-loaded rules (workflow, gate, 10 hard rules, reporting, budget)
AGENTS.md                     same rules for other vendors' agents (Codex/Gemini cross-review)
CONTRIBUTING.md               one page for human contributors, definition of done
.claude/
  settings.json               permissions (allow / ask / deny) and hooks
  rules/                      path-scoped rules, loaded only when matching files are touched
    coding.md testing.md security.md git.md          always
    communication.md                                 always: response style, plain English, IDs explained
    specs.md                                         docs/specs/**, docs/adr/**
    node.md python.md java.md spring-boot.md         per stack (unused ones are deleted at init)
  agents/                     subagents with fixed models
    explorer (haiku) · test-runner (haiku) · implementer (sonnet) · reviewer (sonnet) · reasoner (opus)
  skills/
    project-init/             /project-init + verified scaffolds in assets/<stack>/ + README.project.md
    spec-new/ spec-design/ spec-tasks/ spec-implement/ spec-verify/
    edge-cases/               /edge-cases checklist + verified concurrency patterns (references/concurrency.md)
    bugfix/ adr/ wrap-up/ karpathy-guidelines/
  hooks/
    session-start.sh          branch, dirty files, open inbox items → context
    protect-files.sh          blocks edits to .env, lockfiles, wrappers, build output
    guard-bash.sh             pushes only to branches the agent created; blocks PR merges, merging into main,
                              force-push, --no-verify, reset --hard, publish, ...
    format-file.sh            formats each edited file (prettier / ruff)
scripts/check.sh              THE quality gate, same locally, in Claude, and in CI
.github/workflows/ci.yml      runs scripts/check.sh plus a dependency audit
docs/
  constitution.md             non-negotiable engineering principles (checked in every design)
  BUSINESS.md                 users, payers, journeys, scope, policies, the single glossary (CONFIRMED vs assumption)
  capabilities/               CURRENT behaviour, one living file per capability, stable rule IDs (CHECKOUT-3)
  specs/NNN-slug/             change records: requirements.md (EARS + AC scenarios) · design.md · tasks.md
  specs/_templates/           templates for the three files above
  adr/0000-template.md        architecture decision records
  state/NOW.md                ≤ 40-line current state, rewritten by /wrap-up, imported by CLAUDE.md
  state/archive.md            one line per finished item (not loaded at startup)
  state/inbox.md              FYI / REQUEST / NEEDS OWNER messages between parallel sessions
  facts/releases.md           the only source for public claims about what shipped
```

## Scaffolds (verified on 2026-10-24)

Each `assets/<stack>/` passed its own gate as shipped (format + lint + types + tests + coverage ≥ 80%):

| Stack | Toolchain | Gate |
|---|---|---|
| node | Node 24, TypeScript 6.0 (strict), ESLint 10 + typescript-eslint strict-type-checked, Prettier 3, Vitest 5 | `npm run check` |
| python | Python ≥ 3.13, uv, Ruff 0.17 (format and lint, incl. bandit rules), mypy 2.4 strict, pytest 9 + pytest-cov | ruff, mypy, pytest |
| java | Java 25 toolchain, Gradle 9.8 wrapper (Kotlin DSL, version catalog, configuration + build cache), Spotless (google-java-format), `-Xlint:all -Werror`, JUnit 6, AssertJ, `test` + `integrationTest` suites, JaCoCo | `./gradlew check` |
| spring-boot | Same Gradle setup + Spring Boot 4.1.2 (webmvc, validation, actuator, ProblemDetail, ECS logs), slice tests (`@WebMvcTest` + `MockMvcTester`), `*IT` full-context tests in `src/integrationTest`; JPA/Flyway/Testcontainers ready to uncomment | `./gradlew check` |

TypeScript is pinned to 6.0 because typescript-eslint 8.72 supports `<6.1`. Move to TS 7 once typescript-eslint does.

After `/project-init`, this README is replaced by a README for your project (`assets/README.project.md`). The template's rationale stays in `docs/WORKFLOW.md`.

## Customise

- **Your principles:** `docs/constitution.md` → *Project-specific additions*.
- **Stricter or looser rules:** edit `.claude/rules/*.md`. Keep each file short, because rules are instructions and not documentation.
- **Hard enforcement:** anything that must *never* happen belongs in a hook or the gate, not only in a rule.
- **Personal overrides:** `.claude/settings.local.json` and `CLAUDE.local.md` (both git-ignored).
