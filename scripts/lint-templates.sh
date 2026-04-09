#!/usr/bin/env bash
#
# Lint dotclaude templates against frontmatter, size budgets, and portability rules.
#
# Usage:
#   lint-templates.sh                   lint everything
#   lint-templates.sh <path>            lint a single file
#   lint-templates.sh commands/commit.md
#

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"

# size budgets (in characters)
BUDGET_COMMAND=1000
BUDGET_SKILL=1500
BUDGET_RULE=1500
BUDGET_AGENT=2000

total_files=0
total_failures=0

# -------- helpers --------

# print "✓ " or "✗ " prefix and track failures per file
file_failures=0
pass() { printf '  \033[32m✓\033[0m %s\n' "$1"; }
fail() { printf '  \033[31m✗\033[0m %s\n' "$1"; file_failures=$((file_failures + 1)); }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }

# get body (everything after the second ---) and byte count
get_body_size() {
  awk '
    BEGIN { in_fm=0; past_fm=0 }
    /^---$/ { if (!past_fm) { if (in_fm) { past_fm=1; next } else { in_fm=1; next } } }
    past_fm { print }
  ' "$1" | wc -c | tr -d ' '
}

has_frontmatter() {
  head -n 1 "$1" | grep -q '^---$'
}

get_frontmatter_value() {
  local file="$1"
  local key="$2"
  awk -v k="$key" '
    /^---$/ { fm++; if (fm==2) exit; next }
    fm==1 {
      if (match($0, "^" k ":[[:space:]]*")) {
        val = substr($0, RLENGTH+1)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)
        print val
        exit
      }
    }
  ' "$file"
}

# -------- per-type linters --------

lint_common() {
  local file="$1"

  if ! has_frontmatter "$file"; then
    fail "missing frontmatter (file must start with ---)"
    return
  fi
  pass "frontmatter present"

  local desc
  desc="$(get_frontmatter_value "$file" description)"
  if [[ -z "$desc" ]]; then
    fail "frontmatter missing 'description'"
  elif [[ "$desc" =~ TODO|FIXME|Lorem|\<.*\> ]]; then
    fail "description looks like a placeholder: $desc"
  elif [[ ${#desc} -gt 500 ]]; then
    fail "description too long (${#desc} chars, max 500)"
  else
    pass "description ok (${#desc} chars)"
  fi

  # portability: no absolute paths
  if grep -qE '(/home/|/Users/|^C:\\|[^a-zA-Z]C:\\)' "$file"; then
    fail "contains hard-coded absolute path"
  else
    pass "no hard-coded paths"
  fi
}

lint_size() {
  local file="$1"
  local budget="$2"
  local label="$3"

  local size
  size="$(get_body_size "$file")"

  if [[ $size -gt $budget ]]; then
    fail "$label body $size chars exceeds budget $budget — push detail to sibling files"
  else
    pass "$label body $size/$budget chars"
  fi
}

lint_command() {
  local file="$1"
  lint_common "$file"
  lint_size "$file" "$BUDGET_COMMAND" "command"
}

lint_skill() {
  local file="$1"
  lint_common "$file"

  local name
  name="$(get_frontmatter_value "$file" name)"
  if [[ -z "$name" ]]; then
    fail "skill frontmatter missing 'name'"
  else
    local dir
    dir="$(basename "$(dirname "$file")")"
    if [[ "$name" != "$dir" ]]; then
      fail "skill name '$name' does not match directory '$dir'"
    else
      pass "skill name matches directory"
    fi
  fi

  # trigger phrasing
  local desc
  desc="$(get_frontmatter_value "$file" description)"
  if [[ ! "$desc" =~ [Uu]se|[Ww]hen ]]; then
    warn "description should mention a trigger (e.g., 'Use this skill when...')"
  fi

  lint_size "$file" "$BUDGET_SKILL" "skill"
}

lint_rule() {
  local file="$1"
  lint_common "$file"
  lint_size "$file" "$BUDGET_RULE" "rule"
}

lint_agent() {
  local file="$1"
  lint_common "$file"

  local name
  name="$(get_frontmatter_value "$file" name)"
  local basename_no_ext
  basename_no_ext="$(basename "$file" .md)"
  if [[ -n "$name" && "$name" != "$basename_no_ext" ]]; then
    fail "agent name '$name' does not match filename '$basename_no_ext'"
  fi

  lint_size "$file" "$BUDGET_AGENT" "agent"
}

lint_claude_md() {
  local file="$1"
  # CLAUDE.md does not use frontmatter. It has its own budget and portability checks.
  local size
  size="$(wc -c < "$file" | tr -d ' ')"
  if [[ $size -gt 8000 ]]; then
    fail "CLAUDE.md $size chars exceeds 8000 — keep it under ~200 lines"
  else
    pass "CLAUDE.md size $size/8000 chars"
  fi

  if grep -qE '(/home/|/Users/|^C:\\|[^a-zA-Z]C:\\)' "$file"; then
    fail "contains hard-coded absolute path"
  else
    pass "no hard-coded paths"
  fi
}

# -------- dispatcher --------

lint_file() {
  local file="$1"

  if [[ ! -e "$file" ]]; then
    printf '\033[31m✗\033[0m %s (not found)\n' "$file"
    total_failures=$((total_failures + 1))
    return
  fi

  # skip READMEs and non-.md files
  case "$file" in
    */README.md) return ;;
    *.md) : ;;
    *) return ;;
  esac

  total_files=$((total_files + 1))
  file_failures=0

  printf '\n\033[1m%s\033[0m\n' "$file"

  case "$file" in
    */commands/*.md|commands/*.md)  lint_command "$file" ;;
    */skills/*/SKILL.md|skills/*/SKILL.md) lint_skill "$file" ;;
    */rules/*.md|rules/*.md)        lint_rule "$file" ;;
    */agents/*.md|agents/*.md)      lint_agent "$file" ;;
    */CLAUDE.md|CLAUDE.md)          lint_claude_md "$file" ;;
    *) warn "unknown template type, skipping type-specific checks"; lint_common "$file" ;;
  esac

  if [[ $file_failures -gt 0 ]]; then
    total_failures=$((total_failures + 1))
  fi
}

# -------- main --------

if [[ $# -eq 0 ]]; then
  # lint everything
  while IFS= read -r -d '' f; do
    lint_file "$f"
  done < <(
    find "$REPO/commands" "$REPO/skills" "$REPO/rules" "$REPO/agents" \
         -type f -name '*.md' -print0 2>/dev/null
  )
  # also lint root CLAUDE.md
  [[ -e "$REPO/CLAUDE.md" ]] && lint_file "$REPO/CLAUDE.md"
else
  # lint specific files
  for arg in "$@"; do
    # resolve relative to repo if not absolute
    if [[ "$arg" = /* ]]; then
      lint_file "$arg"
    else
      lint_file "$REPO/$arg"
    fi
  done
fi

echo
if [[ $total_failures -eq 0 ]]; then
  printf '\033[32mall clean\033[0m — %d files linted\n' "$total_files"
  exit 0
else
  printf '\033[31m%d/%d files failed\033[0m\n' "$total_failures" "$total_files"
  exit 1
fi
