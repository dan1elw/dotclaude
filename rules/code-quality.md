---
description: Baseline code quality standards
alwaysApply: true
---

# Code Quality

- Names describe intent, not type. `userCount`, not `intUsers`.
- Comments explain **why**, not **what**. If the what isn't obvious, rename or refactor first.
- No dead code. Delete commented-out blocks; git remembers.
- Fail loudly. Prefer early returns and explicit errors over silent fallbacks.
- One concept per file. Split when a file serves two unrelated purposes.
- Imports ordered: stdlib → third-party → local. Blank line between groups.

## Markers

Use these exact tokens so they're greppable:

- `TODO(name):` — planned work, owner required
- `FIXME:` — known defect, must be fixed before release
- `HACK:` — intentional shortcut, explain the trade-off
- `NOTE:` — non-obvious context a future reader will need
