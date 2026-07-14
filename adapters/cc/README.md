# gadd-cc — in-loop adapter for Claude Code

Same invariants as `spec/GADD.md`, enforced INSIDE the executor's loop — plus **tiered model
dispatch for token economy**: the expensive model directs, cheap models burn the bulk tokens.

| Role | Model | Runs as |
|---|---|---|
| Director/Architect | your main session (frontier model) | the `/gadd-loop` command |
| Executors | Sonnet | `agents/gadd-executor.md` |
| Mechanics | Haiku | `agents/gadd-mechanic.md` |
| RED_TEAM — judgment adversaries (SECURITY, DATA_INTEGRITY, REGRESSION) | Opus, read-only tools | `agents/gadd-rt-*.md`, one isolated subagent each |
| RED_TEAM — structural adversaries (CONTRACT_FIDELITY, TEST_HONESTY) | Haiku, read-only tools | `agents/gadd-rt-*.md`, one isolated subagent each |
| Fixer | Opus, separate instance | `agents/gadd-fixer.md` |

The RED_TEAM bench is five SEPARATE subagent invocations launched in parallel — never one
agent role-playing five perspectives. Each `gadd-rt-*` agent reads its own definition from
the governed repo's `RED_TEAM/<NAME>.md` (role, attack surface, pass criteria, output
contract) and never sees another adversary's verdict: independence is what makes five
adversaries worth more than one. Models follow the orchestration rule — structural checks
(diff-vs-artifact comparison) on the cheap tier, judgment calls on the strong tier — per
`RED_TEAM/gate-matrix.md`.

Why this saves tokens: subagents run in their own context windows and return summaries, so the
Director's context stays small; zero-judgment chores route to Haiku (~an order of magnitude
cheaper), and so do the structural adversaries; RED_TEAM is read-only (no expensive rewrite
spirals); failed adversaries alone re-run after a fix; the 2-round arbitration cap (spec
invariant 6) kills runaway loops.

## Install
Copy into your repo (or user config):
```bash
cp -r agents/   <repo>/.claude/agents/
cp -r commands/ <repo>/.claude/commands/
cp -r ../../RED_TEAM/ <repo>/RED_TEAM/   # the bench definitions — graders; executors never touch them
```
Then: `/gadd-loop <feature or spec path>`.

Pairs with the deterministic ratchet from `adapters/lv/checks` if installed (`.gadd/`): the loop
runs it as its gate in step 3. Blocking CI + hooks extraction: on the roadmap.
