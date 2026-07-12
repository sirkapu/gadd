# gadd-cc — in-loop adapter for Claude Code

Same invariants as `spec/GADD.md`, enforced INSIDE the executor's loop — plus **tiered model
dispatch for token economy**: the expensive model directs, cheap models burn the bulk tokens.

| Role | Model | Runs as |
|---|---|---|
| Director/Architect | your main session (frontier model) | the `/gadd-loop` command |
| Executors | Sonnet | `agents/gadd-executor.md` |
| Mechanics | Haiku | `agents/gadd-mechanic.md` |
| RED_TEAM | Opus, read-only tools | `agents/gadd-redteam.md` |
| Fixer | Opus, separate instance | `agents/gadd-fixer.md` |

Why this saves tokens: subagents run in their own context windows and return summaries, so the
Director's context stays small; zero-judgment chores route to Haiku (~an order of magnitude
cheaper); RED_TEAM is read-only (no expensive rewrite spirals); the 3-round arbitration cap kills
runaway loops.

## Install
Copy into your repo (or user config):
```bash
cp -r agents/  <repo>/.claude/agents/
cp -r commands/ <repo>/.claude/commands/
```
Then: `/gadd-loop <feature or spec path>`.

Pairs with the deterministic ratchet from `adapters/lv/checks` if installed (`.gadd/`): the loop
runs it as its gate in step 3. Blocking CI + hooks extraction: on the roadmap.
