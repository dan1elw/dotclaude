# Commands

Single-file slash commands loaded from `.claude/commands/*.md`. Invoked as `/name <args>`.

## Frontmatter

```yaml
---
description: One sentence, under 100 chars    # required
argument-hint: "<issue #>"                    # optional, shown in /help
allowed-tools: Read, Grep, Bash(git *)        # optional, restricts tools
model: sonnet                                 # optional
---
```

## Dynamic features

- `$ARGUMENTS` — injects text passed after the command name
- `!` backtick syntax — embeds shell command output into the prompt
- `@path/to/file` — includes file content

Example:
```markdown
---
description: Show current git status and diff, then summarize changes
allowed-tools: Bash(git status), Bash(git diff:*)
---

Current branch: !`git branch --show-current`
Staged changes: !`git diff --cached --stat`

Summarize what changed in plain English.
```

## Commands vs skills

Commands are single-file and always explicit (`/name`). Skills are directories that can bundle supporting files and may auto-invoke based on their description. Use commands for short, explicit workflows; use skills for richer capabilities with dependencies.
