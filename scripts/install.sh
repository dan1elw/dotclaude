#!/usr/bin/env bash
#
# Install dotclaude template into the current project.
#
# Copies:
#   CLAUDE.md                     -> <target>/CLAUDE.md
#   CLAUDE.local.md.example       -> <target>/CLAUDE.local.md        (renamed, if missing)
#   settings.json                 -> <target>/.claude/settings.json
#   settings.local.json.example   -> <target>/.claude/settings.local.json (renamed, if missing)
#   rules/      commands/   skills/   agents/   hooks/   -> <target>/.claude/...
#
# The meta workshop (<repo>/.claude/) and scripts/ are NEVER copied.
#
# Usage:
#   install.sh                    copy, skip existing files
#   install.sh --force            overwrite existing files
#   install.sh --dry-run          show what would happen
#   install.sh --only rules,skills    copy only selected components
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET="$(pwd)"

FORCE=0
DRY_RUN=0
ONLY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)   FORCE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --only)    ONLY="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

# Guard: don't install into the dotclaude repo itself
if [[ "$TARGET" == "$REPO" ]]; then
  echo "refusing to install into the dotclaude repo itself" >&2
  exit 1
fi

COMPONENTS=(rules commands skills agents hooks)
if [[ -n "$ONLY" ]]; then
  IFS=',' read -r -a COMPONENTS <<< "$ONLY"
fi

echo "source: $REPO"
echo "target: $TARGET"
echo "components: ${COMPONENTS[*]}"
[[ $DRY_RUN -eq 1 ]] && echo "(dry run)"
echo

copied=0
skipped=0
overwritten=0

# copy_file <src> <dst>
copy_file() {
  local src="$1"
  local dst="$2"
  local rel="${dst#"$TARGET"/}"

  if [[ ! -e "$src" ]]; then
    return 0
  fi

  if [[ -e "$dst" && $FORCE -eq 0 ]]; then
    echo "skip   $rel"
    ((skipped++)) || true
    return 0
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    if [[ -e "$dst" ]]; then
      echo "force  $rel (dry-run)"
    else
      echo "copy   $rel (dry-run)"
    fi
    return 0
  fi

  mkdir -p "$(dirname "$dst")"

  if [[ -e "$dst" ]]; then
    cp "$src" "$dst"
    echo "force  $rel"
    ((overwritten++)) || true
  else
    cp "$src" "$dst"
    echo "copy   $rel"
    ((copied++)) || true
  fi
}

# copy_dir <src-dir> <dst-dir>
copy_dir() {
  local src="$1"
  local dst="$2"

  if [[ ! -d "$src" ]]; then
    return 0
  fi

  while IFS= read -r -d '' file; do
    local rel="${file#"$src"/}"
    copy_file "$file" "$dst/$rel"
  done < <(find "$src" -type f -print0)
}

# ----- top-level files -----
copy_file "$REPO/CLAUDE.md"     "$TARGET/CLAUDE.md"

# CLAUDE.local.md and settings.local.json are renamed from .example and only copied if missing.
if [[ ! -e "$TARGET/CLAUDE.local.md" ]]; then
  copy_file "$REPO/CLAUDE.local.md.example" "$TARGET/CLAUDE.local.md"
fi

copy_file "$REPO/settings.json" "$TARGET/.claude/settings.json"

if [[ ! -e "$TARGET/.claude/settings.local.json" ]]; then
  copy_file "$REPO/settings.local.json.example" "$TARGET/.claude/settings.local.json"
fi

# ----- component directories -----
for comp in "${COMPONENTS[@]}"; do
  copy_dir "$REPO/$comp" "$TARGET/.claude/$comp"
done

# ----- post-install: make hooks executable -----
if [[ $DRY_RUN -eq 0 && -d "$TARGET/.claude/hooks" ]]; then
  find "$TARGET/.claude/hooks" -type f -name '*.sh' -exec chmod +x {} \;
fi

# ----- post-install: strip README.md files from .claude/ subdirs to save tokens -----
# These READMEs are for humans browsing the repo, not for Claude to load at runtime.
if [[ $DRY_RUN -eq 0 ]]; then
  for comp in "${COMPONENTS[@]}"; do
    readme="$TARGET/.claude/$comp/README.md"
    [[ -e "$readme" ]] && rm -f "$readme"
  done
fi

echo
echo "done. copied=$copied overwritten=$overwritten skipped=$skipped"
echo
echo "next steps:"
echo "  1. restart Claude Code (skills, rules, and agents load at session start)"
echo "  2. edit CLAUDE.md and fill in your project's stack, commands, and conventions"
echo "  3. review .claude/settings.json and adjust permissions for your package manager"
