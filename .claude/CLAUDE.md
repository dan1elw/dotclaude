# dotclaude — Authoring Context

You are working on **dotclaude**, a template repository of Claude Code components (commands, skills, agents, rules, hooks) copied into other projects by `scripts/install.sh`.

## Two contexts, one repo

- **Repo root = the template.** Files here get copied into other projects. They must be generic and portable.
- **`.claude/` (this directory) = the workshop.** Commands here exist only to help author templates. They are never copied out.

Never mix the two. When asked to create a new reusable component, it goes under `commands/`, `skills/`, `agents/`, `rules/`, or `hooks/` at the repo root. When asked to improve the authoring workflow, it goes under `.claude/commands/`.

## Core principle: token efficiency

Every file in the template must justify its context cost.

1. **Short, specific descriptions.** The `description` field determines whether a skill/command fires. Be specific enough to trigger correctly, but narrow enough to avoid false positives.
2. **Progressive disclosure.** Push detail behind file references, not inline. `SKILL.md` under 1500 characters; reference siblings via `@file.md`.
3. **Path-scope rules.** Prefer `paths:` over `alwaysApply: true`. Always-on rules cost tokens every turn.
4. **No boilerplate.** Skip "Introduction", "Overview", "Conclusion" sections. Start with the instruction.
5. **Concrete over abstract.** One worked example beats three paragraphs of theory.

## Portability rules

Templates in this repo will be copied into projects that don't exist yet. Therefore:

- **No hard-coded absolute paths.** No `/home/`, `/Users/`, `C:\`.
- **No project-specific names.** Don't reference potential projects.
- **No language-specific assumptions** unless the component is explicitly language-scoped.
- **English only** for all user-facing text, comments, and documentation.

## Authoring workflow

1. `/new-command <n>` — scaffold a slash command
2. `/new-skill <n>` — scaffold a skill directory
3. `/new-agent <n>` — scaffold a subagent
4. Write the content
5. `/lint-template <path>` — validate one file, or
6. `scripts/lint-templates.sh` — validate everything

## Conventions

- File naming: kebab-case
- Frontmatter: YAML, minimal keys
- Commit messages: imperative, lowercase, no period
- Size budgets (enforced by the linter):
  - Commands: body under 1000 characters
  - Skills: `SKILL.md` under 1500 characters
  - Rules: under 1500 characters
  - Agents: under 2000 characters (system prompts can be longer)

## Before you commit

Run `scripts/lint-templates.sh`. A red lint must never land on main.
