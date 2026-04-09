# dotclaude

![ci](https://github.com/USER/dotclaude/actions/workflows/ci.yml/badge.svg)

A personal, lean, token-efficient `.claude/` template for bootstrapping new Claude Code projects.

## Why this exists

Claude Code reads configuration from `.claude/` in your project and from `CLAUDE.md` at the root. Every project starts from scratch: same CLAUDE.md skeleton, same permissions, same handful of slash commands. This repo is the one-time setup, reusable across all future projects.

The goal is **token efficiency**. Everything in this template earns its place on the context budget, or it gets cut.

## Repository layout

This repo is flat. The root **is** the template — `install.sh` copies it into a target project, splitting files between the target root (`CLAUDE.md`) and the target's `.claude/` directory (everything else).

```
dotclaude/
├── CLAUDE.md                     → <target>/CLAUDE.md
├── CLAUDE.local.md.example       → <target>/CLAUDE.local.md (renamed, gitignored)
├── settings.json                 → <target>/.claude/settings.json
├── settings.local.json.example   → <target>/.claude/settings.local.json (renamed, gitignored)
├── rules/                        → <target>/.claude/rules/
├── commands/                     → <target>/.claude/commands/
├── skills/                       → <target>/.claude/skills/
├── agents/                       → <target>/.claude/agents/
├── hooks/                        → <target>/.claude/hooks/
│
├── .claude/                      Meta workshop — used ONLY when developing this repo
├── scripts/                      install.sh, lint-templates.sh
├── .gitignore
├── LICENSE
└── README.md                     (you are here)
```

## Install into a project

```bash
git clone https://github.com/<you>/dotclaude.git ~/dotclaude
cd /path/to/your-project
~/dotclaude/scripts/install.sh
```

Flags:
- `--force` — overwrite existing files
- `--dry-run` — show what would happen without writing
- `--only rules,commands` — copy only selected components

After install, restart Claude Code — skills, agents, and rules are loaded at session start.

## What's in the box

| Component | Purpose | Docs |
|---|---|---|
| `CLAUDE.md` | Always-loaded project instructions | [memory](https://code.claude.com/docs/en/memory) |
| `settings.json` | Permissions, hooks, model defaults | [settings](https://code.claude.com/docs/en/settings) |
| `rules/*.md` | Topic-scoped, optionally path-gated rules | [rules](https://code.claude.com/docs/en/memory#organize-rules-with-claude/rules/) |
| `commands/*.md` | Slash commands invoked with `/name` | [commands](https://code.claude.com/docs/en/skills) |
| `skills/<n>/SKILL.md` | Reusable prompts, auto-invoked or `/name` | [skills](https://code.claude.com/docs/en/skills) |
| `agents/*.md` | Subagents with isolated context | [subagents](https://code.claude.com/docs/en/sub-agents) |
| `hooks/*.sh` | Deterministic automation scripts | [hooks](https://code.claude.com/docs/en/settings) |

## Developing this repo

The `.claude/` directory at the root is the **meta workshop** — it configures Claude Code specifically for authoring and validating templates in this repo. It is never copied to target projects.

From the repo root:
- `/new-command <n>` — scaffold a new slash command
- `/new-skill <n>` — scaffold a new skill
- `/new-agent <n>` — scaffold a new subagent
- `/lint-template <path>` — validate a template's frontmatter, size, and conventions
- `scripts/lint-templates.sh` — run the full lint across all templates

See `.claude/CLAUDE.md` for authoring conventions.

## Continuous integration

Every push and pull request runs three jobs via GitHub Actions (`.github/workflows/ci.yml`):

| Job | What it checks |
|---|---|
| `lint-templates` | Runs `scripts/lint-templates.sh` — frontmatter, size budgets, portability |
| `shellcheck` | Static analysis of all `scripts/*.sh` and `hooks/*.sh` |
| `install-integration` | Runs `scripts/test-install.sh` — 30 assertions covering dry-run, real install, hooks, `--force`, `--only`, and self-install guard |

All three jobs can be run locally before pushing:

```bash
bash scripts/lint-templates.sh
shellcheck scripts/*.sh hooks/*.sh
bash scripts/test-install.sh
```

## Token budget principles

1. **Progressive disclosure.** `SKILL.md` is terse; detail lives in sibling files loaded only when needed.
2. **Path-scoped rules.** `alwaysApply: true` rules cost tokens every turn. Prefer path-gated rules where possible.
3. **No boilerplate.** Skip introductions, overviews, and conclusions. Start with the instruction.
4. **Cut anything Claude can figure out from the code itself.** Don't describe your file structure; Claude can read it.

## License

MIT
