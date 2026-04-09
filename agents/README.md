# Agents

Subagent definitions loaded from `.claude/agents/*.md`. Each agent runs in its own isolated context window — it doesn't see the main conversation history, and its intermediate exploration doesn't pollute your main context.

## Frontmatter

```yaml
---
name: agent-name                               # matches filename
description: When Claude should delegate to this agent. Be specific about triggers.
tools: Read, Grep, Glob                        # optional, restricts tools available to the agent
model: sonnet                                  # optional: sonnet | opus | haiku
color: blue                                    # optional, purely cosmetic
---
```

## When to use an agent vs a skill vs a command

- **Command** — explicit, short, single-file workflow invoked by you.
- **Skill** — richer capability, may auto-invoke, may bundle files. Runs in your main context.
- **Agent** — isolated context window, useful for exploration-heavy or long-running tasks where you don't want the findings to flood your main session. Agent compresses its work and reports back.

## Tool restriction

Restrict tools aggressively. A reviewer agent only needs `Read, Grep, Glob`. An agent that should never modify files should not have `Edit` or `Write`. Less surface area = safer, more predictable behavior.
