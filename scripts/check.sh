#!/usr/bin/env bash
# Quality gate: the single command that decides "done". Same locally, in hooks, and in CI.
#
#   bash scripts/check.sh          format-check + lint + typecheck + tests + coverage
#   bash scripts/check.sh --fix    apply formatters/autofixes, then run the gate
#
# Detects the stack from files in the repo root. Exit code 0 = GREEN, non-zero = RED.
set -euo pipefail

cd "$(dirname "$0")/.."

FIX=false
[[ "${1:-}" == "--fix" ]] && FIX=true

step() { printf '\n\033[1m▶ %s\033[0m\n' "$*"; }
ran=false

# ---------- Node / TypeScript ----------
if [[ -f package.json ]]; then
  ran=true
  [[ -d node_modules ]] || { step "npm ci"; npm ci --no-audit --no-fund; }
  if $FIX; then step "npm run fix"; npm run fix; fi
  step "npm run check"
  npm run check
fi

# ---------- Python (uv) ----------
if [[ -f pyproject.toml ]]; then
  ran=true
  if command -v uv >/dev/null 2>&1; then
    run() { uv run --frozen "$@"; }
    step "uv sync"; uv sync --frozen 2>/dev/null || uv sync
  else
    echo "WARN: uv not found; using tools from the active environment" >&2
    run() { "$@"; }
  fi
  if $FIX; then
    step "ruff format + ruff check --fix"
    run ruff format .
    run ruff check --fix .
  fi
  step "ruff format --check"; run ruff format --check .
  step "ruff check";          run ruff check .
  step "mypy";                run mypy src tests
  step "pytest";              run pytest
fi

# ---------- Java / Spring Boot (Gradle wrapper) ----------
if [[ -f build.gradle.kts || -f build.gradle ]]; then
  ran=true
  GRADLE=./gradlew
  [[ -x "$GRADLE" ]] || { echo "ERROR: ./gradlew missing or not executable. Run /project-init or 'chmod +x gradlew'." >&2; exit 1; }
  if $FIX; then step "gradlew spotlessApply"; "$GRADLE" --console=plain -q spotlessApply; fi
  step "gradlew check"
  "$GRADLE" --console=plain check
fi

if ! $ran; then
  echo "ERROR: no package.json, pyproject.toml or build.gradle.kts found. Run /project-init first." >&2
  exit 1
fi

printf '\n\033[1;32m✔ GATE GREEN\033[0m\n'
