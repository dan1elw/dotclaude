---
description: Scaffold a new reusable slash command under commands/
argument-hint: "<command-name>"
allowed-tools: Read, Write, Bash(ls:*), Bash(test:*)
---

Create a new command at `commands/$ARGUMENTS.md`.

Steps:

1. Check that `commands/$ARGUMENTS.md` does not already exist. If it does, stop and report.
2. Ask the user in a single message:
   - One-sentence purpose (becomes `description`)
   - Arguments, if any (becomes `argument-hint`)
   - Tools the command must or must not use (becomes `allowed-tools`)
   - Does it need shell command output (`!` backtick) or file references (`@path`)?
3. Write the file with this exact structure:
   ```
   ---
   description: <one sentence, under 100 chars>
   argument-hint: "<hint>"          # omit if no arguments
   allowed-tools: <tools>           # omit to allow all
   ---

   <imperative instruction starting with a verb>

   <optional: steps, constraints, or dynamic context via ! and @>
   ```
4. Body budget: under 1000 characters. If the command needs more, it is doing too much — split it.
5. Run `/lint-template commands/$ARGUMENTS.md` to validate.

Portability check before writing: no hard-coded paths, no project-specific names, English only.
