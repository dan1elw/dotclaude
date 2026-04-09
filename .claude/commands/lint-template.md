---
description: Validate a single template file against frontmatter, size, and portability rules
argument-hint: "<path>"
allowed-tools: Read, Bash(scripts/lint-templates.sh:*), Bash(bash scripts/lint-templates.sh:*)
---

Lint report: !`bash scripts/lint-templates.sh $ARGUMENTS`

If the report shows failures, explain each one briefly and propose the minimal fix. Do not modify the file unless the user asks you to.

If everything passes, confirm in one sentence and stop.
