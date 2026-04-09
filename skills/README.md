# Skills

Directory-based capabilities loaded from `.claude/skills/<n>/SKILL.md`. Each skill is a folder that may contain supporting scripts, references, and examples.

## Frontmatter (required)

```yaml
---
name: skill-name                               # must match directory name
description: Use this skill when <trigger>. Covers <scope>. Do NOT use for <out-of-scope>.
allowed-tools: Read, Grep, Bash(git *)         # optional, restricts tools
---
```

## The description field is the most important part

Claude decides whether to auto-invoke a skill **based on the description alone**. It must:

- Name the trigger conditions explicitly ("Use this skill when...")
- State the scope
- Declare what is out of scope, to prevent false positives
- Stay under ~500 characters

## Progressive disclosure

Keep `SKILL.md` itself terse — under 1500 characters is a reasonable target. Push depth into sibling files and reference them from SKILL.md:

```
skills/my-skill/
├── SKILL.md              ← loaded into context when triggered
├── reference.md          ← loaded only when SKILL.md tells Claude to read it
├── examples/
│   └── basic.md
└── scripts/
    └── helper.sh
```

This keeps the auto-loaded context small while making detail available on demand.
