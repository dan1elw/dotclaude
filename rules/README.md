# Rules

Topic-scoped instructions loaded by Claude Code from `.claude/rules/*.md`. Rules can be always-on or path-gated.

## Frontmatter

```yaml
---
description: One-sentence purpose              # optional
alwaysApply: true                              # optional, default false
paths:                                         # optional; if set, rule loads only when working near these paths
  - "src/api/**"
  - "src/auth/**"
---
```

## Cost rule of thumb

- `alwaysApply: true` — costs tokens every turn. Use sparingly.
- `paths:` — costs tokens only when Claude works on matching files. Prefer this.
- No frontmatter — rule is available but not auto-loaded; reference it explicitly with `@rules/name.md`.

## Files

- `code-quality.md` — naming, comments, file organization (always on)
