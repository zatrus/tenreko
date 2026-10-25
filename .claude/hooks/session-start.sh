#!/usr/bin/env bash
# SessionStart: give the new session the live facts NOW.md can't know (stdout goes into context).
# NOW.md itself is imported by CLAUDE.md, so it isn't repeated here.
set -uo pipefail
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

echo "## Session facts (from session-start hook)"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "- Branch: $(git branch --show-current 2>/dev/null || echo detached)"
  dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  echo "- Uncommitted files: $dirty"
  echo "- Last commit: $(git log -1 --format='%h %s (%cr)' 2>/dev/null || echo none)"
else
  echo "- Not a git repository yet (run: git init)"
fi

if [[ -f docs/state/inbox.md ]]; then
  open_re='^[0-9]{4}-.*status: open[[:space:]]*$'
  open=$(grep -Ec "$open_re" docs/state/inbox.md 2>/dev/null || true)
  owner=$(grep -E "$open_re" docs/state/inbox.md 2>/dev/null | grep -c 'NEEDS OWNER' || true)
  echo "- Inbox: ${open:-0} open (${owner:-0} NEEDS OWNER)"
  grep -E "$open_re" docs/state/inbox.md 2>/dev/null | grep 'NEEDS OWNER' | head -5 | sed 's/^/  - /'
fi

left=$(grep -l '{{' CLAUDE.md README.md docs/BUSINESS.md docs/state/NOW.md 2>/dev/null | tr '\n' ' ')
[[ -n "$left" ]] && echo "- WARNING: unfilled {{placeholders}} in: $left(run /project-init, or fill them)"

if [[ -f docs/state/NOW.md ]]; then
  lines=$(wc -l < docs/state/NOW.md | tr -d ' ')
  (( lines > 40 )) && echo "- WARNING: NOW.md has $lines lines (max 40). Trim it at the next /wrap-up."
fi
exit 0
