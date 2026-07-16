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
# Placeholder example only, inert while commented — uncomment to govern
# an additional grader-owned lane, e.g. {{AGENT_PROMPTS_DIR}}/*
```

Agent-owned (free to modify): everything else, including `spec/**`,
`bin/**`, `adapters/**`, `templates/**`, `tests/**`, `docs/**`,
`context/**`, `gadd/**` (baseline acceptance itself is authorship-gated by
check #2's `accept_authors` allowlist, not by this lane list).
