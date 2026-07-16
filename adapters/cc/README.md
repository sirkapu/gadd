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
| Ratifier (packet arbitration for `/mission-loop`) | Opus, read-only tools | `agents/gadd-ratifier.md`, isolated subagent |

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
One command, run from the target repo root:
```bash
bash adapters/cc/bin/install.sh
# or via the root dispatcher:
bash bin/install.sh --adapter=cc
```
This installs: `agents/` → `.claude/agents/` (executor, mechanic, fixer, the five RED_TEAM
adversary agents, and the Ratifier); `commands/` → `.claude/commands/` (`/gadd-loop`,
`/mission-loop`, `/objective-audit`); `RED_TEAM/` → `RED_TEAM/` at the repo root (the bench
definitions — graders; executors never touch them; only copied if absent); `spec/schemas/*.json`
→ `.gadd/schemas/` (verdict + baseline schemas); and `/mission-loop`'s own dependencies
(`bin/loop-lock.sh`, `bin/schedule-loop.sh`, `bin/mission-loop.plist.template`) so the shipped
commands work standalone in the target repo, not just inside gadd itself.

Then: `/gadd-loop <feature or spec path>` for one feature loop, or `/mission-loop` for the
autonomous run-until-done driver (bootstraps via `/objective-audit` if no ratified objective
function exists yet).

Pairs with the deterministic ratchet from `adapters/lv/checks` if installed (`.gadd/`): the loop
runs it as its gate in step 3. Blocking CI + hooks extraction: on the roadmap.
