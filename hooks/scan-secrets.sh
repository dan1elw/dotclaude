#!/usr/bin/env bash
# PreToolUse hook for Write and Edit. Blocks writes that look like they contain secrets.
# Exit 0 = allow, exit 1 = block.

set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "scan-secrets.sh: jq not found; install with 'brew install jq' or 'apt install jq'" >&2
  exit 0
fi

input="$(cat)"
content="$(echo "$input" | jq -r '.tool_input.content // .tool_input.new_string // empty')"
path="$(echo "$input" | jq -r '.tool_input.file_path // empty')"

if [[ -z "$content" ]]; then
  exit 0
fi

# Allow example and documentation files explicitly
case "$path" in
  *.example|*.sample|*.md|*README*|*example*) exit 0 ;;
esac

# Secret patterns. Prefer precise over broad to minimize false positives.
patterns=(
  'AKIA[0-9A-Z]{16}'                             # AWS access key
  'aws_secret_access_key[[:space:]]*=[[:space:]]*[A-Za-z0-9/+=]{40}'
  'ghp_[A-Za-z0-9]{36}'                          # GitHub PAT
  'gho_[A-Za-z0-9]{36}'                          # GitHub OAuth
  'xox[baprs]-[0-9A-Za-z-]{10,}'                 # Slack
  'sk-[A-Za-z0-9]{32,}'                          # OpenAI/Anthropic-style
  '-----BEGIN[[:space:]]+(RSA|EC|OPENSSH|DSA|PGP)[[:space:]]+PRIVATE[[:space:]]+KEY-----'
)

for pat in "${patterns[@]}"; do
  if echo "$content" | grep -qE -e "$pat"; then
    echo "blocked by scan-secrets.sh: matched secret pattern '$pat'" >&2
    echo "file: $path" >&2
    echo "move the secret to an env var or a gitignored file" >&2
    exit 1
  fi
done

exit 0
