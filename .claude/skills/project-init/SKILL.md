---
name: project-init
description: Bootstrap this template into a real project for one stack (node, python, java, spring-boot) - copy the verified scaffold with formatter, linter, type checker, tests, coverage gate and CI, rename the package, fill CLAUDE.md placeholders, remove rules for unused stacks, and prove the gate is green. Use once, right after copying the template.
argument-hint: "<node|python|java|spring-boot> <project-name> [base package / group id, e.g. com.acme.billing]"
disable-model-invocation: true
---

# /project-init: from template to a green project

Arguments: **$ARGUMENTS**. Expected: `<stack> <project-name> [package]`. If any are missing, ask once (suggest: stack from what's already in the folder, name from the folder name, package `com.<org>.<name>` for Java).

Scaffolds live next to this file in `assets/<stack>/`. They are verified to pass their gate as shipped. Don't "improve" them during init.

## 1. Preconditions
- The repo root has no `package.json`, `pyproject.toml`, or `build.gradle.kts` yet. If one exists, stop and ask. This skill is for new projects; for an existing codebase, keep its build and only adopt `CLAUDE.md`, `.claude/`, `docs/` and `scripts/check.sh` (then adapt `scripts/check.sh`).
- Toolchain present? Check, and report what's missing with install hints. Don't install it globally yourself:
  - node: `node --version` (≥ 24), `npm --version`
  - python: `uv --version` (install: https://docs.astral.sh/uv/)
  - java / spring-boot: `java -version` (≥ 25; otherwise the Gradle toolchain downloads one). Gradle itself isn't needed (the wrapper downloads it).

## 2. Copy the scaffold
Copy every file from `assets/<stack>/` to the repo root, including dotfiles. For `java` and `spring-boot`, also copy `assets/gradle-wrapper/` (gives `gradlew`, `gradlew.bat`, `gradle/wrapper/`), then run `chmod +x gradlew`.
Append `assets/<stack>/gitignore.append` to `.gitignore` and don't copy the `.append` file itself.

## 3. Rename
- **node:** `"name"` in `package.json`.
- **python:** `name` in `pyproject.toml`; rename `src/app/` → `src/<pkg>/` (snake_case); update `packages`, `--cov=`, `source`, and imports in tests.
- **java / spring-boot:** `group` in `build.gradle.kts`, `rootProject.name` in `settings.gradle.kts`; move `com/example/app` → the new package path in `src/main/java`, `src/test/java` and (spring-boot) `src/integrationTest/java`; update `package` and `import` lines; `spring.application.name` in `application.yml`.
Then `grep -ri "com.example\|\"app\"\|src/app" .` (excluding `.claude/`) must find nothing left over.

## 4. Fit the Claude setup to the stack
- In `.claude/rules/`, delete the rule files for stacks you don't use (`node.md`, `python.md`, `java.md`, `spring-boot.md`). Spring Boot keeps both `java.md` and `spring-boot.md`.
- In `.github/workflows/ci.yml`, keep only the job for this stack.
- Fill the `{{…}}` placeholders in `CLAUDE.md` (name, stack, purpose: ask the human for a one-line purpose) and the *Commands* section:

| Stack | Install | Run | Test one |
|---|---|---|---|
| node | `npm ci` | `npm run dev` | `npx vitest run src/x.test.ts -t "name"` |
| python | `uv sync` | `uv run python -m <pkg>` | `uv run pytest tests/unit/test_x.py::test_name` |
| java | `./gradlew build` | `./gradlew run` (add the `application` plugin when needed) | `./gradlew test --tests "com.acme.XTest.method"` |
| spring-boot | `./gradlew build` | `./gradlew bootRun --args='--spring.profiles.active=local'` | `./gradlew test --tests "com.acme.XTest.method"` |

- Python: generate the lockfile with `uv lock` (the hook blocks hand-edits; `uv` writes it).
- Node: `npm install` creates `package-lock.json`.

## 5. Prove it
1. `bash scripts/check.sh --fix`, then `bash scripts/check.sh`. Must end with `GATE GREEN`. Paste the summary lines.
2. `git init` (if needed) → `git add -A` → `git commit -m "chore: bootstrap <stack> project from template"`. This initial commit is the one place `git add -A` is fine (after checking `git status` for anything unexpected), and the only commit allowed directly on `main`. Don't push it: the human creates the remote and pushes `main`.
3. Fill `docs/constitution.md` → *Project-specific additions* with the human (or delete the placeholder line).
4. Rewrite `docs/state/NOW.md`: next step = `/spec-new <first feature>`.

The example code (`greeting`/`Greeter`) shows the conventions. Tell the human it can be deleted, together with its tests, in the first real feature's task list.

## Report
```
Initialized: <stack> · <name> · <package>
Gate: GREEN — <copied test/coverage summary>
Removed rules: …   Kept CI job: …
Next: /spec-new <idea>
Delegated: …
```
