# OWNERSHIP — path lanes

This is gadd's own dogfood deployment of gadd-lv (phase-4, run #10). The
governed lanes below are grader/product territory: the adversary bench and
the deterministic check scripts themselves. Ordinary ratified development
(spec changes, adapter changes, template changes, test-fixture changes,
instrument changes under bin/) is NOT governed here — it is gated by the
normal RED_TEAM/Ratifier cycle described in [CLAUDE.md](CLAUDE.md), not by
this lane check. Check #2 ([.gadd/checks/02-lane-violation.sh](.gadd/checks/02-lane-violation.sh))
parses the fenced block below — keep it as one glob per line. Commented
lines inside the block are inert examples (proven inert by check #2's
comment-stripping) — uncomment and set a real path to enforce them.

```gadd-governed
RED_TEAM/**
.gadd/checks/**
gadd/BASELINE.json
OWNERSHIP.md
# Placeholder example only, inert while commented — uncomment to govern
# an additional grader-owned lane, e.g. {{AGENT_PROMPTS_DIR}}/*
```

Agent-owned (free to modify): everything else, including `spec/**`,
`bin/**`, `adapters/**`, `templates/**`, `tests/**` (see note below), `docs/**`,
`context/**`, `gadd/**` (baseline acceptance itself is authorship-gated by
check #2's `accept_authors` allowlist, not by this lane list).

**On `tests/` and `RED_TEAM/`:** "agent-owned" above means *not gated by the
deterministic lane check (#2)* — agents add and refine fixtures during normal
ratified development. It does NOT mean ungoverned. The `tests/` and `RED_TEAM/`
fixture corpus is the operator-owned *ratified corpus* (charter item-6): the
Ratifier's L-class whole-corpus-preservation receipt forbids narrowing it,
CODEOWNERS requires operator review of external-PR changes to it, and CI
(`gadd-tests`) re-runs it. A proposer may extend or tighten the corpus; only the
operator may narrow or weaken it.
