# Contributing

This is a personal template repo, but the authoring workflow is documented so it stays consistent.

## Adding a component

Use the meta workshop commands from the repo root in Claude Code:

- `/new-command <n>` for a slash command
- `/new-skill <n>` for a skill
- `/new-agent <n>` for a subagent

Each scaffolder asks a few questions, writes the file, and runs the linter.

## Writing rules by hand

Rules don't have a scaffolder. Create `rules/<topic>.md` with YAML frontmatter:

```yaml
---
description: One-sentence purpose
alwaysApply: true     # or omit and use paths
paths:
  - "src/api/**"
---
```

Prefer path-scoped over always-on. See `rules/README.md`.

## Before committing

Run the linter:

```bash
scripts/lint-templates.sh
```

Optionally, run the install integration test and shellcheck — both are cheap and match what CI runs:

```bash
scripts/test-install.sh
shellcheck scripts/*.sh hooks/*.sh
```

A red lint must never land on main. The linter checks:

- Frontmatter presence and required keys
- Description quality (no placeholders, under 500 chars)
- Size budgets (commands 1000, skills 1500, rules 1500, agents 2000 chars)
- Portability (no hard-coded paths)
- Skill name matches its directory
- Agent name matches its filename

## Continuous integration

Every pull request against `main` runs four jobs via `.github/workflows/ci.yml`:

1. **lint templates** — `scripts/lint-templates.sh`
2. **shellcheck** — static analysis of all bash in `scripts/` and `hooks/`
3. **validate json** — `jq empty` on every `settings.json` and example
4. **install integration** — `scripts/test-install.sh` runs the installer into a temp dir and asserts the expected layout, permissions, and refusal cases

A PR cannot merge until all four are green. The same four commands run locally, so you can reproduce any failure without pushing.

## Token efficiency checklist

Before merging any new component, ask:

1. Does the description trigger on the right intents without false positives?
2. Is there any boilerplate (introductions, conclusions, restating the obvious) I can cut?
3. If this is a skill with supporting material, is the detail in sibling files rather than inline?
4. If this is a rule, does it really need `alwaysApply: true`, or can it be path-scoped?
5. Would removing this component cause Claude to make a mistake it otherwise wouldn't? If no, cut it.

## Portability

Templates are copied into unknown future projects. Never include:

- Absolute paths (`/home/...`, `/Users/...`, `C:\...`)
- Names of specific projects, companies, people, or missions
- Language/framework assumptions unless the component is explicitly scoped to that language
- Non-English text in user-facing content

The linter catches hard-coded paths automatically. The rest is on you.
