# Hooks

Shell scripts run deterministically by Claude Code at specific lifecycle events, wired via `settings.json`. Hooks cannot be bypassed by Claude — they are the enforcement layer.

## Event types

- **PreToolUse** — runs before a tool executes. Exit non-zero to block.
- **PostToolUse** — runs after a tool executes. Useful for formatting, logging.
- **SessionStart** — runs when a Claude Code session starts. Output is injected into context.
- **UserPromptSubmit** — runs when the user submits a prompt.

## Conventions

- All hooks must be executable: `chmod +x hooks/*.sh`.
- Hooks receive tool input as JSON on stdin. Parse with `jq`.
- Exit 0 = allow, non-zero = block. Print a message to stderr explaining why.
- Keep hooks fast. They run on every matching event.

## Wired in the template settings.json

| Hook | Event | Purpose |
|---|---|---|
| `block-dangerous-commands.sh` | PreToolUse (Bash) | Blocks `rm -rf /`, force pushes, `DROP TABLE`, etc. |
| `scan-secrets.sh` | PreToolUse (Write/Edit) | Blocks writes containing API keys, tokens |
| `session-start.sh` | SessionStart | Injects branch, last commit, and stash state into context |

## Dependencies

These scripts expect `jq` to be installed. Install:
- macOS: `brew install jq`
- Debian/Ubuntu: `apt install jq`
