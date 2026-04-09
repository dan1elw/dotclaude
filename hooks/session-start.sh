#!/usr/bin/env bash
# SessionStart hook. Output is injected into the Claude Code session as context.
# Keep output short — every line costs tokens at session start.

set -euo pipefail

if ! git rev-parse --git-dir > /dev/null 2>&1; then
  exit 0
fi

branch="$(git branch --show-current 2>/dev/null || echo 'detached')"
last_commit="$(git log -1 --pretty=format:'%h %s' 2>/dev/null || echo 'none')"
staged="$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')"
unstaged="$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')"
stashed="$(git stash list 2>/dev/null | wc -l | tr -d ' ')"

cat <<EOF
## git state
- branch: $branch
- last commit: $last_commit
- staged files: $staged
- unstaged files: $unstaged
- stashes: $stashed
EOF
