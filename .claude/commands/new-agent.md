---
description: Scaffold a new subagent under agents/
argument-hint: "<agent-name>"
allowed-tools: Read, Write, Bash(ls:*), Bash(test:*)
---

Create a new subagent at `agents/$ARGUMENTS.md`.

Steps:

1. Check that `agents/$ARGUMENTS.md` does not exist. If it does, stop and report.
2. Ask the user in a single message:
   - **Specialty**: what this agent is an expert at (one sentence)
   - **Delegation triggers**: when should Claude auto-delegate to it?
   - **Tool access**: which tools does it actually need? Default to read-only (Read, Grep, Glob) unless there is a reason to allow Edit/Write/Bash.
   - **Model preference**: sonnet (default), opus (complex reasoning), or haiku (fast/cheap)?
3. Write the file with this structure:
   ```
   ---
   name: $ARGUMENTS
   description: <when to delegate, concrete triggers>
   tools: <comma-separated tools>
   model: sonnet
   ---

   You are <role>. <one-paragraph persona>.

   ## Your job

   <numbered steps or bullet constraints>

   ## Output format

   <exactly what the agent should return to the main session>
   ```
4. Principle: restrict tools aggressively. A reviewer agent should never have `Edit` or `Write`.
5. Principle: agents run in isolated context and report back. Tell the agent explicitly to compress its findings — don't return raw exploration.
6. Budget: under 2000 characters. Agent system prompts can be longer than commands because they are loaded only when delegated.
7. Run `/lint-template agents/$ARGUMENTS.md` to validate.

Portability check: no hard-coded paths, no project-specific names, English only.
