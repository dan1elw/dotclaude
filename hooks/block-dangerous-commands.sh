#!/usr/bin/env bash
# PreToolUse hook for Bash. Blocks destructive commands regardless of permission config.
# Exit 0 = allow, exit 1 = block.

set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "block-dangerous-commands.sh: jq not found; install with 'brew install jq' or 'apt install jq'" >&2
  exit 0
fi

input="$(cat)"
cmd="$(echo "$input" | jq -r '.tool_input.command // empty')"

if [[ -z "$cmd" ]]; then
  exit 0
fi

# Patterns to block. Extend carefully — false positives are worse than false negatives here.
patterns=(
  'rm[[:space:]]+-rf?[[:space:]]+/'
  'rm[[:space:]]+-rf?[[:space:]]+~'
  'git[[:space:]]+push[[:space:]]+.*--force'
  'git[[:space:]]+push[[:space:]]+-f'
  'git[[:space:]]+reset[[:space:]]+--hard[[:space:]]+origin'
  ':\(\)\{.*\|.*&.*\};:'
  'mkfs\.'
  'dd[[:space:]]+if=.*of=/dev/'
  'DROP[[:space:]]+(TABLE|DATABASE|SCHEMA)'
  '>[[:space:]]*/dev/sd[a-z]'
  'chmod[[:space:]]+-R[[:space:]]+777[[:space:]]+/'
)

for pat in "${patterns[@]}"; do
  if echo "$cmd" | grep -qiE "$pat"; then
    echo "blocked by block-dangerous-commands.sh: matched pattern '$pat'" >&2
    echo "command: $cmd" >&2
    exit 1
  fi
done

exit 0
