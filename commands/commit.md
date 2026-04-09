---
description: Review staged changes and draft a conventional commit message
allowed-tools: Bash(git status), Bash(git diff:*), Bash(git log:*)
argument-hint: "[optional scope hint]"
---

Staged files: !`git diff --cached --name-status`

Staged diff: !`git diff --cached`

Recent commit style: !`git log -10 --pretty=format:'%s'`

Draft a commit message matching the style above. Rules:

1. Imperative mood, lowercase, no trailing period.
2. Subject line under 72 characters.
3. If changes touch multiple concerns, list each in the body as a bullet.
4. Scope hint from user (if any): $ARGUMENTS

Output only the commit message — no commentary, no fences.
