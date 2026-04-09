---
name: explain-code
description: Use this skill when the user asks to explain, walk through, or understand a file, function, class, or code concept. Covers high-level summaries, mental models, and pointing out non-obvious behavior. Do NOT use for debugging, refactoring, or writing new code.
allowed-tools: Read, Grep, Glob
---

Explain code in layers, deepest insight first.

1. **One-sentence summary.** What does this code do, in plain English?
2. **Mental model.** A short analogy or metaphor that captures the shape of the logic.
3. **The non-obvious parts.** What would surprise a reader? Edge cases, hidden coupling, subtle invariants, performance gotchas.
4. **What to be careful about when modifying it.** Where are the landmines?

Skip the obvious. Don't narrate line-by-line unless the user asks. Don't repeat what a good variable name already says.

If the code spans multiple files, read the entry point first, then follow only the branches relevant to the user's question.
