# Measurement — the escaped-regression loop

**North Star** (ratified 2026-07-14): **escaped-regression rate** across governed repos —
defects that reached acceptance despite the ratchet, divided by accepted pushes. Everything
else (check count, adversary coverage, adapter count) is a means to moving this number down.

## What counts as an escaped regression

A defect **discovered after acceptance** that a *named* gadd check or invariant should have
caught — the ratchet ran, said PASS, and was wrong. Not every bug qualifies: only ones that
map to a specific check (existing or missing) that had the job of catching it. If nothing in
the invariant set was ever meant to catch it, it's a gap in scope, not an escape — note it
in the rejection ledger instead.

## How to record one

Append one JSONL line to `gadd/ESCAPED.jsonl` in the governed repo, fields per
[`spec/schemas/escaped.schema.json`](../spec/schemas/escaped.schema.json):
`date`, `accepted_sha`, `check`, `severity`, `description`, optional `discovered_via`.

One honest entry per defect. This is a **human/Director act** — never automated, never
inferred from logs. If you're not sure a check should have caught it, don't record it as
escaped; raise it in the rejection ledger instead.

## How to measure

```
bin/gadd-fleet.sh ~/code/governed-repo-a ~/code/governed-repo-b
```

Reads `gadd/verdicts/*.json` and `gadd/ESCAPED.jsonl` from each path given. Every verdict
file is validated against `spec/schemas/verdict.schema.json` and every ledger line against
`spec/schemas/escaped.schema.json` before aggregation — only conformant records are admitted;
non-conformant ones are disclosed per repo under `anomalies` (total + `by_reason`). stdout is
one JSON object (per-repo `status` + verdict/finding/escape totals over admitted records +
per-repo `anomalies` + the `north_star` rollup, which counts escapes/pushes over clean repos
only); stderr is a human table. **Output is local-only** — it names private repo paths — never
commit it, never paste it into a shared doc or PR.

## Wired today vs roadmap

- **Wired**: `gadd/ESCAPED.jsonl` ledger format + schema, `bin/gadd-fleet.sh` aggregation
  (verdicts + escapes, per-repo and fleet-wide `escaped_rate`) with **schema admission** —
  verdict files and ledger lines are validated against their spec schemas before aggregation,
  and non-conformant records are excluded and disclosed as per-repo `anomalies` rather than
  silently fail-opened.
- **Roadmap**: escaped-entry schema validation inside `run-all.sh` (the governed-side check
  runner, distinct from `gadd-fleet.sh`'s upstream admission), trend history across runs
  (today each `gadd-fleet.sh` run is a point-in-time snapshot, nothing is stored between
  runs).
