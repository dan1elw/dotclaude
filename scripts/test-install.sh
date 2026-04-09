#!/usr/bin/env bash
#
# Integration test for scripts/install.sh.
#
# Runs the installer into a throwaway directory and verifies:
#   - expected files land in the right places
#   - CLAUDE.local.md and settings.local.json are renamed from .example
#   - hooks are executable
#   - READMEs are stripped from target .claude/ subdirs
#   - meta workshop (<repo>/.claude/, scripts/) is NOT copied
#   - --dry-run writes nothing
#   - --only flag limits components
#   - installer refuses to run inside the dotclaude repo itself
#
# Exit 0 = all checks pass, non-zero = failure.
#

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL="$REPO/scripts/install.sh"

failures=0
tmpdirs=()

cleanup() {
  # shellcheck disable=SC2317  # invoked via trap
  for d in "${tmpdirs[@]}"; do
    # shellcheck disable=SC2317
    [[ -d "$d" ]] && rm -rf "$d"
  done
}
trap cleanup EXIT

pass() { printf '  \033[32m✓\033[0m %s\n' "$1"; }
fail() { printf '  \033[31m✗\033[0m %s\n' "$1"; failures=$((failures + 1)); }

new_tmp() {
  local d
  d="$(mktemp -d)"
  tmpdirs+=("$d")
  echo "$d"
}

assert_file() {
  local path="$1"
  local desc="$2"
  if [[ -f "$path" ]]; then
    pass "$desc"
  else
    fail "$desc (missing: $path)"
  fi
}

assert_not_exists() {
  local path="$1"
  local desc="$2"
  if [[ ! -e "$path" ]]; then
    pass "$desc"
  else
    fail "$desc (should not exist: $path)"
  fi
}

assert_executable() {
  local path="$1"
  local desc="$2"
  if [[ -x "$path" ]]; then
    pass "$desc"
  else
    fail "$desc (not executable: $path)"
  fi
}

# ---------- test 1: full install ----------
printf '\n\033[1mtest 1: full install\033[0m\n'
t1="$(new_tmp)"
cd "$t1" || exit 1
"$INSTALL" > /dev/null 2>&1 || fail "install.sh exited non-zero"

assert_file "$t1/CLAUDE.md"                                "CLAUDE.md at target root"
assert_file "$t1/CLAUDE.local.md"                          "CLAUDE.local.md renamed from .example"
assert_file "$t1/.claude/settings.json"                    "settings.json in target .claude/"
assert_file "$t1/.claude/settings.local.json"              "settings.local.json renamed from .example"
assert_file "$t1/.claude/rules/code-quality.md"            "rules/code-quality.md copied"
assert_file "$t1/.claude/commands/commit.md"               "commands/commit.md copied"
assert_file "$t1/.claude/skills/explain-code/SKILL.md"     "skills/explain-code/SKILL.md copied"
assert_file "$t1/.claude/agents/code-reviewer.md"          "agents/code-reviewer.md copied"
assert_file "$t1/.claude/hooks/block-dangerous-commands.sh" "hooks/block-dangerous-commands.sh copied"
assert_file "$t1/.claude/hooks/scan-secrets.sh"            "hooks/scan-secrets.sh copied"
assert_file "$t1/.claude/hooks/session-start.sh"           "hooks/session-start.sh copied"

assert_executable "$t1/.claude/hooks/block-dangerous-commands.sh" "block-dangerous-commands.sh is executable"
assert_executable "$t1/.claude/hooks/scan-secrets.sh"             "scan-secrets.sh is executable"
assert_executable "$t1/.claude/hooks/session-start.sh"            "session-start.sh is executable"

# READMEs should have been stripped from the target .claude/ subdirs
assert_not_exists "$t1/.claude/rules/README.md"    "rules/README.md stripped"
assert_not_exists "$t1/.claude/commands/README.md" "commands/README.md stripped"
assert_not_exists "$t1/.claude/skills/README.md"   "skills/README.md stripped"
assert_not_exists "$t1/.claude/agents/README.md"   "agents/README.md stripped"
assert_not_exists "$t1/.claude/hooks/README.md"    "hooks/README.md stripped"

# Meta workshop and scripts must NEVER end up in the target
assert_not_exists "$t1/.claude/CLAUDE.md"             "meta .claude/CLAUDE.md not copied"
assert_not_exists "$t1/.claude/commands/new-skill.md" "meta new-skill command not copied"
assert_not_exists "$t1/scripts"                       "scripts/ not copied"
assert_not_exists "$t1/.github"                       ".github/ not copied"

# ---------- test 2: dry-run writes nothing ----------
printf '\n\033[1mtest 2: --dry-run writes nothing\033[0m\n'
t2="$(new_tmp)"
cd "$t2" || exit 1
"$INSTALL" --dry-run > /dev/null 2>&1 || fail "install.sh --dry-run exited non-zero"

if [[ -z "$(find "$t2" -mindepth 1 -print -quit)" ]]; then
  pass "target directory is empty after --dry-run"
else
  fail "target directory has files after --dry-run"
fi

# ---------- test 3: --only limits components ----------
printf '\n\033[1mtest 3: --only rules,commands\033[0m\n'
t3="$(new_tmp)"
cd "$t3" || exit 1
"$INSTALL" --only rules,commands > /dev/null 2>&1 || fail "install.sh --only exited non-zero"

assert_file     "$t3/.claude/rules/code-quality.md"  "rules copied with --only rules,commands"
assert_file     "$t3/.claude/commands/commit.md"     "commands copied with --only rules,commands"
assert_not_exists "$t3/.claude/skills"               "skills NOT copied with --only rules,commands"
assert_not_exists "$t3/.claude/agents"               "agents NOT copied with --only rules,commands"
assert_not_exists "$t3/.claude/hooks"                "hooks NOT copied with --only rules,commands"

# ---------- test 4: --force overwrites ----------
printf '\n\033[1mtest 4: --force overwrites existing files\033[0m\n'
t4="$(new_tmp)"
cd "$t4" || exit 1
echo "original content" > "$t4/CLAUDE.md"
"$INSTALL" > /dev/null 2>&1 || true
if grep -q "original content" "$t4/CLAUDE.md"; then
  pass "default install did not overwrite existing CLAUDE.md"
else
  fail "default install overwrote existing CLAUDE.md (should skip)"
fi

"$INSTALL" --force > /dev/null 2>&1 || fail "install.sh --force exited non-zero"
if grep -q "original content" "$t4/CLAUDE.md"; then
  fail "--force did not overwrite existing CLAUDE.md"
else
  pass "--force overwrote existing CLAUDE.md"
fi

# ---------- test 5: refuses to install into the repo itself ----------
printf '\n\033[1mtest 5: refuses self-install\033[0m\n'
cd "$REPO" || exit 1
if "$INSTALL" > /dev/null 2>&1; then
  fail "installer should have refused self-install"
else
  pass "installer refused to install into the repo itself"
fi

# ---------- summary ----------
echo
if [[ $failures -eq 0 ]]; then
  printf '\033[32mall install tests passed\033[0m\n'
  exit 0
else
  printf '\033[31m%d install test(s) failed\033[0m\n' "$failures"
  exit 1
fi
