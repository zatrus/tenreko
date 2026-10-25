#!/usr/bin/env bash
# PreToolUse (Edit|Write|MultiEdit): stop edits to files that must never be hand-edited.
set -uo pipefail
source "$(dirname "$0")/lib.sh"

input="$(cat)"
path="$(norm_path "$(json_field "$input" file_path)")"
[[ -z "$path" ]] && exit 0
name="$(basename "$path")"

case "$name" in
  .env|.env.*)
    [[ "$name" == ".env.example" ]] || block "$name holds secrets. Document keys in .env.example instead." ;;
  package-lock.json|uv.lock|poetry.lock|yarn.lock|pnpm-lock.yaml|gradle.lockfile)
    block "$name is generated. Change dependencies with the package manager (npm install / uv add)." ;;
  gradlew|gradlew.bat|gradle-wrapper.jar|gradle-wrapper.properties)
    block "Gradle wrapper files are generated. Update with: ./gradlew wrapper --gradle-version <x.y>" ;;
esac

case "$path" in
  */.git/*|*/node_modules/*|*/target/*|*/dist/*|*/build/*|*/.gradle/*|*/.venv/*|*/coverage/*)
    block "$path is generated or vendored output." ;;
  */docs/constitution.md)
    # Allowed, but the human must approve. Claude Code still shows its normal permission prompt.
    echo "NOTE: constitution changes need a human GO and an ADR." >&2 ;;
esac

exit 0
