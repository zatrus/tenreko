#!/usr/bin/env bash
# PreToolUse (Bash): block destructive or rule-breaking shell commands.
# Deterministic backstop for the rules in CLAUDE.md and .claude/rules/git.md.
#
# Branch ownership: branches the agent creates are recorded in <git-dir>/claude-branches
# (never committed). The agent may push only to those. The human can allow another branch with:
#   echo <branch> >> .git/claude-branches
set -uo pipefail
source "$(dirname "$0")/lib.sh"

input="$(cat)"
cmd="$(json_field "$input" command)"
[[ -z "$cmd" ]] && exit 0

check() { # check <extended-regex> <reason>
  if printf '%s' "$cmd" | grep -Eq -- "$1"; then block "$2"; fi
}

# ---------- always blocked ----------
check 'git[[:space:]]+push([^|;&]*)(--force([^-]|$)|[[:space:]]-f([[:space:]]|$))' \
  "force push needs an explicit human GO. Use --force-with-lease only when told to."
check 'git[[:space:]]+reset[[:space:]]+--hard' \
  "git reset --hard discards work. Ask the human first."
check 'git[[:space:]]+(commit|push|merge)[^|;&]*--no-verify' \
  "hooks must not be skipped. Fix what the hook reports."
check 'git[[:space:]]+clean[[:space:]]+-[a-zA-Z]*f' \
  "git clean -f deletes untracked files. Ask the human first."
check 'rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f?[[:space:]]+(/|~|\$HOME|\.|\*)([[:space:]]|$)' \
  "recursive delete of a root/home/cwd path."
check '(cat|less|more|head|tail|type)[[:space:]]+[^|;&]*\.env([[:space:]]|$)' \
  ".env holds secrets. Don't print it."
check '(npm|yarn|pnpm)[[:space:]]+publish|gradlew?[^|;&]*[[:space:]]publish[A-Za-z]*([[:space:]]|$)|twine[[:space:]]+upload|uv[[:space:]]+publish' \
  "publishing is public. It needs an explicit human GO."
check 'gh[[:space:]]+pr[[:space:]]+merge|gh[[:space:]]+api[^|;&]*/merge' \
  "only the human merges pull requests. Open the PR and stop."

# ---------- git branch ownership ----------
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
registry="$(git rev-parse --git-common-dir)/claude-branches"
current="$(git branch --show-current 2>/dev/null)"

owned() { [[ -f "$registry" ]] && grep -qxF -- "$1" "$registry"; }
exists() { # local branch or any remote-tracking branch with that name
  git show-ref --verify --quiet "refs/heads/$1" && return 0
  git for-each-ref --format='%(refname)' "refs/remotes/*/$1" | grep -q .
}

# Split the command into simple commands on && || ; | and newlines, then inspect each one.
while IFS= read -r seg; do
  read -ra w <<<"$seg"
  [[ "${w[0]:-}" == "git" ]] || continue
  sub="${w[1]:-}"

  case "$sub" in
    merge)
      [[ "$current" == "main" || "$current" == "master" ]] \
        && block "no merging into $current. Only the human merges into main (via the PR)." ;;

    switch|checkout|worktree|branch)
      # Record branches the agent creates. Already-existing names are not taken over.
      new=""
      for ((i = 2; i < ${#w[@]}; i++)); do
        case "${w[i]}" in
          -b|-B|-c|-C) new="${w[i+1]:-}"; break ;;
        esac
      done
      if [[ -z "$new" && "$sub" == "branch" && -n "${w[2]:-}" && "${w[2]}" != -* ]]; then
        new="${w[2]}"
      fi
      if [[ -n "$new" ]]; then
        if exists "$new"; then
          owned "$new" || echo "NOTE: branch '$new' already exists and was not created by the agent; pushes to it will be blocked." >&2
        else
          owned "$new" || echo "$new" >>"$registry"
        fi
      fi ;;

    push)
      args=()
      for ((i = 2; i < ${#w[@]}; i++)); do
        case "${w[i]}" in
          --all|--mirror|--tags|--delete|-d|--prune)
            block "git push ${w[i]} touches branches/tags the agent doesn't own. Ask the human." ;;
          -*) ;;
          *) args+=("${w[i]}") ;;
        esac
      done
      # args = [remote] [refspec...]; without a refspec git pushes the current branch.
      targets=()
      if (( ${#args[@]} <= 1 )); then
        targets=("$current")
      else
        for ref in "${args[@]:1}"; do
          [[ "$ref" == +* ]] && block "'$ref' is a force push. It needs an explicit human GO."
          dst="${ref#*:}"
          [[ "$ref" == :* ]] && block "'$ref' deletes a remote branch. Ask the human."
          [[ "$dst" == "HEAD" ]] && dst="$current"
          targets+=("${dst#refs/heads/}")
        done
      fi
      for t in "${targets[@]}"; do
        [[ -z "$t" ]] && block "can't tell which branch this push targets (detached HEAD?)."
        [[ "$t" == "main" || "$t" == "master" ]] && block "no pushes to $t. Push your feature branch and open a PR; the human merges."
        owned "$t" || block "branch '$t' was not created by the agent, so it may not push to it. If that's intended, the human runs: echo $t >> .git/claude-branches"
      done ;;
  esac
done < <(printf '%s\n' "$cmd" | sed -E 's/(&&|\|\||;|\|)/\n/g')

exit 0
