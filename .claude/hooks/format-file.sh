#!/usr/bin/env bash
# PostToolUse (Edit|Write|MultiEdit): format the edited file so style never needs discussing.
# Silent no-op when the formatter isn't installed yet. Never blocks.
# Java is formatted by `bash scripts/check.sh --fix` (Spotless is too slow to run per edit).
set -uo pipefail
source "$(dirname "$0")/lib.sh"

input="$(cat)"
path="$(json_field "$input" file_path)"
[[ -z "$path" || ! -f "$path" ]] && exit 0
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

case "$path" in
  *.ts|*.tsx|*.js|*.mjs|*.cjs|*.json|*.css|*.html|*.yml|*.yaml|*.md)
    if [[ -x node_modules/.bin/prettier ]]; then
      node_modules/.bin/prettier --write --log-level warn "$path" >/dev/null 2>&1 || true
    fi ;;
  *.py)
    if command -v uv >/dev/null 2>&1 && [[ -f pyproject.toml ]]; then
      uv run --frozen ruff format -q "$path" >/dev/null 2>&1 || true
      uv run --frozen ruff check --fix -q "$path" >/dev/null 2>&1 || true
    elif command -v ruff >/dev/null 2>&1; then
      ruff format -q "$path" >/dev/null 2>&1 || true
      ruff check --fix -q "$path" >/dev/null 2>&1 || true
    fi ;;
esac

exit 0
