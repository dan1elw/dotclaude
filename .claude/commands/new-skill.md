---
description: Scaffold a new reusable skill directory under skills/
argument-hint: "<skill-name>"
allowed-tools: Read, Write, Bash(ls:*), Bash(mkdir:*), Bash(test:*)
---

Create a new skill at `skills/$ARGUMENTS/SKILL.md`.

Steps:

1. Check that `skills/$ARGUMENTS/` does not exist. If it does, stop and report.
2. Ask the user in a single message:
   - **Trigger conditions**: exact user-request patterns that should invoke this skill
   - **Scope**: what the skill covers
   - **Out of scope**: what it must NOT handle (prevents false-positive auto-invocation)
   - **Supporting files**: reference docs, scripts, or examples alongside SKILL.md?
   - **Tool restrictions**: any tools the skill must not use?
3. Create the directory and write `SKILL.md` with this frontmatter:
   ```
   ---
   name: $ARGUMENTS
   description: Use this skill when <trigger>. Covers <scope>. Do NOT use for <out-of-scope>.
   allowed-tools: <tools>           # omit to allow all
   ---
   ```
4. The `description` is the trigger. It must be 2–4 sentences, under ~500 characters, and concrete enough to fire on real intents without false positives.
5. Body: start with the core instruction in one paragraph, then concrete steps or examples. Reference sibling files via `@skills/$ARGUMENTS/file.md` instead of inlining detail.
6. Budget: SKILL.md under 1500 characters. Push depth into sibling files.
7. Run `/lint-template skills/$ARGUMENTS/SKILL.md` to validate.

Portability check: no hard-coded paths, no project-specific names, English only.
