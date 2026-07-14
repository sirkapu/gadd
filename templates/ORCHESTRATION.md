# Orchestration — roles × models (TEMPLATE)

Copy into your deployment (suggested: `docs/gadd/orchestration.md`), replace every
`{{PLACEHOLDER}}` with a concrete model pin, and keep it current. Model assignment is a
deployment concern (spec §3); the Does / Never-does columns mirror `spec/GADD.md` §3 and
are NOT yours to weaken.

| Role | Model | Does | Never does |
|---|---|---|---|
| Director/Architect (main session) | `{{FRONTIER_MODEL}}` | Specs with EARS criteria, task decomposition + tier declaration (spec §6), dispatch, arbitration at the 2-round cap, lantern updates | Write production code |
| Executors (subagents) | `{{MID_MODEL}}` | Features, components, contract drafts, tests | Touch `RED_TEAM/`, gate configs, baselines; weaken tests |
| Mechanics (subagents) | `{{CHEAP_MODEL}}` | Zero-judgment chores; running checks and pasting raw output | Anything requiring judgment |
| RED_TEAM — structural adversaries | `{{CHEAP_MODEL}}` | Diff-vs-artifact attack surfaces (contract fidelity, test honesty), one isolated context each | Rewrite code; see another adversary's verdict |
| RED_TEAM — judgment adversaries | `{{STRONG_MODEL}}` | Security / data-integrity / regression judgment, one isolated context each | Rewrite code; see another adversary's verdict |
| Fixer (subagent, separate instance) | `{{STRONG_MODEL}}` | Applies the blockers' one-line fixes, reports back | Grade its own fix |

## Fallback-chain rule

Pin a fallback chain per role (`primary → fallback → stop`) in your copy. One rule governs
every chain:

**Workers may fall back down; graders never do.** An executor or mechanic on a cheaper
fallback is acceptable — its output still faces the full gate. An adversary or gate on a
cheaper model is a silently loosened ratchet: if a grader's pinned tier is unavailable,
the pass WAITS or the Director escalates to the human; it never degrades. Log every
fallback activation in the lantern.
